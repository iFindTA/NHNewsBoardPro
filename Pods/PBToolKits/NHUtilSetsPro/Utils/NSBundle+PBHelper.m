//
//  NSBundle+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NSBundle+PBHelper.h"
#import "PBKits.h"
#import "NSDictionary+PBHelper.h"

@implementation NSBundle (PBHelper)

+ (NSString *)pb_buildVersion {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo pb_stringForKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)pb_releaseVersion {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo pb_stringForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)pb_displayName {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *m_name = [bundleInfo pb_stringForKey:@"CFBundleDisplayName"];
    if (PBIsEmpty(m_name)) {
        m_name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }
    return m_name;
}

@end
