#import "InterfaceController.h"
#import "WatchKitHelper.h"

@implementation InterfaceController

- (instancetype)init {
  id obj = [super init];
  
  self.navwormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:[super getAppGroup]
                                                          optionalDirectory:@"wormhole"];

  NSString *wormholeIdentifier = @"fromjstowatchapp-navigation";
  [self.navwormhole listenForMessageWithIdentifier:wormholeIdentifier listener:^(id messageObject) {
    [self pushControllerWithName:[messageObject valueForKey:@"id"] context:messageObject];
  }];
  
  return obj;
}

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