//
//  NHPreventPager.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NHPreventStateNone              =  1 << 0,
    NHPreventStatePreLoaded         =  1 << 1,
    NHPreventStateWaitForShow       =  1 << 2,
    NHPreventStateWillShow          =  1 << 3,
    NHPreventStateShowing           =  1 << 4,
    NHPreventStateLowPower          =  1 << 5
}NHPreventState;

@interface NHPreventPager : UIView

/**
 *  @brief 当前page‘s 栏目名称
 */
@property (nonatomic, copy, readonly) NSString * _Nonnull cnn;

/**
 *  @brief 页码数
 */
@property (nonatomic, assign) NSUInteger pageIdx;

/**
 *  @brief 最后显示日期
 */
@property (nonatomic, strong, nullable, readonly) NSDate * showDate;

/**
 *  @brief 当前状态
 */
@property (nonatomic, assign, readonly) NHPreventState state;

- (id _Nonnull)initWithFrame:(CGRect)frame withCnn:(NSString * _Nonnull)cnn;

/**
 *  @brief 预加载
 */
- (void)preventLoad NS_REQUIRES_SUPER;

/**
 *  @brief view将要显示(加载本地数据、准备状态)
 */
- (void)viewWillAppear NS_REQUIRES_SUPER;

/**
 *  @brief view已经显示（是否需要刷新数据在此判断）
 */
- (void)viewDidAppear NS_REQUIRES_SUPER;

/**
 *  @brief 重置为低内存状态
 */
- (void)reset2LowwerPowerState NS_REQUIRES_SUPER;

@end
