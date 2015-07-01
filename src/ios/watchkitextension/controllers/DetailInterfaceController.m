#import "DetailInterfaceController.h"
#import "WatchKitUIHelper.h"

// TODO copy from InterfaceController when that's done, also: do some code reuse beforehand
@implementation DetailInterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  [WKInterfaceController openParentApplication:@{@"action" : @"onAppDetailPageRequestsUpdate"} reply:nil];
}

# pragma callback actions
- (IBAction)buttonAction {
  // TODO get action from actionButton.onButtonPressed (store in a var?)
  NSString* cb = self.actionButtonCallback;
  if (cb) {
    [WKInterfaceController openParentApplication:@{@"action" : cb} reply:nil];
  }
}

- (IBAction)switch1Action:(BOOL)on {
}

@end