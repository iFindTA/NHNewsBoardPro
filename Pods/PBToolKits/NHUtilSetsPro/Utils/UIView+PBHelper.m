//
//  UIView+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "UIView+PBHelper.h"
#import "UIImage+PBHelper.h"

@implementation UIView (PBHelper)

- (void)pb_addRound:(CGBCornerColor)corner {
    
    UIColor *bgColor = [UIColor colorWithRed:((float)((corner.color & 0xFF0000) >> 16))/255.0 \
                                       green:((float)((corner.color & 0x00FF00) >>  8))/255.0 \
                                        blue:((float)((corner.color & 0x0000FF) >>  0))/255.0 \
                                       alpha:1.0];
    UIImage *bgImg = [UIImage pb_imageWithColor:bgColor];
    CGSize size = self.bounds.size;
    UIImage *dstImg = [bgImg pb_drawRoundCornerWithRadius:corner.radius toSize:size];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:dstImg];
    [self insertSubview:imgView atIndex:0];
}

- (void)pb_addRound:(CGBCornerColor)corner withBorder:(CGBWidthColor)border {
    UIColor *bgColor = [UIColor colorWithRed:((float)((corner.color & 0xFF0000) >> 16))/255.0 \
                                       green:((float)((corner.color & 0x00FF00) >>  8))/255.0 \
                                        blue:((float)((corner.color & 0x0000FF) >>  0))/255.0 \
                                       alpha:1.0];
    UIColor *borderColor = [UIColor colorWithRed:((float)((border.color & 0xFF0000) >> 16))/255.0 \
                                           green:((float)((border.color & 0x00FF00) >>  8))/255.0 \
                                            blue:((float)((border.color & 0x0000FF) >>  0))/255.0 \
                                           alpha:1.0];
    UIImage *bgImg = [UIImage pb_imageWithColor:bgColor];
    CGSize size = self.bounds.size;
    UIImage *dstImg = [bgImg pb_drawRoundCornerWithRadius:corner.radius toSize:size];
    //dstImg = [dstImg pb_roundImageWithBorderWidth:border.width withColor:borderColor];
    dstImg = [dstImg pb_roundCornerWithRadius:corner.radius withBorderWidth:border.width withBorderColor:borderColor];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:dstImg];
    [self insertSubview:imgView atIndex:0];
}

@end
