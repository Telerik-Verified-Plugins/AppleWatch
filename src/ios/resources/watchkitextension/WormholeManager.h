//
//  WormholeManager.h
//  MMWormhole
//
//  Created by Toma Popov on 12/29/15.
//  Copyright © 2015 Conrad Stoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMWormholeUmbrella.h"

@interface WormholeManager : NSObject

+ (instancetype)sharedInstance;

- (void)listenForMessageWithIdentifier:(NSString *)identifier
                              listener:(void (^)(id messageObject))listener;

- (void)passMessageObject:(id <NSCoding>)messageObject
               identifier:(NSString *)identifier;

@property (nonatomic, strong, readonly) MMWormhole *wormhole;
@property (nonatomic, strong, readonly) MMWormholeSession *listeningWormhole;

@end
