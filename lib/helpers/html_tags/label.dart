part of 'html_tags.dart';

class Label extends Tag {
  final String? for_;
  final String? text;

  Label({required this.text, this.for_});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<label');
    if (for_ != null) {
      buffer.write(' for="$for_"');
    }
    buffer.write('>');

    if (text != null) {
      buffer.write(text);
    }
    buffer.write('</label>');
  }
}
