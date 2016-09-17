#import "InterfaceController.h"
#import "WatchKitHelper.h"
#import "WormholeManager.h"

@implementation InterfaceController

- (NSString*) getPageID {
  return @"AppMain";
}

// When the app is launched from a notification.
// If launched from app icon in notification UI, identifier will be empty.
// Note that (only) the default interfacecontroller will receive this message.
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
  [WatchKitHelper openParent:@"applewatch.callback.onRemoteNotification" withParams:identifier];
}

// When the app is launched from a notification.
// If launched from app icon in notification UI, identifier will be empty
// Note that (only) the default interfacecontroller will receive this message.
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
  [WatchKitHelper openParent:@"applewatch.callback.onLocalNotification" withParams:identifier];
}


@end