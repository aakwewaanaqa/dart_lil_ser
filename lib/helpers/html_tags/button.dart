part of 'html_tags.dart';

class Button extends Tag {
  final String type;
  final String? text;

  Button({required this.type, this.text});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<button type="$type">');

    if (text != null) {
      buffer.write(text);
    }
    buffer.write('</button>');
  }
}
