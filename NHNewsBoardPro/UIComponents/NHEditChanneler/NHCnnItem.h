//
//  NHCnnItem.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHCnnItem : UIView

@property (nonatomic, copy) NSString * _Nonnull title;
@property (nonatomic, strong) UIColor * _Nonnull titleColor;
@property (nonatomic, strong) UIFont * _Nonnull font;
@property (nonatomic, assign) BOOL isExist;

/**
 *  @brief wethear show delete button
 *
 *  @param show enable
 */
- (void)showDelete:(BOOL)show;

/**
 *  @brief wethear hidden bg image
 *
 *  @param hidden enable
 */
- (void)hiddenBgImg:(BOOL)hidden;

/**
 *  @brief 添加删除按钮事件
 *
 *  @param target
 *  @param action
 */
- (void)addTarget:(id _Nullable)target forAction:(SEL _Nullable)action;

@end

@interface NHOtherCnnItem : UIView

@property (nonatomic, copy, nonnull) NSString *title;

/**
 *  @brief 添加事件
 *
 *  @param target
 *  @param action
 */
- (void)addTarget:(id _Nullable)target forAction:(SEL _Nullable)action;

/**
 *  @brief 隐藏标题
 *
 *  @param hidden 是否隐藏
 */
- (void)hiddenTitle:(BOOL)hidden;

@end