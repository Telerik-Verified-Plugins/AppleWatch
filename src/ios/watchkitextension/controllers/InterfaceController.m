#import "InterfaceController.h"
#import "WatchKitHelper.h"

@implementation InterfaceController

// TODO replace by one 'showPage' method which also takes care of navigation and will not invoke the webview in willactivate if not required
- (instancetype)init {
  id obj = [super init];
  
  NSString *appGroup = [NSString stringWithFormat:@"group.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
  appGroup = [appGroup stringByReplacingOccurrencesOfString:@".watchkitextension" withString:@""];

  self.navwormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:appGroup
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