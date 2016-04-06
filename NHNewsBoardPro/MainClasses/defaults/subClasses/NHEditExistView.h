//
//  NHEditExistView.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/5.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NHItemChannel;
@interface NHEditExistView : UIView

- (void)enableLongPress:(BOOL)enable;

- (void)reloadData:(NSArray * _Nonnull)datas;

@end

@interface NHItemChannel : UIControl

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIButton *delete;
@property (nonatomic, strong) UIImageView *bgImg;

@property (nonatomic, assign) BOOL isExist;

/**
 *  @brief wethear show delete button
 *
 *  @param show enable
 */
- (void)showDelete:(BOOL)show;

@end