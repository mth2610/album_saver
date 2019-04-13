import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:album_saver/album_saver.dart';

void main() {
  const MethodChannel channel = MethodChannel('album_saver');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AlbumSaver.platformVersion, '42');
  });
}
