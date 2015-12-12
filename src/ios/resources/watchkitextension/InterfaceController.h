#import "ParentInterfaceController.h"

@interface InterfaceController : ParentInterfaceController

@property (nonatomic, strong) MMWormhole *navwormhole;

#if defined (TARGET_OS_WATCH) && TARGET_OS_WATCH >= 2
@property (nonatomic, strong) MMWormholeSession *listeningWormhole;
#endif

@end
