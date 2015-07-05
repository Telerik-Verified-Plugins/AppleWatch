#import "InterfaceController.h"
#import "WatchKitUIHelper.h"

@implementation InterfaceController

- (NSString*) getPageID {
  return @"main";
}

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
}

- (void)willActivate {
  // This method is called when the watch view controller is about to be visible to the user
  [super willActivate];
  [WKInterfaceController openParentApplication:@{@"action" : @"onAppRequestsUpdate"} reply:nil];
}

# pragma custom callback actions
// triggered when a navigation button was pressed
- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
  // could pass data here to the next page, no need yet.. perhaps for the title in case of a modal nav because the title from the phone arrives too late (you briefly see the 'cancel' label
  return nil;
}

# pragma notification callbacks (TODO move to super)
// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
//  int i=0; // eg. "firstButtonAction"
}

// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
//  int i=0;
}

@end