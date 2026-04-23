//
import 'dart:io';

import 'package:args/args.dart' show ArgParser, ArgResults;

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:embed_annotation/embed_annotation.dart';

part 'file.g.dart';

@EmbedStr('editor.html')
String editorHtml = _$editorHtml;

@EmbedStr('directory.html')
String directoryHtml = _$directoryHtml;

/// file serving command
class FileCmd {
  ArgParser get argParser {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Print usage.')
      ..addOption('port', abbr: 'p', help: 'The port to server files')
      ..addOption('ip', abbr: 'i', help: 'The IP to serve files');
  }

  Future<String> _defineIp(ArgResults results) async {
    if (results.option('ip') != null) {
      return results.option('ip')!;
    }

    final addresses = await NetworkInterface.list();
    for (final address in addresses) {
      for (final addr in address.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }

    return InternetAddress.loopbackIPv4.address;
  }

  Future<int> _definePort(ArgResults results) async {
    if (results.option('port') != null) {
      return int.parse(results.option('port')!);
    }

    return 1347;
  }

  /// Handle GET requests for file serving.
  Future<Response> _handleGet(Request request) async {
    // Construct the file path from the request URI.
    // We use p.join to safely combine path segments.
    // The path is relative to the current working directory.
    final wd = Directory.current.path;
    final filePath = p.join(wd, Uri.decodeComponent(request.url.path));

    // To prevent path traversal attacks (e.g., /../../etc/passwd),
    // we ensure the resolved path is within the current directory.
    final resolvedPath = p.normalize(filePath);
    if (!p.isWithin(wd, resolvedPath) && wd != resolvedPath) {
      return Response.forbidden('Access denied.');
    }

    final isFile = await FileSystemEntity.isFile(resolvedPath);
    final isDirectory = await FileSystemEntity.isDirectory(resolvedPath);
    if (isDirectory) {
      final dir = Directory(resolvedPath);
      final entries = await dir.list().toList();
      return Response.ok(
        _Embeded().dirTemplate(
          currentPath: request.url.path,
          entities: entries,
        ),
        headers: {HttpHeaders.contentTypeHeader: 'text/html'},
      );
    } else if (isFile) {
      // The file exists.
      final file = File(resolvedPath);
      final mime = lookupMimeType(file.path) ?? 'application/octet-stream';

      // If it's a text file (or likely text), serve the editor.
      if (mime.startsWith('text/') ||
          mime == 'application/json' ||
          mime == 'application/javascript' ||
          mime == 'application/x-shellscript' ||
          mime == 'application/xml') {
        final content = await file.readAsString();

        // Determine CodeMirror mode
        String mode = 'null'; // Default to plain text
        if (mime == 'application/json') {
          mode = '"application/json"';
        } else if (mime == 'application/javascript') {
          mode = '"javascript"';
        } else if (mime == 'application/xml') {
          mode = '"xml"';
        } else if (mime == 'text/html') {
          mode = '"htmlmixed"';
        } else if (mime == 'text/css') {
          mode = '"css"';
        } else if (mime == 'application/x-shellscript') {
          mode = '"shell"';
        } else if (file.path.endsWith('.dart')) {
          mode = '"dart"';
        } else if (file.path.endsWith('.yaml') || file.path.endsWith('.yml')) {
          mode = '"yaml"';
        } else if (file.path.endsWith('.go')) {
          mode = '"text/x-go"';
        } else if (file.path.endsWith('.py')) {
          mode = '"python"';
        } else if (file.path.endsWith('.rs')) {
          mode = '"text/x-rustsrc"';
        } else if (file.path.endsWith('.java')) {
          mode = '"text/x-java"';
        } else if (file.path.endsWith('.cs')) {
          mode = '"text/x-csharp"';
        } else if (file.path.endsWith('.ts')) {
          mode = '"application/typescript"';
        }

        final html = editorHtml
            .replaceFirst('{{MODE}}', mode)
            .replaceFirst('{{FILENAME}}', p.basename(file.path))
            .replaceFirst('{{CONTENT}}', content);

        return Response.ok(
          html,
          headers: {HttpHeaders.contentTypeHeader: 'text/html'},
        );
      }

      // Otherwise serve the file content directly.
      final length = (await file.length()).toString();
      final headers = {
        HttpHeaders.contentTypeHeader: mime,
        HttpHeaders.contentLengthHeader: length,
      };
      final stream = file.openRead();
      return Response.ok(stream, headers: headers);
    } else {
      // The file doesn't exist, return a 404.
      return Response.notFound('File not found');
    }
  }

  /// Handle POST requests for file uploading.
  Future<Response> _handlePost(Request request) async {
    try {
      // Parse the content type to ensure it's multipart/form-data.
      final contentType = request.headers[HttpHeaders.contentTypeHeader];
      if (contentType == null ||
          !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: 'Invalid content type.');
      }

      final boundary = contentType.split('boundary=').last;
      final transformer = MimeMultipartTransformer(boundary);
      final bodyStream = request.read();

      await for (final part in transformer.bind(bodyStream)) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition == null ||
            !contentDisposition.contains('filename=')) {
          continue; // Skip parts without a file.
        }

        // Extract the filename from the content-disposition header.
        final filename = RegExp(
          r'filename="([^"]+)"',
        ).firstMatch(contentDisposition)?.group(1);
        if (filename == null) {
          continue;
        }

        // Resolve the target path.
        final targetPath = p.join(Directory.current.path, Uri.decodeComponent(request.url.path));

        File file;
        if (await FileSystemEntity.isFile(targetPath)) {
          // If the target is an existing file, overwrite it (Editor Save).
          file = File(targetPath);
        } else {
          // Otherwise, treat it as a directory (File Upload).
          final uploadDir = Directory(targetPath);
          if (!await uploadDir.exists()) {
            await uploadDir.create(recursive: true);
          }
          file = File(p.join(uploadDir.path, filename));
        }
        final sink = file.openWrite();
        await part.pipe(sink);
        await sink.close();
      }

      // Redirect back to the current directory to refresh the page.
      final redirectUri = Uri(path: request.url.path);
      print(redirectUri);
      return Response.seeOther(redirectUri);
    } catch (e, s) {
      return Response.internalServerError(
        body: 'Error during file upload: $e $s',
      );
    }
  }

  Future<void> execute(ArgResults args) async {
    if (args.flag('help')) {
      print(argParser.usage);
      return;
    }

    try {
      final ip = await _defineIp(args);
      final port = await _definePort(args);

      final router = Router();
      router.get('/<ignored|.*>', _handleGet);
      router.post('/<ignored|.*>', _handlePost);

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      print('Serving files at http://$ip:$port');
      await io.serve(handler, ip, port);
    } catch (e) {
      print('Error: $e');
    }
  }
}

class _Embeded {
  String dirTemplate({
    required String currentPath,
    required List<FileSystemEntity> entities,
  }) {
    final fileListBuffer = StringBuffer();

    // Add parent directory link if not root
    if (currentPath != '/') {
      fileListBuffer.write('''
        <a href=".." class="file-item">
            <span class="icon">📁</span>
            <span class="name">..</span>
        </a>
      ''');
    }

    // Sort entities: directories first, then files
    entities.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return p.basename(a.path).compareTo(p.basename(b.path));
    });

    for (final entity in entities) {
      final entityName = p.basename(entity.path);
      final isDir = entity is Directory;
      final href = isDir ? './$entityName/' : './$entityName';
      final icon = isDir ? '📁' : '📄';

      fileListBuffer.write('''
        <a href="$href" class="file-item">
            <span class="icon">$icon</span>
            <span class="name">$entityName</span>
        </a>
      ''');
    }

    return directoryHtml
        .replaceFirst('{{CURRENT_PATH}}', currentPath)
        .replaceFirst(
          '{{CURRENT_PATH}}',
          currentPath,
        ) // Replace in title and body
        .replaceFirst('{{FILE_LIST}}', fileListBuffer.toString())
        .replaceFirst('{{ITEM_COUNT}}', entities.length.toString());
  }
}
