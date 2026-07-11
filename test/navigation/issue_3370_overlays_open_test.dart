// Regression test for upstream issue #3370:
// Get.isOverlaysOpen (and friends) must not throw when called before
// a GetMaterialApp/GetRoot has been mounted.
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  test("overlay getters are safe before routing initialization", () {
    expect(() => Get.isOverlaysOpen, returnsNormally);
    expect(Get.isOverlaysOpen, false);
    expect(Get.isOverlaysClosed, true);
    expect(Get.isDialogOpen, isNull);
    expect(Get.isBottomSheetOpen, isNull);
  });
}
