//
//  UIDevice+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "UIDevice+PBHelper.h"
#import "sys/utsname.h"
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <mach/mach.h>
#import <mach-o/arch.h>
#import <net/if.h>
#import <ifaddrs.h>

@implementation UIDevice (PBHelper)

+(NSString *)getSysInfoByName:(char *)typeSpecifier{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;
}

//获取平台信息
+(NSString *)pb_platform{
    NSString *result = [self getSysInfoByName:"hw.machine"];
    NSString *type = @"i386";
    //    NSLog(@"固件版本：%@",result);
    //模拟器
    if ([result isEqualToString:@"i386"]||[result isEqualToString:@"x86_64"])                 type = @"Simulator";
    //iPod
    if ([result isEqualToString:@"iPod3,1"])        type = @"iPod Touch 3";
    if ([result isEqualToString:@"iPod4,1"])        type = @"iPod Touch 4";
    if ([result isEqualToString:@"iPod5,1"])        type = @"iPod Touch 5";
    //iPhone
    if ([result isEqualToString:@"iPhone2,1"])      type = @"iPhone 3Gs";
    if ([result isEqualToString:@"iPhone3,1"])      type = @"iPhone 4";
    if ([result isEqualToString:@"iPhone4,1"])      type = @"iPhone 4s";
    if ([result isEqualToString:@"iPhone5,1"]   ||
        [result isEqualToString:@"iPhone5,2"])      type = @"iPhone 5";
    if ([result isEqualToString:@"iPhone5,3"]   ||
        [result isEqualToString:@"iPhone5,4"])      type = @"iPhone 5c";
    if ([result isEqualToString:@"iPhone6,1"]   ||
        [result isEqualToString:@"iPhone6,2"])      type = @"iPhone 5s";
    if ([result isEqualToString:@"iPhone7,2"])      type = @"iPhone 6";
    if ([result isEqualToString:@"iPhone7,1"])      type = @"iPhone 6plus";
    if ([result isEqualToString:@"iPhone8,1"])      type = @"iPhone 6s";
    if ([result isEqualToString:@"iPhone8,2"])      type = @"iPhone 6splus";
    //iPad
    if ([result isEqualToString:@"iPad2,1"]     ||
        [result isEqualToString:@"iPad2,2"]     ||
        [result isEqualToString:@"iPad2,3"])        type = @"iPad 2";
    if ([result isEqualToString:@"iPad3,1"]     ||
        [result isEqualToString:@"iPad3,2"]     ||
        [result isEqualToString:@"iPad3,3"])        type = @"iPad 3";
    if ([result isEqualToString:@"iPad3,4"]     ||
        [result isEqualToString:@"iPad3,5"]     ||
        [result isEqualToString:@"iPad3,6"])         type = @"iPad 4";
    if ([result isEqualToString:@"iPad2,5"]     ||
        [result isEqualToString:@"iPad2,6"]     ||
        [result isEqualToString:@"iPad2,7"]     ||
        [result isEqualToString:@"iPad4,4"]     ||
        [result isEqualToString:@"iPad4,5"])        type = @"iPad Mini";
    if ([result isEqualToString:@"iPad4,1"]     ||
        [result isEqualToString:@"iPad4,2"]     ||
        [result isEqualToString:@"iPad4,3"]     ||
        [result isEqualToString:@"iPad4,6"])        type = @"iPad Air";
    
    
    return type;
}

@end
