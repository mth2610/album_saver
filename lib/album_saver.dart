import 'dart:async';

import 'package:flutter/services.dart';

class AlbumSaver {
  static const MethodChannel _channel = const MethodChannel('album_saver');

  static Future saveToAlbum({String filePath, String albumName}) async {
    return await _channel.invokeMethod('saveToAlbum',
      {
        'filePath': filePath,
        'albumName': albumName,
      });
  }

  /// This function just can work on Android
  static Future createAlbum({String albumName}) async {
    return await _channel.invokeMethod('createAlbum',
      {
        'albumName': albumName,
      });
  }

  static Future<String> getDcimPath() async {
    return await _channel.invokeMethod('getDcimPath',
      {
      });
  }
}
