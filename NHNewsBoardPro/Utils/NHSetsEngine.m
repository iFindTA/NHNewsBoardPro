//
//  NHSetsEngine.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/12/20.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHSetsEngine.h"
#import "NHModels.h"

@interface NHSetsEngine ()

@property (nonatomic, strong) NSArray *newsURIs;

@end

static NHSetsEngine *instance = nil;

@implementation NHSetsEngine

+ (NHSetsEngine *)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)configure {
    
    // load urls for news channels from local caches, don't from net!
    _newsURIs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewsURLs" ofType:@"plist"]];
    
    // load recent login user
}

- (BOOL)netWorkFine {
    return true;
}

- (BOOL)whetherLogin {
    return false;
}

- (NSDictionary *)getInfoForChannel:(nonnull NSString *)channel {
    __block NSDictionary *tmp;
    [_newsURIs enumerateObjectsUsingBlock:^( NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"title"] isEqualToString:channel]) {
            tmp = [NSDictionary dictionaryWithDictionary:obj];
            *stop = true;
        }
    }];
    return tmp;
}

- (NSDateFormatter * _Nonnull)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeZone* localzone = [NSTimeZone localTimeZone];
        NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.timeZone = GTMzone;
    });
    return formatter;
}

@end
