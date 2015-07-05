#import "InterfaceController.h"
#import "WatchKitHelper.h"

@implementation InterfaceController

- (NSString*) getPageID {
  return @"main";
}

- (void)willActivate {
  [super willActivate];
  // TODO applewatch.callback.onAppRequestsUpdate
  [WatchKitHelper openParent:@"onAppRequestsUpdate"];
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