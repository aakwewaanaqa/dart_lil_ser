import 'dart:io';

import 'package:dart_lil_ser/commands/file.dart';
import 'package:path/path.dart' as p;
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
}
