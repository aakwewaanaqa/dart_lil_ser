import 'package:dart_lil_ser/helpers/html_tags/meta.dart';

import 'tag.dart';

class Head extends ContainerTag {
  Head({required super.children});

  @override
  void postBuild({required StringBuffer buffer}) {
    buffer.write('</head>');
  }

  @override
  void preBuild({required StringBuffer buffer}) {
    buffer.write('<head>');
  }

  factory Head.minimal({String charset = 'utf-8'}) {
    return Head(
      children: [Meta(key: 'charset', value: charset)],
    );
  }
}
