//
//  UIColor+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "UIColor+PBHelper.h"

@implementation UIColor (PBHelper)

+ (UIColor *)pb_randomColor {
    
    UIColor *color;
    float randomRed   = (arc4random()%255)/255.0f;
    float randomGreen = (arc4random()%255)/255.0f;
    float randomBlue  = (arc4random()%255)/255.0f;
    
    color= [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1.0];
    
    return color;
}

+ (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)pb_colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            red = 0 ; green = 0 ; blue = 0; alpha = 1;
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (PBRGBA)pb_rgbaFromUIColor:(UIColor * _Nonnull)color {
    
    PBRGBA rgba;CGColorRef colorRef = color.CGColor;
    
    CGColorSpaceRef color_space = CGColorGetColorSpace(colorRef);
    CGColorSpaceModel color_space_model = CGColorSpaceGetModel(color_space);
    const CGFloat *color_components = CGColorGetComponents(colorRef);
    size_t color_component_count = CGColorGetNumberOfComponents(colorRef);
    
    switch (color_space_model){
        case kCGColorSpaceModelMonochrome:{
            assert(color_component_count == 2);
            rgba = (PBRGBA){
                .r = color_components[0],
                .g = color_components[0],
                .b = color_components[0],
                .a = color_components[1]
            };
            break;
        }
            
        case kCGColorSpaceModelRGB:{
            assert(color_component_count == 4);
            rgba = (PBRGBA){
                .r = color_components[0],
                .g = color_components[1],
                .b = color_components[2],
                .a = color_components[3]
            };
            break;
        }
            
        default:{
            rgba = (PBRGBA) { 0, 0, 0, 0 };
            break;
        }
    }
    
    return rgba;
}

@end
