import 'dart:ui';

enum ScreenType { Mobile, Tablet, Desktop }

ScreenType deviceName(Size size) {
  print("size.width");
  print(size.width);
  if (size.width < 600) {
    return ScreenType.Mobile;
  } else if (size.width > 600 && size.width < 1200) {
    return ScreenType.Tablet;
  } else {
    return ScreenType.Desktop;
  }
}
