#import "InterfaceController.h"
#import "WatchKitHelper.h"

@implementation InterfaceController

- (instancetype)init {
    id obj = [super init];
    NSString *wormholeIdentifier = @"fromjstowatchapp-navigation";
    // Initialize the wormhole
#if defined (TARGET_OS_WATCH) && TARGET_OS_WATCH >= 2
    self.listeningWormhole = MMWormholeSession.sharedListeningSession;
    [self.listeningWormhole listenForMessageWithIdentifier:wormholeIdentifier listener:^(id messageObject) {
                                                      [self pushControllerWithName:[messageObject valueForKey:@"id"] context:messageObject];
                                                  }];
    
    // Make sure we are activating the listening wormhole so that it will receive new messages from
    // the WatchConnectivity framework.
    [self.listeningWormhole activateSessionListening];
    self.navwormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:[super getAppGroup]
                                                         optionalDirectory:@"wormhole"
                                                            transitingType:MMWormholeTransitingTypeSessionContext];
#else
    self.navwormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:[super getAppGroup]
                                                            optionalDirectory:@"wormhole"];
    
    [self.navwormhole listenForMessageWithIdentifier:wormholeIdentifier listener:^(id messageObject) {
        [self pushControllerWithName:[messageObject valueForKey:@"id"] context:messageObject];
    }];
#endif
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