part of 'html_tags.dart';

class A extends ContainerTag {
  final String href;

  A({required this.href, required super.children});

  @override
  void postBuild({required StringBuffer buffer}) {
    buffer.write('</a>');
  }

  @override
  void preBuild({required StringBuffer buffer}) {
    buffer.write('<a href="$href">');
  }
}
