part of 'html_tags.dart';

abstract class Tag {
  final String? style;

  void build({required StringBuffer buffer});

  const Tag({this.style});
}

abstract class ContainerTag extends Tag {
  final List<Tag> children;

  const ContainerTag({required this.children, super.style});

  void preBuild({required StringBuffer buffer});
  void postBuild({required StringBuffer buffer});

  @override
  void build({required StringBuffer buffer}) {
    preBuild(buffer: buffer);
    for (final child in children) {
      child.build(buffer: buffer);
    }
    postBuild(buffer: buffer);
  }
}
