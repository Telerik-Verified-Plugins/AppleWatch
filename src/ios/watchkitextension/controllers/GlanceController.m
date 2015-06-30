//
//  GlanceController.m
//  HelloCordova WatchKit Extension
//
//  Created by Eddy Verbruggen on 17/06/15.
//
//

#import "GlanceController.h"
#import "WatchKitUIHelper.h"

#import "MMWormhole.h"


@interface GlanceController()

@property (nonatomic, strong) MMWormhole *wormhole;
//@property (nonatomic, strong) NSString *lastmsg;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *header;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *message;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *image;
// TODO map (landkaartje met posities)

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  // hide everything initially, so when no glance was activated, the glance is empty
  [self.header setHidden:YES];
  [self.message setHidden:YES];
  [self.image setHidden:YES];
  
  self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.nl.xservices.applewatch"
                                                       optionalDirectory:@"wormhole"];

  [self.wormhole listenForMessageWithIdentifier:@"fromjstowatchglance" listener:^(id messageObject) {
    [self buildUI:messageObject];
  }];
}

- (void) buildUI:(NSDictionary*)messageObject {
  [WatchKitUIHelper setLabel:self.header  fromDic:[messageObject valueForKey:@"header"]];
  [WatchKitUIHelper setLabel:self.message fromDic:[messageObject valueForKey:@"message"]];
  [WatchKitUIHelper setImage:self.image   fromDic:[messageObject valueForKey:@"image"]];
}

- (void)willActivate {
  // This method is called when watch view controller is about to be visible to the user
  [super willActivate];

  [WKInterfaceController openParentApplication:@{@"action" : @"onGlanceRequestsUpdate"} reply:nil];
}

- (void)didDeactivate {
  // This method is called when watch view controller is no longer visible
  [super didDeactivate];
}

@end