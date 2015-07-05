#import "GlanceController.h"
#import "WatchKitUIHelper.h"

@implementation GlanceController

- (NSString*) getPageID {
  return @"glance";
}

- (void)willActivate {
  [super willActivate];
  // TODO applewatch.callback.onGlanceRequestsUpdate, or something with [self getPageID]
  [WatchKitHelper openParent:@"onGlanceRequestsUpdate"];
}

@end