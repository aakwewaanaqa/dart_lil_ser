abstract class Tag {
  void build({required StringBuffer buffer});

  const Tag();
}

abstract class ContainerTag extends Tag {
  final List<Tag> children;

  const ContainerTag({required this.children});

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
