part of 'html_tags.dart';

class Input extends Tag {
  final String type;
  final String? id;
  final String? name;
  final bool required_;

  Input({
    required this.type,
    required this.id,
    required this.name,
    this.required_ = false,
  });

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<input type="$type"');

    if (id != null) {
      buffer.write(' id="$id"');
    }

    if (name != null) {
      buffer.write(' name="$name"');
    }

    if (required_) {
      buffer.write(' required');
    }

    buffer.write(' />');
  }
}
