//
//  NHSetsEngine.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/12/20.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHUser;
@interface NHSetsEngine : NSObject

+ (NHSetsEngine *)share;

@property (nonatomic, strong) NHUser *user;

/**
 *  @brief config project for init load
 */
- (void)configure;

/**
 *  @brief get network state
 *
 *  @return true if network fine, otherwise false
 */
- (BOOL)netWorkFine;

/**
 *  @brief whether user was login or not
 *
 *  @return the user's login state
 */
- (BOOL)whetherLogin;

//TODO:临时解决方案
- (NSDictionary *)getInfoForChannel:(nonnull NSString *)channel;
- (NSDateFormatter * _Nonnull)dateFormatter;

@end
