import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chatbot/app_libs.dart';
import 'dart:ui' as ui;

class ImageUtils {
  ImageUtils._();

  static Widget getAssetImage(String? src,
      {double? height, double? width, fit = BoxFit.cover}) {
    return Image.asset(
      src!,
      height: height,
      width: width,
      fit: fit,
    );
  }

  static Widget getSvgFromAsset(String src,
      {double? height, double? width, fit = BoxFit.cover, Color? color}) {
    return SvgPicture.asset(
      src,
      color: color,
      width: width,
      height: height,
      fit: fit,
    );
  }

  static Widget getSvgFromNetwork(String src,
      {double? height, double? width, fit = BoxFit.cover, Color? color}) {
    final Widget networkSvg = SvgPicture.network(
      src,
      placeholderBuilder: (BuildContext context) => Container(
          padding: const EdgeInsets.all(30.0),
          child: const CircularProgressIndicator()),
    );

    return networkSvg;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
