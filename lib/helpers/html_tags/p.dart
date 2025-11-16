import 'tag.dart';

class P extends Tag {
  final String text;

  P({required this.text});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<p>$text</p>');
  }
}
