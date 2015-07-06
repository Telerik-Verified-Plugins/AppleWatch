#import "InterfaceController.h"
#import "WatchKitHelper.h"

@implementation InterfaceController

- (NSString*) getPageID {
  return @"main";
}

- (void)willActivate {
  [super willActivate];
  // TODO applewatch.callback.onAppRequestsUpdate, or something with [self getPageID]
  [WatchKitHelper openParent:@"onAppRequestsUpdate"];
}

@end