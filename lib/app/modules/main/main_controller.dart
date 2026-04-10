import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Handles the back button.
  /// If not on the first tab, switches to the first tab.
  /// Otherwise, allows the app to exit.
  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      changePage(0);
      return false;
    }
    return true;
  }
}
