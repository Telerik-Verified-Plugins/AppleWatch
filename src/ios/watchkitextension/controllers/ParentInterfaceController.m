#import "ParentInterfaceController.h"
#import "WatchKitUIHelper.h"

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

- (void) hideAllWidgets {
  [self.header setHidden:YES];
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
    // TODO if items can not be found, nslog it - same for other expected values as well
    NSArray *items = [contextMenuItems valueForKey:@"items"];
    self.contextMenuButton1Callback = [self addContextMenuItem:items forItemAtIndex:0 performSelector:@selector(contextMenuButton1Action)];
    self.contextMenuButton2Callback = [self addContextMenuItem:items forItemAtIndex:1 performSelector:@selector(contextMenuButton2Action)];
    self.contextMenuButton3Callback = [self addContextMenuItem:items forItemAtIndex:2 performSelector:@selector(contextMenuButton3Action)];
    self.contextMenuButton4Callback = [self addContextMenuItem:items forItemAtIndex:3 performSelector:@selector(contextMenuButton4Action)];
  }

  // TODO rename to label1, etc
  [WatchKitUIHelper setLabel:self.header fromDic:[messageObject valueForKey:@"header"]];
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
  [self openParent:@{@"action" : self.contextMenuButton1Callback}];
}

- (IBAction)contextMenuButton2Action {
  [self openParent:@{@"action" : self.contextMenuButton2Callback}];
}

- (IBAction)contextMenuButton3Action {
  [self openParent:@{@"action" : self.contextMenuButton3Callback}];
}

- (IBAction)contextMenuButton4Action {
  [self openParent:@{@"action" : self.contextMenuButton4Callback}];
}

- (void) openParent:(NSDictionary*)dic {
  [WKInterfaceController openParentApplication:dic reply:nil];
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
  // be a good citizen.. btw, doing this here seems ugly but it's better than forgetting to do it in a subclass and leaving a mess
  if (![@"main" isEqualToString:[self getPageID]]) {
    NSString *wormholeIdentifier = [@"fromjstowatchapp-" stringByAppendingString:[self getPageID]];
    [self.wormhole stopListeningForMessageWithIdentifier:wormholeIdentifier];
  }
}

@end