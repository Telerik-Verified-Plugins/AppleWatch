#import "ParentInterfaceController.h"

@implementation ParentInterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  // hide everything initially
  [self hideAllWidgets];

  // Initialize the wormhole
  // TODO appgroupID must be dynamic
  self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.nl.xservices.applewatch"
                                                       optionalDirectory:@"wormhole"];
  
  NSString *wormholeIdentifier = [@"fromjstowatchapp-" stringByAppendingString:[self getPageID]];
  [self.wormhole listenForMessageWithIdentifier:wormholeIdentifier listener:^(id messageObject) {
    [self buildUI:messageObject];
  }];
}

// poor man's abstract method implementation
- (NSString*) getPageID {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (id)contextForSegueWithIdentifier:(NSString*)segueIdentifier {
  // here we can pass data to the next page's awakeWithContext method
  return nil;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  // TODO we probably want to:
  // a) nav to the detailpage here, or
  // b) send the selected item back to JS, or
  // c) both
}

- (void) hideAllWidgets {
  [self.label1 setHidden:YES];
  [self.label2 setHidden:YES];
  [self.table setHidden:YES];
  [self.image setHidden:YES];
  [self.switch1 setHidden:YES];
  [self.switch2 setHidden:YES];
  [self.map setHidden:YES];
  [self.sliderGroup setHidden:YES];
  [self.slider setHidden:YES];
  [self.sliderLabel setHidden:YES];
  [self.userInputButton setHidden:YES];
  [self.actionButton setHidden:YES];
  [self.pushNavButton setHidden:YES];
  [self.modalNavButton setHidden:YES];
}

- (void) buildUI:(NSDictionary*)messageObject {
  //  [WatchKitUIHelper setLabel:self.message fromDic:[messageObject valueForKey:@"message"]];

  // the page title, in case we're not showing the root page
  if ([messageObject valueForKey:@"title"] != nil) {
    [self setTitle:[messageObject valueForKey:@"title"]];
  } else {
    [self setTitle:nil];
  }

  if ([messageObject valueForKey:@"contextMenu"] != nil) {
    [self clearAllMenuItems];
    NSDictionary *contextMenuItems = [messageObject valueForKey:@"contextMenu"];
    // TODO if items can not be found, log it - same for other expected values
    NSArray *items = [contextMenuItems valueForKey:@"items"];
    self.contextMenuButton1Callback = [self addContextMenuItem:items forItemAtIndex:0 performSelector:@selector(contextMenuButton1Action)];
    self.contextMenuButton2Callback = [self addContextMenuItem:items forItemAtIndex:1 performSelector:@selector(contextMenuButton2Action)];
    self.contextMenuButton3Callback = [self addContextMenuItem:items forItemAtIndex:2 performSelector:@selector(contextMenuButton3Action)];
    self.contextMenuButton4Callback = [self addContextMenuItem:items forItemAtIndex:3 performSelector:@selector(contextMenuButton4Action)];
  }

  [WatchKitUIHelper setGroup:self.wrapper fromDic:[messageObject valueForKey:@"group"]];
  [WatchKitUIHelper setLabel:self.label1 fromDic:[messageObject valueForKey:@"label1"]];
  [WatchKitUIHelper setLabel:self.label2 fromDic:[messageObject valueForKey:@"label2"]];
  [WatchKitUIHelper setImage:self.image fromDic:[messageObject valueForKey:@"image"]];
  [WatchKitUIHelper setTable:self.table fromDic:[messageObject valueForKey:@"table"]];
  [WatchKitUIHelper setMap:self.map fromDic:[messageObject valueForKey:@"map"]];
  self.switch1Callback = [WatchKitUIHelper setSwitch:self.switch1 fromDic:[messageObject valueForKey:@"switch1"]];
  self.switch2Callback = [WatchKitUIHelper setSwitch:self.switch2 fromDic:[messageObject valueForKey:@"switch2"]];
  self.sliderCallback = [WatchKitUIHelper setSlider:self.slider withLabel:self.sliderLabel inGroup:self.sliderGroup fromDic:[messageObject valueForKey:@"slider"]];
  self.pushNavButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.pushNavButton fromDic:[messageObject valueForKey:@"pushNavButton"]];
  self.modalNavButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.modalNavButton fromDic:[messageObject valueForKey:@"modalNavButton"]];
  self.actionButtonCallback = [WatchKitUIHelper setButtonWithCallback:self.actionButton fromDic:[messageObject valueForKey:@"actionButton"]];
  self.userInputButtonDic = [WatchKitUIHelper setUserInputButton:self.userInputButton fromDic:[messageObject valueForKey:@"userInputButton"]];
}

- (NSString*) addContextMenuItem:(NSArray*)items forItemAtIndex:(int)index performSelector:(SEL)selector {
  if (items.count <= index) {
    return nil;
  }
  NSDictionary* item = [items objectAtIndex:index];
  WKMenuItemIcon icon = [WatchKitUIHelper WKMenuItemIconFromString:[item valueForKey:@"iconNamed"]];
  [self addMenuItemWithItemIcon:icon title:[item valueForKey:@"title"] action:selector];
  return [item valueForKey:@"callback"];
}

- (IBAction)contextMenuButton1Action {
  [WatchKitHelper openParent:self.contextMenuButton1Callback];
}

- (IBAction)contextMenuButton2Action {
  [WatchKitHelper openParent:self.contextMenuButton2Callback];
}

- (IBAction)contextMenuButton3Action {
  [WatchKitHelper openParent:self.contextMenuButton3Callback];
}

- (IBAction)contextMenuButton4Action {
  [WatchKitHelper openParent:self.contextMenuButton4Callback];
}

- (IBAction)switch1Action:(BOOL)on {
  if (self.switch1Callback) {
    [WatchKitHelper openParent:self.switch1Callback withParams:@(on ? "true" : "false")];
  } else {
    [WatchKitHelper logError:@"No callback specified for switch1"];
  }
}

- (IBAction)switch2Action:(BOOL)on {
  if (self.switch2Callback) {
    [WatchKitHelper openParent:self.switch2Callback withParams:@(on ? "true" : "false")];
  }
}

- (IBAction)sliderAction:(float)value {
  NSString *str = [NSString stringWithFormat:@"%.f", value];
  [self.sliderLabel setText:str];
  [WatchKitHelper openParent:self.sliderCallback withParams:str];
}

- (IBAction)buttonAction {
  [WatchKitHelper openParent:self.actionButtonCallback];
}

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
      [WatchKitHelper openParent:[self.userInputButtonDic objectForKey:@"callback"] withParams:results[0]];
    }
  }];
}

// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
  //  int i=0; // eg. "firstButtonAction"
}

// when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
  //  int i=0;
}

// This method is called when watch view controller is about to be visible to the user
- (void)willActivate {
  [super willActivate];
  [WatchKitHelper openParent:[@"applewatch.callback.onLoad" stringByAppendingString:[self getPageID]]];
}

// This method is called when watch view controller is no longer visible
- (void)didDeactivate {
  [super didDeactivate];
  // be a good citizen.. btw, doing this here seems ugly but it's better than forgetting to do it in a subclass and leaving a mess
  if (![@"main" isEqualToString:[self getPageID]]) {
    NSString *wormholeIdentifier = [@"fromjstowatchapp-" stringByAppendingString:[self getPageID]];
    [self.wormhole stopListeningForMessageWithIdentifier:wormholeIdentifier];
  }
}

@end