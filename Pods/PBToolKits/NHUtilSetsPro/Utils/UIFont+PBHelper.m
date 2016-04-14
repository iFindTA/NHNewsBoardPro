//
//  UIFont+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "UIFont+PBHelper.h"
#import "UIDevice+PBHelper.h"

@implementation UIFont (PBHelper)

+ (UIFont *)pb_deviceFontForTitle {
    static UIFont *deviceFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (deviceFont == nil) {
            NSString *platform = [UIDevice pb_platform];
            NSInteger fontSize = 13;
            if ([platform isEqualToString:@"iPhone 6"]
                || [platform isEqualToString:@"iPhone 6s"]) {
                fontSize = 15;
            }else if ([platform isEqualToString:@"iPhone 6plus"]
                      || [platform isEqualToString:@"iPhone 6splus"]){
                fontSize = 17;
            }
            deviceFont = [UIFont systemFontOfSize:fontSize];
        }
    });
    return deviceFont;
}

+ (UIFont *)pb_navigationTitle {
    NSDictionary *attributs = [[UINavigationBar appearance] titleTextAttributes];
    UIFont *__tmp_font = [attributs objectForKey:NSFontAttributeName];
    if (__tmp_font == nil) {
        __tmp_font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    }
    return __tmp_font;
}

@end
