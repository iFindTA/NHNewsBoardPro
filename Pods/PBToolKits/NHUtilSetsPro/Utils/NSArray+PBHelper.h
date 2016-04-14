//
//  NSArray+PBHelper.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PBHelper)

/**
 *	@brief	Judging method
 *
 *	@return	whether the array is empty
 */
- (BOOL)pb_isEmpty NS_DEPRECATED_IOS(2_0, 7_0, "PBIsEmpty()");

@end
