//
//  NSString+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NSString+PBHelper.h"
#import "PBDependency.h"

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
