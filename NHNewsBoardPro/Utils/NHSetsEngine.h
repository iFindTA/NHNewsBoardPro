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

+ (NHSetsEngine * _Nonnull)share;

@property (nonatomic, strong) NHUser * _Nullable user;

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
- (NSDictionary * _Nonnull)getInfoForChannel:(nonnull NSString *)channel;

/**
 *  @brief 单例化日期格式器
 *
 *  @return 日期格式器实例
 */
- (NSDateFormatter * _Nonnull)dateFormatter;

@end
