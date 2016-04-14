//
//  NSBundle+PBHelper.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (PBHelper)

/**
 *	@brief	get build version
 *
 *	@return	return the build version
 */
+ (NSString * _Nonnull)pb_buildVersion;

/**
 *	@brief	get the release version
 *
 *	@return	return the release version
 */
+ (NSString * _Nonnull)pb_releaseVersion;

/**
 *	@brief	get app's display name
 *
 *	@return	return app's display name
 */
+ (NSString * _Nonnull)pb_displayName;

@end
