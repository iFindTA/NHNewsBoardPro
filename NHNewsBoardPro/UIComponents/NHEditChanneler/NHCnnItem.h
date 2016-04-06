//
//  NHCnnItem.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHCnnItem : UILabel

@property (nonatomic, strong, nullable) UIButton *delBtn;
@property (nonatomic, strong, nullable) UIImageView *bgImg;

@property (nonatomic, assign) BOOL isExist;

/**
 *  @brief wethear show delete button
 *
 *  @param show enable
 */
- (void)showDelete:(BOOL)show;

@end
