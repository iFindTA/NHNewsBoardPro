//
//  NSDictionary+PBHelper.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PBHelper)

/**
 *	@brief	Judging method
 *
 *	@return	whether the map is empty
 */
- (BOOL)pb_isEmpty NS_DEPRECATED_IOS(2_0, 7_0, "PBIsEmpty()");

///////////////// NSDictionary Safe Accessors ///////////////
/// home page: https://github.com/allenhsu/NSDictionary-Accessors

- (BOOL)isArrayForKey:(NSString * _Nonnull )key;
- (BOOL)isDictionaryForKey:(NSString * _Nonnull )key;
- (BOOL)isStringForKey:(NSString * _Nonnull )key;
- (BOOL)isNumberForKey:(NSString * _Nonnull )key;

- (NSArray * _Nullable )pb_arrayForKey:(NSString * _Nonnull )key;
- (NSDictionary * _Nullable )pb_dictionaryForKey:(NSString * _Nonnull )key;
- (NSString * _Nullable )pb_stringForKey:(NSString * _Nonnull )key;
- (NSNumber * _Nullable )pb_numberForKey:(NSString * _Nonnull )key;
- (double)pb_doubleForKey:(NSString * _Nonnull )key;
- (float)pb_floatForKey:(NSString * _Nonnull )key;
- (int)pb_intForKey:(NSString * _Nonnull )key;
- (unsigned int)pb_unsignedIntForKey:(NSString * _Nonnull )key;
- (NSInteger)pb_integerForKey:(NSString * _Nonnull )key;
- (NSUInteger)pb_unsignedIntegerForKey:(NSString * _Nonnull )key;
- (long long)pb_longLongForKey:(NSString * _Nonnull )key;
- (unsigned long long)pb_unsignedLongLongForKey:(NSString * _Nonnull )key;
- (BOOL)pb_boolForKey:(NSString * _Nonnull )key;
////////////////// NSDictionary Safe Accessors ///////////////

@end
