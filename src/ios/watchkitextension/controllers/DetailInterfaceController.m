#import "DetailInterfaceController.h"
#import "WatchKitUIHelper.h"

@implementation DetailInterfaceController

- (NSString*) getPageID {
  return @"detail";
}

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context]; // passed from our previous page seque callback
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];
  [WKInterfaceController openParentApplication:@{@"action" : @"onAppDetailPageRequestsUpdate"} reply:nil];
}

@end