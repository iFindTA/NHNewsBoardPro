//
//  PBKits.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#ifndef PBKits_h
#define PBKits_h

#import "UIFont+PBHelper.h"
#import "UIView+PBHelper.h"
#import "UIColor+PBHelper.h"
#import "UIImage+PBHelper.h"
#import "UIDevice+PBHelper.h"

#import "NSArray+PBHelper.h"
#import "NSString+PBHelper.h"
#import "NSBundle+PBHelper.h"
#import "NSDictionary+PBHelper.h"

#import "PBDependency.h"

#endif /* PBKits_h */

/// weak self reference
#define weakify(var) __weak typeof(var) PBWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = PBWeak_##var; \
_Pragma("clang diagnostic pop")
/// screen size
#ifndef PBSCREEN_WIDTH
#define PBSCREEN_WIDTH   ([[UIScreen mainScreen]bounds].size.width)
#endif
#ifndef PBSCREEN_HEIGHT
#define PBSCREEN_HEIGHT  ([[UIScreen mainScreen]bounds].size.height)
#endif
#ifndef PBSCREEN_SCALE
#define PBSCREEN_SCALE  ([UIScreen mainScreen].scale)
#endif
/// system version
#ifndef PBIOS8_ABOVE
#define PBIOS8_ABOVE   ([[UIDevice currentDevice].systemVersion compare:@"8.0"] != NSOrderedDescending)
#endif
/// animation custom duration
#ifndef PBANIMATE_DURATION
#define PBANIMATE_DURATION                        0.25f
#endif
/// main / background thead
#define PBMAIN(block)  if ([NSThread isMainThread]) {\
block();\
}else{\
dispatch_async(dispatch_get_main_queue(),block);\
}
#define PBMAINDelay(x, block) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(x * NSEC_PER_SEC)), dispatch_get_main_queue(), block)
#define PBBACK(block)  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)

#define PBFormat(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

static inline BOOL PBIsEmpty(id _Nullable obj) {
    return obj == nil
    || (NSNull *)obj == [NSNull null]
    || ([obj respondsToSelector:@selector(length)] && [obj length] == 0)
    || ([obj respondsToSelector:@selector(count)] && [obj count] == 0);
}

static inline NSString * _Nonnull PBAvailableString (NSString * _Nullable obj) {
    return PBIsEmpty(obj)?@"":obj;
}

static inline NSNumber * _Nonnull PBAvailableNumber (NSNumber * _Nullable obj) {
    return PBIsEmpty(obj)?[NSNumber numberWithInt:0]:obj;
}

static inline NSArray * _Nonnull PBAvailableArray (NSArray * _Nullable obj) {
    return PBIsEmpty(obj)?[NSArray array]:obj;
}

static inline NSDictionary *_Nonnull PBAvailableDictionary (NSDictionary * _Nullable obj) {
    return PBIsEmpty(obj)?[NSDictionary dictionary]:obj;
}