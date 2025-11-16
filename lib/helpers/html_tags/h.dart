import 'html_tags.dart';

abstract class _Heading extends Tag {
  final String text;
  final int level;

  const _Heading({required this.text, required this.level});

  @override
  void build({required StringBuffer buffer}) {
    buffer.write('<h$level>$text</h$level>');
  }
}

class H1 extends _Heading {
  const H1({required super.text}) : super(level: 1);
}

class H2 extends _Heading {
  const H2({required super.text}) : super(level: 2);
}

class H3 extends _Heading {
  const H3({required super.text}) : super(level: 3);
}

class H4 extends _Heading {
  const H4({required super.text}) : super(level: 4);
}

class H5 extends _Heading {
  const H5({required super.text}) : super(level: 5);
}

class H6 extends _Heading {
  const H6({required super.text}) : super(level: 6);
}
