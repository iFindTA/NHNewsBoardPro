//
//  NHCnnItem.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHCnnItem : UILabel<NSCopying>

@property (nonatomic, strong, nullable) UIButton *delBtn;
@property (nonatomic, strong, nullable) UIImageView *bgImg;
//@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
//@property (nonatomic, strong) UIPanGestureRecognizer *dragGesture;

@property (nonatomic, assign) BOOL isExist;

/**
 *  @brief wethear show delete button
 *
 *  @param show enable
 */
- (void)showDelete:(BOOL)show;

@end


@interface NHMoreItem : UIButton

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