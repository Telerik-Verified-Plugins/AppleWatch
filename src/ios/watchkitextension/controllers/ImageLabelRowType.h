#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ImageLabelRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceImage* image;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* label;

@end
