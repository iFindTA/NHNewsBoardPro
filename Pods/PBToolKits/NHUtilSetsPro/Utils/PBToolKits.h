//
//  PBToolKits.h
//  NHUtilSetsPro
//
//  Created by hu jiaju on 15/11/14.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

/// weak self reference
#define weakify(var) __weak typeof(var) PBWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = PBWeak_##var; \
_Pragma("clang diagnostic pop")
/// screen size
#ifndef PBSCREEN_WIDTH
#define PBSCREEN_WIDTH   ([[UIScreen mainScreen]bounds].size.width)
#endif
#ifndef PBSCREEN_HEIGHT
#define PBSCREEN_HEIGHT  ([[UIScreen mainScreen]bounds].size.height)
#endif
/// system version
#ifndef PBIOS8_ABOVE
#define PBIOS8_ABOVE   ([[UIDevice currentDevice].systemVersion compare:@"8.0"] != NSOrderedDescending)
#endif
/// animation custom duration
#ifndef PBANIMATE_DURATION
#define PBANIMATE_DURATION                        0.25f
#endif
/// main / background thead
#define PBMAIN(block)  if ([NSThread isMainThread]) {\
block();\
}else{\
dispatch_async(dispatch_get_main_queue(),block);\
}
#define PBMAINDelay(x, block) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(x * NSEC_PER_SEC)), dispatch_get_main_queue(), block)
#define PBBACK(block)  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)

#define PBFormat(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

static inline BOOL PBIsEmpty(id _Nullable obj) {
    return obj == nil
    || (NSNull *)obj == [NSNull null]
    || ([obj respondsToSelector:@selector(length)] && [obj length] == 0)
    || ([obj respondsToSelector:@selector(count)] && [obj count] == 0);
}

static inline NSString * _Nonnull PBAvailableString (NSString * _Nullable obj) {
    return PBIsEmpty(obj)?@"":obj;
}

static inline NSNumber * _Nonnull PBAvailableNumber (NSNumber * _Nullable obj) {
    return PBIsEmpty(obj)?[NSNumber numberWithInt:0]:obj;
}

static inline NSArray * _Nonnull PBAvailableArray (NSArray * _Nullable obj) {
    return PBIsEmpty(obj)?[NSArray array]:obj;
}

static inline NSDictionary *_Nonnull PBAvailableDictionary (NSDictionary * _Nullable obj) {
    return PBIsEmpty(obj)?[NSDictionary dictionary]:obj;
}

@interface PBToolKits : NSObject

@end

@interface NSArray (PBHelper)

/**
 *	@brief	Judging method
 *
 *	@return	whether the array is empty
 */
- (BOOL)pb_isEmpty NS_DEPRECATED_IOS(2_0, 7_0, "PBIsEmpty()");

@end

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

@interface NSString (PBHelper)

/**
 *	@brief	Judging method
 *
 *	@return	whether only contain numbers
 */
- (BOOL)pb_isOnlyNumbers;

/**
 *	@brief	Judging method
 *
 *	@return	wheter only contain letters
 */
- (BOOL)pb_isOnlyLetters;

/**
 *	@brief	Judging method
 *
 *	@return	whether only contain number or letter
 */
- (BOOL)pb_isNumberOrLetter;

/**
 *	@brief	caculate string's size
 *
 *	@param 	font 	string's font
 *	@param 	width 	string's width
 *
 *	@return	the adjust size of string
 */
- (CGSize)pb_sizeThatFitsWithFont:(UIFont * _Nonnull)font width:(CGFloat)width;

@end

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

@interface UIDevice (PBHelper)

/**
 *  @brief platform
 *
 *  @return the device's platform eg. iPhone6s
 */
+(NSString * _Nonnull)pb_platform;

@end

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

struct PBRGBA {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
};

typedef struct PBRGBA PBRGBA;

@interface UIColor (PBHelper)

/**
 *	@brief	generate color
 *
 *	@return	random color instance
 */
+ (UIColor * _Nonnull)pb_randomColor;

/**
 *	@brief	generate color
 *
 *	@param 	hexString 	eg:#34DE8A
 *
 *	@return	color's instance
 */

+ (UIColor * _Nonnull)pb_colorWithHexString:(NSString * _Nonnull)hexString;

/**
 *  @brief get rgba value from color
 *
 *  @param color the source color
 *
 *  @return the rgba value
 */
+ (PBRGBA)pb_rgbaFromUIColor:(UIColor * _Nonnull)color;

@end

@interface UIImage (PBHelper)

/**
 *	@brief	Judging Method
 *
 *	@param 	image 	other image
 *
 *	@return	whether only the two image is equal
 */
- (BOOL)pb_isEqualTo:(UIImage * _Nonnull)image;


/**
 *	@brief	generate image
 *
 *	@param 	color 	the image's color
 *
 *	@return	the image from color
 */
+ (UIImage * _Nonnull)pb_imageWithColor:(UIColor * _Nonnull)color;

/**
 *	@brief	blur image
 *
 *	@param 	blurAmount 	blur level, default is 0.5
 *
 *	@return	the blured image
 */
- (UIImage * _Nonnull)pb_blurredImage:(CGFloat)level;

/**
 *	@brief	generate small image
 *
 *	@param 	bounds 	the destnation image's frame
 *
 *	@return	the cropped image
 */
- (UIImage * _Nonnull)pb_croppedBounds:(CGRect)bounds;

/**
 *	@brief	scale image
 *
 *	@param 	dstSize 	the destnation size
 *
 *	@return	the scaled image
 */
- (UIImage * _Nonnull)pb_scaleToSize:(CGSize)dstSize DEPRECATED_MSG_ATTRIBUTE("use pb_scaleToSize: keepAspect: method instead");

/**
 *	@brief	scale image
 *
 *	@param 	dstSize 	the destnation size
 *	@param 	keep 	whether keep image's width/height scale info
 *
 *	@return	the scaled image
 */
- (UIImage * _Nonnull)pb_scaleToSize:(CGSize)dstSize keepAspect:(BOOL)keep;

/**
 *	@brief	generate round image
 *
 *	@return	the round image
 */
- (UIImage * _Nonnull)pb_roundImage;

/**
 *	@brief	generate round image
 *
 *	@param 	bWidth 	the round image's border width
 *	@param 	color 	the round image's border color
 *
 *	@return	the round image
 */
- (UIImage * _Nonnull)pb_roundImageWithBorderWidth:(int)bWidth withColor:(UIColor * _Nonnull)color;

/**
 *	@brief	generate round corner image
 *
 *	@param 	radius 	the round corner radius
 *
 *	@return	the round corner image
 */
- (UIImage * _Nonnull)pb_roundCornerWithRadius:(int)radius;

/**
 *	@brief	generate round corner image
 *
 *	@param 	radius 	the round corner redius
 *	@param 	bWidth 	the border width
 *	@param 	bColor 	the border color default is white
 *
 *	@return	the round corner image
 */
- (UIImage * _Nonnull)pb_roundCornerWithRadius:(int)radius withBorderWidth:(int)bWidth withBorderColor:(UIColor * _Nonnull)bColor;

/**
 *	@brief	generate dark image
 *
 *	@param 	color 	dark color
 *	@param 	level 	dark level
 *
 *	@return	the dark image
 */
- (UIImage * _Nonnull)pb_darkColor:(UIColor * _Nonnull)color lightLevel:(CGFloat)level;

/**
 *	@brief	generate image for iconfont
 *
 * To use this function you must add custom icon font into your plist file
 * for the key 'Fonts provided by application : iconfont.ttf'
 *
 *	@param 	fontName 	iconfont name default is named of 'iconfont'
 *	@param 	name        icon name
 *	@param 	size        the image's size
 *	@param 	color       the image's color default is white color
 *
 *	@return	the icon image
 */
+ (UIImage * _Nonnull)pb_iconFont:(NSString * _Nullable)fontName withName:(NSString * _Nonnull)name withSize:(NSInteger)size withColor:(UIColor * _Nonnull)color;

/*!
 *  @brief generate round corner image
 *
 *  @param radius the corner's size
 *  @param size   the image's new size
 *
 *  @return the round corner image
 */
- (UIImage * _Nonnull)pb_drawRoundCornerWithRadius:(CGFloat)radius toSize:(CGSize)size;

@end

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

- (void)pb_addRound:(CGBCornerColor)corner;

- (void)pb_addRound:(CGBCornerColor)corner withBorder:(CGBWidthColor)border;

@end
