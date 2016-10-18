//
//  UIColor+CustomColors.m
//  Chillin
//
//  Created by Viny on 10/05/2016.
//

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

// Wall weight graph background + Calendar future medication to take point color
+ (UIColor *)colorChillin {
    return [UIColor colorWithRed:79.0/255.0 green:145.0/255.0f blue:254.0/255.0f alpha:1.0f];
}

+ (UIColor *)colorBlueButton {
    return [UIColor colorWithRed:0.0/255.0 green:163.0/255.0 blue:236.0/255.0f alpha:1.0];
}

+ (UIColor *)colorHeaderLabel {
    return [UIColor colorWithRed:138.0/255.0 green:142.0/255.0 blue:145.0/255.0f alpha:1.0];
}

+ (UIColor *)colorHeaderViewBackground {
    return [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0f alpha:1.0];
}

+ (UIColor *)colorLabelAndButtonCell {
    return [UIColor colorWithRed:0/255.f green:163/255.f blue:241/255.f alpha:1.f];
}

+ (UIColor *)colorBorder {
    return [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0f alpha:1.0];
}

+ (UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
