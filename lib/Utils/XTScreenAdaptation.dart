import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class XTScreenAdaptation {
  static bool isTablet = false;
  static double tabletScale = 0.8;
  static bool isLandscape = false;
  static bool isBaseOnWidth = true;

  static ensureScreenSize() async {
    await ScreenUtil.ensureScreenSize();
  }

  static init(BuildContext context, {bool? setTablet}) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), //暂时只支持竖屏
      // designSize: MediaQuery.of(context).orientation == Orientation.portrait
      //     ? const Size(375, 812)
      //     : const Size(812, 375),
    );

    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    isTablet = setTablet ?? false;
  }

  static double getXTPx(num size) {
    var transformedSize = isBaseOnWidth
        ? ScreenUtil().setWidth(size)
        : ScreenUtil().setHeight(size);

    if (XTScreenAdaptation.isTablet) {
      transformedSize = transformedSize * XTScreenAdaptation.tabletScale;
    }

    return transformedSize;
  }

  static double getXTSp(num size) {
    return XTScreenAdaptation.isTablet
        ? ScreenUtil().setSp(size) * XTScreenAdaptation.tabletScale
        : ScreenUtil().setSp(size);
  }
}

extension XTScreenAdaptationExtension on num {
  double get px => XTScreenAdaptation.getXTPx(this);

  double get sp => XTScreenAdaptation.getXTPx(this);
}
