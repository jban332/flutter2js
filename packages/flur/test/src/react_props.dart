import 'package:flur/flur.dart';
import 'package:test/test.dart';

void main() {
  test("Names", () {
    expect(ReactProps.nameFromKebabCase("font-family"), "fontFamily");
    expect(ReactProps.nameToKebabCase("fontFamily"), "font-family");

    expect(ReactProps.nameFromHtmlAttributeName("for"), "htmlFor");
    expect(ReactProps.nameFromHtmlAttributeName("data-x-y"), "dataXY");
    expect(ReactProps.nameToHtmlAttributeName("htmlFor"), "for");
    expect(ReactProps.nameToHtmlAttributeName("data-x-y"), "data-x-y");
    expect(ReactProps.nameToHtmlAttributeName("dataXY"), "data-x-y");
  });
}