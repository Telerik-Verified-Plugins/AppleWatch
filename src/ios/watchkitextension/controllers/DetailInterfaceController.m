#import "DetailInterfaceController.h"
#import "WatchKitHelper.h"

@implementation DetailInterfaceController

- (NSString*) getPageID {
  return @"detail";
}

- (void)willActivate {
  [super willActivate];
  // TODO applewatch.callback.onAppDetailPageRequestsUpdate, or something with [self getPageID]
 [WatchKitHelper openParent:@"onAppDetailPageRequestsUpdate"];
}

@end