import 'dart:io';

import 'package:dart_lil_ser/commands/file.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Embedded.dirTemplate', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dart_lil_ser_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('href for Chinese-named file is URL-encoded', () async {
      final chineseFile = File(p.join(tempDir.path, '中文.txt'));
      await chineseFile.create();

      final html = Embedded().dirTemplate(
        currentPath: '/',
        entities: [chineseFile],
      );

      expect(html, contains('href="./%E4%B8%AD%E6%96%87.txt"'));
      expect(html, contains('<span class="name">中文.txt</span>'));
    });

    test('href for ASCII-named file is unchanged', () async {
      final asciiFile = File(p.join(tempDir.path, 'hello.txt'));
      await asciiFile.create();

      final html = Embedded().dirTemplate(
        currentPath: '/',
        entities: [asciiFile],
      );

      expect(html, contains('href="./hello.txt"'));
    });

    test('href for Chinese-named directory is URL-encoded with trailing slash',
        () async {
      final chineseDir =
          Directory(p.join(tempDir.path, '中文資料夾'));
      await chineseDir.create();

      final html = Embedded().dirTemplate(
        currentPath: '/',
        entities: [chineseDir],
      );

      expect(
        html,
        contains('href="./%E4%B8%AD%E6%96%87%E8%B3%87%E6%96%99%E5%A4%BE/"'),
      );
      expect(html, contains('<span class="name">中文資料夾</span>'));
    });
  });

  group('FileCmd._handleGet', () {
    late Directory tempDir;
    late Directory originalDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dart_lil_ser_test_');
      originalDir = Directory.current;
      Directory.current = tempDir;
    });

    tearDown(() async {
      Directory.current = originalDir;
      await tempDir.delete(recursive: true);
    });

    test('returns 200 for Chinese-named file requested via URL-encoded path',
        () async {
      final chineseFile = File(p.join(tempDir.path, '中文.txt'));
      await chineseFile.writeAsString('hello');

      final handler = FileCmd().buildHandler();
      // Browser sends percent-encoded URL for the Chinese filename.
      final request = Request(
        'GET',
        Uri.parse('http://localhost/%E4%B8%AD%E6%96%87.txt'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
    });

    test('returns 200 for ASCII-named file', () async {
      final asciiFile = File(p.join(tempDir.path, 'hello.txt'));
      await asciiFile.writeAsString('hello');

      final handler = FileCmd().buildHandler();
      final request = Request(
        'GET',
        Uri.parse('http://localhost/hello.txt'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
    });

    test('returns 404 for non-existent file', () async {
      final handler = FileCmd().buildHandler();
      final request = Request(
        'GET',
        Uri.parse('http://localhost/nonexistent.txt'),
      );
      final response = await handler(request);

      expect(response.statusCode, 404);
    });

    test('returns 200 for directory listing with Chinese-named contents',
        () async {
      final chineseFile = File(p.join(tempDir.path, '中文.txt'));
      await chineseFile.writeAsString('hello');

      final handler = FileCmd().buildHandler();
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = await response.readAsString();
      // The listing should contain an encoded href for the Chinese file.
      expect(body, contains('%E4%B8%AD%E6%96%87.txt'));
    });
  });
}
