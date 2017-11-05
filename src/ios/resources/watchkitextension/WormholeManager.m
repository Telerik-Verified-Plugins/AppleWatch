//
//  WormholeManager.m
//  MMWormhole
//
//  Created by Toma Popov on 12/29/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

#import "WormholeManager.h"

@interface WormholeManager ()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) MMWormholeSession *listeningWormhole;

@end

@implementation WormholeManager

//MARK: Constructors

static WormholeManager *_sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance) {
            _sharedInstance = WormholeManager.new;
            // Initialize the wormhole
            _sharedInstance.listeningWormhole = MMWormholeSession.sharedListeningSession;
            // Make sure we are activating the listening wormhole so that it will receive new messages from
            // the WatchConnectivity framework.
            [_sharedInstance.listeningWormhole activateSessionListening];
            _sharedInstance.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:_sharedInstance.getAppGroup
                                                                            optionalDirectory:@"wormhole"
                                                                               transitingType:MMWormholeTransitingTypeSessionMessage];
            [_sharedInstance.listeningWormhole clearAllMessageContents];
            [_sharedInstance.wormhole clearAllMessageContents];
            [_sharedInstance.wormhole.wormholeMessenger deleteContentForIdentifier:@"fromjstowatchapp-navigation"];
            [_sharedInstance.wormhole.wormholeMessenger deleteContentForAllMessages];
            
            [[NSNotificationCenter defaultCenter] removeObserver:_sharedInstance.listeningWormhole];
            
            CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(_sharedInstance.listeningWormhole));

            [[NSNotificationCenter defaultCenter] removeObserver:_sharedInstance.wormhole];
            
            CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(_sharedInstance.wormhole));

        }
    });
    
    return _sharedInstance;
}

//MARK: Public methods

- (void)listenForMessageWithIdentifier:(NSString *)identifier
                              listener:(void (^)(id messageObject))listener {
    [_sharedInstance.listeningWormhole listenForMessageWithIdentifier:identifier listener:listener];
}

- (void)passMessageObject:(id <NSCoding>)messageObject
               identifier:(NSString *)identifier {
    [_sharedInstance.wormhole passMessageObject:messageObject identifier:identifier];
}

//MARK: Utilities

- (NSString*)getAppGroup {
    NSString *appGroup = [NSString stringWithFormat:@"group.%@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"]];
    return [appGroup stringByReplacingOccurrencesOfString:@".watchkitapp.watchkitextension" withString:@""];
}

@end
