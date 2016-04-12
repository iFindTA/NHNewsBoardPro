//
//  PBToolKits.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 15/11/14.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "PBToolKits.h"
#import "sys/utsname.h"
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <mach/mach.h>
#import <mach-o/arch.h>
#import <net/if.h>
#import <ifaddrs.h>

@implementation PBToolKits

@end


#pragma mark == NSArray ==

@implementation NSArray (PBHelper)

- (BOOL)pb_isEmpty {
    return (self == nil || self.count <= 0);
}

@end

#pragma mark == NSDictionary ==

@implementation NSDictionary (PBHelper)

- (BOOL)pb_isEmpty {
    return (self == nil || self.count <= 0);
}
//////////////// NSDictionary Safe Accessors //////////////
- (BOOL)isKindOfClass:(Class)aClass forKey:(NSString *)key{
    id value = [self objectForKey:key];
    return [value isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass forKey:(NSString *)key{
    id value = [self objectForKey:key];
    return [value isMemberOfClass:aClass];
}

- (BOOL)isArrayForKey:(NSString *)key {
    return [self isKindOfClass:[NSArray class] forKey:key];
}

- (BOOL)isDictionaryForKey:(NSString *)key {
    return [self isKindOfClass:[NSDictionary class] forKey:key];
}

- (BOOL)isStringForKey:(NSString *)key {
    return [self isKindOfClass:[NSString class] forKey:key];
}

- (BOOL)isNumberForKey:(NSString *)key {
    return [self isKindOfClass:[NSNumber class] forKey:key];
}

- (NSArray *)pb_arrayForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

- (NSDictionary *)pb_dictionaryForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSString *)pb_stringForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(description)]) {
        return [value description];
    }
    return nil;
}

- (NSNumber *)pb_numberForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        return [nf numberFromString:value];
    }
    return nil;
}

- (double)pb_doubleForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }
    return 0;
}

- (float)pb_floatForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value floatValue];
    }
    return 0;
}

- (int)pb_intForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value intValue];
    }
    return 0;
}

- (unsigned int)pb_unsignedIntForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntValue];
    }
    return 0;
}

- (NSInteger)pb_integerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)pb_unsignedIntegerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (long long)pb_longLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (unsigned long long)pb_unsignedLongLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedLongLongValue];
    }
    return 0;
}

- (BOOL)pb_boolForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    return NO;
}

@end

#pragma mark == NSString ==

@implementation NSString (PBHelper)

- (BOOL)pb_isOnlyNumbers {
    NSCharacterSet *regular = [NSCharacterSet decimalDigitCharacterSet];
    regular = [regular invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:regular];
    return range.location == NSNotFound;
}

- (BOOL)pb_isOnlyLetters {
    NSCharacterSet *regular = [NSCharacterSet letterCharacterSet];
    regular = [regular invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:regular];
    return range.location == NSNotFound;
}

- (BOOL)pb_isNumberOrLetter {
    NSCharacterSet *regular = [NSCharacterSet alphanumericCharacterSet];
    regular = [regular invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:regular];
    return range.location == NSNotFound;
}

- (CGSize)pb_sizeThatFitsWithFont:(UIFont *)font width:(CGFloat)width {
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self];
    NSDictionary *attSetting = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSRange range = NSMakeRange(0, self.length);
    [attString setAttributes:attSetting range:range];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    CGSize constraints = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, constraints, nil);
    return CGSizeMake(ceilf(width), ceilf(coreTextSize.height));
}

//NSString *MPHexStringFromBytes(void *bytes, NSUInteger len) {
//    NSMutableString *output = [NSMutableString string];
//
//    unsigned char *input = (unsigned char *)bytes;
//
//    NSUInteger i;
//    for (i = 0; i < len; i++)
//        [output appendFormat:@"%02x", input[i]];
//    return output;
//}

//- (NSString *)MD5Hash {
//    const char *input = [self UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(input, (CC_LONG)strlen(input), result);
//    return MPHexStringFromBytes(result, CC_MD5_DIGEST_LENGTH);
//}
//
//- (NSString *)SHA1Hash {
//    const char *input = [self UTF8String];
//    unsigned char result[CC_SHA1_DIGEST_LENGTH];
//    CC_SHA1(input, (CC_LONG)strlen(input), result);
//    return MPHexStringFromBytes(result, CC_SHA1_DIGEST_LENGTH);
//}

@end

#pragma mark == NSBundle ==

@implementation NSBundle (PBHelper)

+ (NSString *)pb_buildVersion {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo pb_stringForKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)pb_releaseVersion {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo pb_stringForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)pb_displayName {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo pb_stringForKey:(NSString *)kCFBundleNameKey];
}

@end

#pragma mark == UIDevice ==

@implementation UIDevice (PBHelper)

+(NSString *)getSysInfoByName:(char *)typeSpecifier{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;
}

//获取平台信息
+(NSString *)pb_platform{
    NSString *result = [self getSysInfoByName:"hw.machine"];
    NSString *type = @"i386";
//    NSLog(@"固件版本：%@",result);
    //模拟器
    if ([result isEqualToString:@"i386"]||[result isEqualToString:@"x86_64"])                 type = @"Simulator";
    //iPod
    if ([result isEqualToString:@"iPod3,1"])        type = @"iPod Touch 3";
    if ([result isEqualToString:@"iPod4,1"])        type = @"iPod Touch 4";
    if ([result isEqualToString:@"iPod5,1"])        type = @"iPod Touch 5";
    //iPhone
    if ([result isEqualToString:@"iPhone2,1"])      type = @"iPhone 3Gs";
    if ([result isEqualToString:@"iPhone3,1"])      type = @"iPhone 4";
    if ([result isEqualToString:@"iPhone4,1"])      type = @"iPhone 4s";
    if ([result isEqualToString:@"iPhone5,1"]   ||
        [result isEqualToString:@"iPhone5,2"])      type = @"iPhone 5";
    if ([result isEqualToString:@"iPhone5,3"]   ||
        [result isEqualToString:@"iPhone5,4"])      type = @"iPhone 5c";
    if ([result isEqualToString:@"iPhone6,1"]   ||
        [result isEqualToString:@"iPhone6,2"])      type = @"iPhone 5s";
    if ([result isEqualToString:@"iPhone7,2"])      type = @"iPhone 6";
    if ([result isEqualToString:@"iPhone7,1"])      type = @"iPhone 6plus";
    if ([result isEqualToString:@"iPhone8,1"])      type = @"iPhone 6s";
    if ([result isEqualToString:@"iPhone8,2"])      type = @"iPhone 6splus";
    //iPad
    if ([result isEqualToString:@"iPad2,1"]     ||
        [result isEqualToString:@"iPad2,2"]     ||
        [result isEqualToString:@"iPad2,3"])        type = @"iPad 2";
    if ([result isEqualToString:@"iPad3,1"]     ||
        [result isEqualToString:@"iPad3,2"]     ||
        [result isEqualToString:@"iPad3,3"])        type = @"iPad 3";
    if ([result isEqualToString:@"iPad3,4"]     ||
        [result isEqualToString:@"iPad3,5"]     ||
        [result isEqualToString:@"iPad3,6"])         type = @"iPad 4";
    if ([result isEqualToString:@"iPad2,5"]     ||
        [result isEqualToString:@"iPad2,6"]     ||
        [result isEqualToString:@"iPad2,7"]     ||
        [result isEqualToString:@"iPad4,4"]     ||
        [result isEqualToString:@"iPad4,5"])        type = @"iPad Mini";
    if ([result isEqualToString:@"iPad4,1"]     ||
        [result isEqualToString:@"iPad4,2"]     ||
        [result isEqualToString:@"iPad4,3"]     ||
        [result isEqualToString:@"iPad4,6"])        type = @"iPad Air";
    
    
    return type;
}

@end

#pragma mark == UIFont ==

@implementation UIFont (PBHelper)

+ (UIFont *)pb_deviceFontForTitle {
    static UIFont *deviceFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (deviceFont == nil) {
            NSString *platform = [UIDevice pb_platform];
            NSInteger fontSize = 13;
            if ([platform isEqualToString:@"iPhone 6"]
                || [platform isEqualToString:@"iPhone 6s"]) {
                fontSize = 15;
            }else if ([platform isEqualToString:@"iPhone 6plus"]
                      || [platform isEqualToString:@"iPhone 6splus"]){
                fontSize = 17;
            }
            deviceFont = [UIFont systemFontOfSize:fontSize];
        }
    });
    return deviceFont;
}

+ (UIFont *)pb_navigationTitle {
    NSDictionary *attributs = [[UINavigationBar appearance] titleTextAttributes];
    return [attributs objectForKey:NSFontAttributeName];
}

@end

#pragma mark == UIColor ==

@implementation UIColor (PBHelper)

+ (UIColor *)pb_randomColor {
    
    UIColor *color;
    float randomRed   = (arc4random()%255)/255.0f;
    float randomGreen = (arc4random()%255)/255.0f;
    float randomBlue  = (arc4random()%255)/255.0f;
    
    color= [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1.0];
    
    return color;
}

+ (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)pb_colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            red = 0 ; green = 0 ; blue = 0; alpha = 1;
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (PBRGBA)pb_rgbaFromUIColor:(UIColor * _Nonnull)color {
    
    PBRGBA rgba;CGColorRef colorRef = color.CGColor;
    
    CGColorSpaceRef color_space = CGColorGetColorSpace(colorRef);
    CGColorSpaceModel color_space_model = CGColorSpaceGetModel(color_space);
    const CGFloat *color_components = CGColorGetComponents(colorRef);
    size_t color_component_count = CGColorGetNumberOfComponents(colorRef);
    
    switch (color_space_model){
        case kCGColorSpaceModelMonochrome:{
            assert(color_component_count == 2);
            rgba = (PBRGBA){
                .r = color_components[0],
                .g = color_components[0],
                .b = color_components[0],
                .a = color_components[1]
            };
            break;
        }
            
        case kCGColorSpaceModelRGB:{
            assert(color_component_count == 4);
            rgba = (PBRGBA){
                .r = color_components[0],
                .g = color_components[1],
                .b = color_components[2],
                .a = color_components[3]
            };
            break;
        }
            
        default:{
            rgba = (PBRGBA) { 0, 0, 0, 0 };
            break;
        }
    }
    
    return rgba;
}

@end

#pragma mark == UIImage ==

@implementation UIImage (PBHelper)

- (BOOL)pb_isEqualTo:(UIImage *)image {
    BOOL result = NO;
    if (image && CGSizeEqualToSize(self.size, image.size)) {
        
        CGDataProviderRef dataProvider1 = CGImageGetDataProvider(self.CGImage);
        NSData *data1 = (NSData*)CFBridgingRelease(CGDataProviderCopyData(dataProvider1));
        
        CGDataProviderRef dataProvider2 = CGImageGetDataProvider(image.CGImage);
        NSData *data2 = (NSData*)CFBridgingRelease(CGDataProviderCopyData(dataProvider2));
        
        result = [data1 isEqual:data2];
    }
    return result;
}

+ (UIImage *)pb_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)pb_blurredImage:(CGFloat)level {
    if (level < 0.0 || level > 1.0) {
        level = 0.5;
    }
    
    int boxSize = (int)(level * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (!error) {
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    }
    
    if (error) {
#ifdef DEBUG
        NSLog(@"%s error: %zd", __PRETTY_FUNCTION__, error);
#endif
        
        return self;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (UIImage *)pb_croppedBounds:(CGRect)bounds {
    
    CGFloat scale = MAX(self.scale, 1.0f);
    
    CGRect scaledBounds = CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], scaledBounds);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    
    return croppedImage;
    
}

- (UIImage*)pb_scaleToSize:(CGSize)dstSize {
    CGImageRef imgRef = self.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return self;
    }
    
    CGFloat scaleRatio = dstSize.width / srcSize.width;
    UIImageOrientation orient = self.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    /////////////////////////////////////////////////////////////////////////////
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage*)pb_scaleToSize:(CGSize)dstSize keepAspect:(BOOL)keep{
    
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(self.size, dstSize)) {
        return self;
    }
    
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = dstSize.width / self.size.width;
    CGFloat aspectHeight = dstSize.height / self.size.height;
    CGFloat aspectRatio = keep?MIN(aspectWidth, aspectHeight):MAX(aspectWidth, aspectHeight);
    
    scaledImageRect.size.width = self.size.width * aspectRatio;
    scaledImageRect.size.height = self.size.height * aspectRatio;
    scaledImageRect.origin.x = (dstSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (dstSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( dstSize, NO, 0 );
    [self drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)pb_roundImage {
    int w = self.size.width;
    int h = self.size.height;
    int dst_wh = w;
    UIImage *tmpImg = self;
    if (w != h) {
        dst_wh = MIN(w, h);
        tmpImg = [self pb_scaleToSize:CGSizeMake(dst_wh, dst_wh) keepAspect:false];
    }
    int radius = dst_wh*0.5;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, dst_wh, dst_wh, 8, 4 * w, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, dst_wh, dst_wh);
    
    CGContextBeginPath(contextRef);
    CGContextAddArc(contextRef, CGRectGetMidX(rect), CGRectGetMidY(rect), radius, 0, 2*M_PI, false);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, rect, tmpImg.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageMasked);
    return img;
}

- (UIImage *)pb_roundImageWithBorderWidth:(int)bWidth withColor:(UIColor *)color {
    int w = self.size.width;
    int h = self.size.height;
    int dst_wh = w;
    UIImage *tmpImg = self;
    if (w != h) {
        dst_wh = MIN(w, h);
        tmpImg = [self pb_scaleToSize:CGSizeMake(dst_wh, dst_wh) keepAspect:false];
    }
    int radius = dst_wh*0.5;
    if (bWidth >= radius || bWidth <= 0) {
        return [self pb_roundImage];
    }
    color = ((color !=nil?color:[UIColor whiteColor]));
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, dst_wh, dst_wh, 8, 4 * w, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, dst_wh, dst_wh);
    
    CGContextBeginPath(contextRef);
    CGContextAddArc(contextRef, CGRectGetMidX(rect), CGRectGetMidY(rect), radius, 0, 2*M_PI, false);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    /// draw layer
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, rect);
    rect = CGRectInset(rect, bWidth, bWidth);
    CGContextAddArc(contextRef, CGRectGetMidX(rect), CGRectGetMidY(rect), radius-bWidth, 0, 2*M_PI, false);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, rect, tmpImg.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageMasked);
    return img;
}

- (UIImage *)pb_roundCornerWithRadius:(int)radius {
    int w = self.size.width;
    int h = self.size.height;
    int dst_wh = w;
    if (w != h) {
        dst_wh = MIN(w, h);
    }
    if (radius > dst_wh || radius <= 0) {
        return self;
    }
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    UIBezierPath *dstPath = [self pb_pathForSize:rect radius:radius];
    CGContextBeginPath(contextRef);
    CGContextAddPath(contextRef, dstPath.CGPath);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, rect, self.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageMasked);
    return img;
}

- (UIImage *)pb_roundCornerWithRadius:(int)radius withBorderWidth:(int)bWidth withBorderColor:(UIColor *)bColor {
    int w = self.size.width;
    int h = self.size.height;
    int dst_wh = w;
    if (w != h) {
        dst_wh = MIN(w, h);
    }
    if (radius + bWidth > dst_wh || radius <= 0 || bWidth <= 0) {
        return self;
    }
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    UIBezierPath *dstPath = [self pb_pathForSize:rect radius:radius];
    /// begin graphics
    CGContextBeginPath(contextRef);
    CGContextAddPath(contextRef, dstPath.CGPath);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    /// draw layer
    bColor = ((bColor != nil)?bColor:[UIColor whiteColor]);
    CGContextSetFillColorWithColor(contextRef, bColor.CGColor);
    CGContextFillRect(contextRef, rect);
    /// draw image
    rect = CGRectInset(rect, bWidth, bWidth);
    dstPath = [self pb_pathForSize:rect radius:radius];
    CGContextAddPath(contextRef, dstPath.CGPath);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, rect, self.CGImage);
    /// end draw image
    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageMasked);
    return img;
}

- (UIBezierPath *)pb_pathForSize:(CGRect)rect radius:(int)radius {
    
    CGPoint origin = rect.origin;
    CGSize size = rect.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    /// left top points
    CGPoint lt_c = CGPointMake(origin.x, origin.y);
    CGPoint lt_r = CGPointMake(origin.x+radius, origin.y);
    CGPoint lt_l = CGPointMake(origin.x, origin.y+radius);
    /// right top points
    CGPoint rt_c = CGPointMake(origin.x+size.width, origin.y);
    CGPoint rt_r = CGPointMake(origin.x+size.width, origin.y+radius);
    CGPoint rt_l = CGPointMake(origin.x+size.width-radius, origin.y);
    /// left bottom points
    CGPoint lb_c = CGPointMake(origin.x, origin.y+size.height);
    CGPoint lb_r = CGPointMake(origin.x+radius, origin.y+size.height);
    CGPoint lb_l = CGPointMake(origin.x, origin.y+size.height-radius);
    /// right bottom points
    CGPoint rb_c = CGPointMake(origin.x+size.width, origin.y+size.height);
    CGPoint rb_r = CGPointMake(origin.x+size.width, origin.y+size.height-radius);
    CGPoint rb_l = CGPointMake(origin.x+size.width-radius, origin.y+size.height);
    
    /// add points lines to path
    [path moveToPoint:lt_r];
    [path addLineToPoint:rt_l];
    [path addQuadCurveToPoint:rt_r controlPoint:rt_c];
    [path addLineToPoint:rb_r];
    [path addQuadCurveToPoint:rb_l controlPoint:rb_c];
    [path addLineToPoint:lb_r];
    [path addQuadCurveToPoint:lb_l controlPoint:lb_c];
    [path addLineToPoint:lt_l];
    [path addQuadCurveToPoint:lt_r controlPoint:lt_c];
    [path closePath];
    
    return path;
}

- (UIImage *)pb_darkColor:(UIColor *)color lightLevel:(CGFloat)level {
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawInRect:imageRect];
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextSetAlpha(ctx, level);
    CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
    CGContextFillRect(ctx, imageRect);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *darkImage = [UIImage imageWithCGImage:imageRef
                                             scale:self.scale
                                       orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    return darkImage;
}

+ (UIImage *)pb_iconFont:(NSString *)fontName withName:(NSString *)name withSize:(NSInteger)size withColor:(UIColor *)color {
    if (size <= 0 || PBIsEmpty(name)) {
        return nil;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    fontName = (fontName != nil ? fontName:@"iconfont");
    UIFont *font = [UIFont fontWithName:fontName size:size*scale];
    if (font == nil) {
        return nil;
    }
    color = (color == nil ? [UIColor whiteColor]:color);
    
    CGFloat realSize = size * scale;
//    UIGraphicsBeginImageContext(CGSizeMake(realSize, realSize));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(realSize, realSize), false, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([name respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        [name drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: color}];
    } else {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGContextSetFillColorWithColor(context, color.CGColor);
        [name drawAtPoint:CGPointMake(0, 0) withFont:font];
#pragma clang pop
    }
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)pb_drawRoundCornerWithRadius:(CGFloat)radius toSize:(CGSize)size {
    CGRect bounds = CGRectZero;
    bounds.size = size;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    [self drawInRect:bounds];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

@end

#pragma mark - UIView

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