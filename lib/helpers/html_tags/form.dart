part of 'html_tags.dart';

class Form extends ContainerTag {
  final String? action;
  final String? method;
  final String? enctype;

  Form({this.action, this.method, this.enctype, required super.children});

  @override
  void postBuild({required StringBuffer buffer}) {
    buffer.write('</form>');
  }

  @override
  void preBuild({required StringBuffer buffer}) {
    buffer.write('<form');
    if (action != null) {
      buffer.write(' action="$action"');
    }

    if (method != null) {
      buffer.write(' method="$method"');
    }

    if (enctype != null) {
      buffer.write(' enctype="$enctype"');
    }

    buffer.write('>');
  }
}
