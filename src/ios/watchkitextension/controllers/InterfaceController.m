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

@end