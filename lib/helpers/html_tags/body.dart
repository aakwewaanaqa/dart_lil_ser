import 'tag.dart';

class Body extends ContainerTag {
  Body({required super.children});

  @override
  void postBuild({required StringBuffer buffer}) {
    buffer.write('</body>');
  }

  @override
  void preBuild({required StringBuffer buffer}) {
    buffer.write('<body>');
  }
}
