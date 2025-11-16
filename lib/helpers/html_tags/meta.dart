import 'tag.dart';

class Meta extends Tag {
  final String key;
  final String value;

  Meta({required this.key, required this.value});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<meta $key="$value" />');
  }
}
