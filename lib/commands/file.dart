import 'dart:io';

import 'package:args/args.dart' show ArgParser, ArgResults;
import '../helpers/html_tags/html_tags.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';

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
    final filePath = p.join(wd, request.url.path);

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
      final entries = dir.list();
      return Response.ok(
        await _Embeded().dirTemplate(
          currentPath: request.url.path,
          entities: entries,
        ),
        headers: {HttpHeaders.contentTypeHeader: 'text/html'},
      );
    } else if (isFile) {
      // The file exists, so we serve it.
      final file = File(resolvedPath);
      final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
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

      // Create a temporary directory to store uploaded files.
      final tempDir = Directory.systemTemp.createTempSync('upload_');
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

        // Save the file to the directory specified by the URL path.
        final uploadDir = Directory(
          p.join(Directory.current.path, request.url.path),
        );
        if (!await uploadDir.exists()) {
          await uploadDir.create(recursive: true);
        }
        final file = File(p.join(uploadDir.path, filename));
        final sink = file.openWrite();
        await part.pipe(sink);
        await sink.close();
      }

      // Redirect back to the current directory to refresh the page.
      final redirectUri = Uri(path: request.url.path);
      return Response.seeOther(redirectUri);
    } catch (e) {
      return Response.internalServerError(body: 'Error during file upload: $e');
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
  Future<String> dirTemplate({
    required String currentPath,
    required Stream<FileSystemEntity> entities,
  }) async {
    return HtmlDoc(
      lang: "en-US",
      head: Head.minimal(),
      body: Body(
        style: 'margin: 20px',
        children: ([
          H1(text: 'Index of $currentPath'),
          if (currentPath != '/')
            A(
              href: '..',
              children: [const P(text: '../')],
            ),
          // List files and directories
          ...(await entities.map((entity) {
            final entityName = p.basename(entity.path);
            final isDir = entity is Directory;
            return A(
              href: entityName,
              children: [P(text: isDir ? '$entityName/' : entityName)],
            );
          }).toList()),
          // HTML form for file upload
          Form(
            method: 'POST',
            enctype: 'multipart/form-data',
            children: [
              Label(text: 'Upload file:', for_: 'file'),
              Input(type: 'file', id: 'file', name: 'file', required_: true),
              Button(type: 'submit', text: 'Upload'),
            ],
          ),
        ]),
      ),
    ).finalize();
  }
}
