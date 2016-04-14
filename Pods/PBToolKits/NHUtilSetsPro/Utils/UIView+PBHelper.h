//
//  UIView+PBHelper.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

struct CGBWidthColor {
    CGFloat width;
    unsigned long color;
};
typedef struct CGBWidthColor CGBWidthColor;

struct CGBCornerColor {
    CGFloat radius;
    unsigned long color;
};
typedef struct CGBCornerColor CGBCornerColor;

@interface UIView (PBHelper)

/**
 *  @brief add round corner
 *
 *  @param corner descript
 */
- (void)pb_addRound:(CGBCornerColor)corner;

/**
 *  @brief add round corner
 *
 *  @param corner descript
 *  @param border descript
 */
- (void)pb_addRound:(CGBCornerColor)corner withBorder:(CGBWidthColor)border;

@end
