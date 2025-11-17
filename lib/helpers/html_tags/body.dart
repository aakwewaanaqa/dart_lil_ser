import 'tag.dart';

class Body extends ContainerTag {
  Body({required super.children, super.style});

  @override
  void postBuild({required StringBuffer buffer}) {
    buffer.write('</body style="$style">');
  }

  @override
  void preBuild({required StringBuffer buffer}) {
    buffer.write('<body>');
  }
}
