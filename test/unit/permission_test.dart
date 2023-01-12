import 'package:courier_market_mobile/api/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Permission should match simple items", () {
    final perms = Permissions(['a', 'b']);
    expect(perms.can('a'), true);
    expect(perms.can('b'), true);
  });

  test("Permission should not match foreign items", () {
    final perms = Permissions(['a', 'b']);
    expect(perms.can('c'), false);
  });

  test("Permission should match one of any", () {
    final perms = Permissions(['a', 'b']);
    expect(perms.canAny(['b', 'c']), true);
  });

  test("Permission should not match none of any", () {
    final perms = Permissions(['a', 'b']);
    expect(perms.canAny(['c', 'd']), false);
  });

  test("Permission should match all of all", () {
    final perms = Permissions(['a', 'b', 'c']);
    expect(perms.canAll(['a', 'b']), true);
    expect(perms.canAll(['b', 'c']), true);
    expect(perms.canAll(['c', 'd']), false);
  });

  test("Permission should allow wildcards", () {
    final perms = Permissions(['a.*', 'b']);
    expect(perms.can('a.foo'), true);
    expect(perms.can('b.foo'), false);
  });
}
