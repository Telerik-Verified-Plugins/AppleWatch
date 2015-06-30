//
//  WatchKitUIHelper.m
//  HelloCordova
//
//  Created by Eddy Verbruggen on 26/06/15.
//
//

#import <Foundation/Foundation.h>
#import "WatchKitUIHelper.h"
#import "ImageLabelRowType.h"
#import "TwoColumnsRowType.h"

@implementation WatchKitUIHelper

- (void)awakeWithContext:(id)context {
}

+ (void) setLabel:(WKInterfaceLabel*)label fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [label setHidden:YES];
  } else {
    NSString *value = [dic valueForKey:@"value"];
    NSDictionary *fontdef = [dic valueForKey:@"font"];
    NSDictionary *attr = nil;
    if (fontdef != nil) {
      NSString *fontface = [fontdef valueForKey:@"face"];
      NSNumber *fontsize = [fontdef valueForKey:@"size"];
      if (fontface == nil && fontsize != nil) {
        fontface = @"HelveticaNeue-Bold"; // default, TODO: set defaults in JS
      }
      int fsize = 11;
      if (fontsize != nil) {
        fsize = fontsize.intValue;
      }
      UIFont *font = [UIFont fontWithName:fontface size:fsize];
      if (font != nil) {
        attr = @{NSFontAttributeName: font};
      }
    }
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:value attributes:attr];
    [label setAttributedText:attrString];
    
    [label setHidden:NO];
    
    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [label setTextColor:theColor];
    }
  }
}

+ (void) setImage:(WKInterfaceImage*)image fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [image setHidden:YES];
  } else {
    [image setImageData:[dic valueForKey:@"src"]];
    
    NSNumber *width = [dic valueForKey:@"width"];
    [image setWidth:width == nil ? 0 /* natural size */ : width.doubleValue];
    
    NSNumber *height = [dic valueForKey:@"height"];
    [image setHeight:height == nil ? 0 /* natural size */ : height.doubleValue];
    
    [self setAlpha:image fromDic:dic];

    [image setHidden:NO];
  }
}

+ (void) setButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [button setHidden:YES];
  } else {
    [button setTitle:[dic valueForKey:@"title"]];
    [self setAlpha:button fromDic:dic];
    
    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [button setBackgroundColor:theColor];
    }
    [button setHidden:NO];
  }
}

+ (NSString*) setButtonWithCallback:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  [self setButton:button fromDic:dic];
  return dic == nil ? nil : [dic valueForKey:@"callback"];
}

+ (NSDictionary*) setUserInputButton:(WKInterfaceButton*)button fromDic:(NSDictionary*)dic {
  [self setButton:button fromDic:dic];
  return dic;
}

+ (NSString*) setSwitch:(WKInterfaceSwitch*)switch1 fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [switch1 setHidden:YES];
    return nil;
  } else {
    [switch1 setTitle:[dic valueForKey:@"title"]];
    NSNumber *on = (NSNumber *)[dic objectForKey: @"on"];
    [switch1 setOn:[on boolValue]];

    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [switch1 setColor:theColor];
    }
    [switch1 setHidden:NO];
    return [dic valueForKey:@"callback"];
  }
}

+ (NSString*) setSlider:(WKInterfaceSlider*)slider withLabel:(WKInterfaceLabel*)label inGroup:(WKInterfaceGroup*)group fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [group setHidden:YES];
    [slider setHidden:YES];
    [label setHidden:YES];
    return nil;
  } else {
    [self setAlpha:group fromDic:dic];

    NSNumber* value = [dic objectForKey: @"value"];
    [slider setValue:[value floatValue]];
    
    NSNumber* steps = [dic objectForKey: @"steps"];
    [slider setNumberOfSteps:[steps integerValue]];
    
    NSString *hexColor = [dic valueForKey:@"color"];
    if (hexColor != nil) {
      UIColor *theColor = [self colorFromHexString:hexColor];
      [slider setColor:theColor];
    }

    NSNumber *hideValue = (NSNumber *)[dic objectForKey: @"hideValue"];
    if (![hideValue boolValue]) {
      [label setHidden:NO];
      [label setText:[NSString stringWithFormat:@"%.f", [value floatValue]]];
    }

    [group setHidden:NO];
    [slider setHidden:NO];
    return [dic valueForKey:@"callback"];
  }
}

+ (void) setTable:(WKInterfaceTable*)table fromDic:(NSDictionary*)dic {
  if (dic == nil) {
    [table setHidden:YES];
  } else {
    [self setAlpha:table fromDic:dic];
    NSMutableArray *rowTypes = [NSMutableArray arrayWithCapacity:2];
    NSArray *rows = [dic valueForKey:@"rows"];
    for (NSInteger i = 0; i < rows.count; i++) {
      NSDictionary* rowDef = rows[i];
      NSString* rowType = [rowDef objectForKey:@"type"];
      [rowTypes addObject:rowType];
    }
    [table setRowTypes:rowTypes];

    for (NSInteger i = 0; i < rows.count; i++) {
      NSDictionary* rowDef = rows[i];

      if ([rowTypes[i] isEqualToString:@"ImageLabelRowType"]) {
        ImageLabelRowType* row = [table rowControllerAtIndex:i];
        [row.label setText:[rowDef objectForKey:@"label"]];
      }
      
      // See this for clickable rows: http://blog.numerousapp.com/2014/12/09/watch-dev-2.html
      if ([rowTypes[i] isEqualToString:@"TwoColumnsRowType"]) {
        TwoColumnsRowType* row = [table rowControllerAtIndex:i];
        [self setLabel:row.col1label fromDic:[rowDef objectForKey:@"col1label"]];
        [self setLabel:row.col2label fromDic:[rowDef objectForKey:@"col2label"]];
      }
    }
    
    [table setHidden:NO];
  }
}

// TODO WKInterfaceObject has more common properties
+ (void) setAlpha:(WKInterfaceObject*) obj fromDic:(NSDictionary*)dic {
  NSNumber *alpha = [dic valueForKey:@"alpha"];
  [obj setAlpha:alpha == nil ? 1 /* full opaque (solid) */ : alpha.doubleValue];
}

// Assumes input like "#00FF00" (#RRGGBB)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
  unsigned rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end