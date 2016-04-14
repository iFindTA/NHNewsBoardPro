//
//  UIFont+PBHelper.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (PBHelper)

/**
 *	@brief	system's title font
 *
 *	@return	return the title's font
 */
+ (UIFont * _Nonnull)pb_deviceFontForTitle;

/**
 *	@brief	navigation title
 *
 *	@return	the title default font
 */
+ (UIFont * _Nonnull)pb_navigationTitle;

@end
