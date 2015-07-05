#import "GlanceController.h"
#import "WatchKitUIHelper.h"

@implementation GlanceController

- (NSString*) getPageID {
  return @"glance";
}

- (void)willActivate {
  [super willActivate];
  // TODO applewatch.callback.onGlanceRequestsUpdate
  [WatchKitHelper openParent:@"onGlanceRequestsUpdate"];
}

@end