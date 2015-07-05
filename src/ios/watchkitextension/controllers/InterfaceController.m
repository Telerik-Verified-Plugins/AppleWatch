#import "InterfaceController.h"
#import "WatchKitUIHelper.h"

@implementation InterfaceController

- (NSString*) getPageID {
  return @"main";
}

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
//  [WKInterfaceController openParentApplication:@{@"action" : @"onAppRequestsUpdate"} reply:nil];
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];
  [WKInterfaceController openParentApplication:@{@"action" : @"onAppRequestsUpdate"} reply:nil];
}

# pragma custom callback actions
// triggered when a navigation button was pressed
- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
  // could pass data here to the next page, no need yet.. perhaps for the title in case of a modal nav because the title from the phone arrives too late (you briefly see the 'cancel' label
  return nil;
}

- (IBAction)buttonAction {
  [self openParent:@{@"action" : self.actionButtonCallback}];
}

// TODO extract and move up (we can do that with all these action callbacks)
- (IBAction)userInputButtonAction {
  NSArray *suggestionsDef = [self.userInputButtonDic valueForKey:@"suggestions"];
  NSMutableArray *suggestions = [NSMutableArray arrayWithCapacity:suggestionsDef.count];
  for (NSInteger i = 0; i < suggestionsDef.count; i++) {
    [suggestions addObject:suggestionsDef[i]];
  }
  long inputMode;
  NSString *inputModeDef = [self.userInputButtonDic valueForKey:@"inputMode"];
  if ([inputModeDef isEqualToString:@"WKTextInputModeAllowAnimatedEmoji"]) {
    inputMode = WKTextInputModeAllowAnimatedEmoji;
  } else  if ([inputModeDef isEqualToString:@"WKTextInputModeAllowEmoji"]) {
    inputMode = WKTextInputModeAllowEmoji;
  } else {
    inputMode = WKTextInputModePlain;
  }
  [self presentTextInputControllerWithSuggestions:suggestions allowedInputMode:inputMode completion:^(NSArray *results) {
    // will be nil if dismissed
    if (results != nil) {
      // results is usually a String, but can be NSData (emoji image), see http://www.fiveminutewatchkit.com/blog/2015/3/15/how-to-get-text-input-from-the-user
      [self openParent:@{@"action" : [self.userInputButtonDic objectForKey:@"callback"], @"params" : results[0]}];
    }
  }];
}

- (IBAction)switch1Action:(BOOL)on {
  if (self.switch1Callback) {
    [self openParent:@{@"action" : self.switch1Callback, @"params" : @(on ? "true" : "false")}];
  }
}

- (IBAction)switch2Action:(BOOL)on {
  if (self.switch2Callback) {
    [self openParent:@{@"action" : self.switch2Callback, @"params" : @(on ? "true" : "false")}];
  }
}

- (IBAction)sliderAction:(float)value {
  NSString *str = [NSString stringWithFormat:@"%.f", value];
  [self.sliderLabel setText:str];
  [self openParent:@{@"action" : self.sliderCallback, @"params" : str}];
}

//- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {}

# pragma notification callbacks
// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
//  int i=0; // eg. "firstButtonAction"
}

// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
//  int i=0;
}

@end