#import "AlbumSaverPlugin.h"
#import <album_saver/album_saver-Swift.h>

@implementation AlbumSaverPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAlbumSaverPlugin registerWithRegistrar:registrar];
}
@end
