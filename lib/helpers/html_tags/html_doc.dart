part of 'html_tags.dart';

class HtmlDoc extends Tag {
  final String lang;
  final Head head;
  final Body body;

  HtmlDoc({required this.lang, required this.head, required this.body});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<!DOCTYPE html>');
    buffer.write('<html lang="$lang">');
    head.build(buffer: buffer);
    body.build(buffer: buffer);
    buffer.write('</html>');
  }

  String finalize() {
    final buffer = StringBuffer();
    build(buffer: buffer);
    return buffer.toString();
  }
}
