class CustomNavBarController {
  int _currentScreen = 0;
  int screenCount;

  CustomNavBarController({required this.screenCount});

  Stream<int> get currentScreenStream =>
      Stream.periodic(const Duration(seconds: 1), (c) => _currentScreen);

  void setCurrentScreen(int index) {
    _currentScreen = index;
  }
}
