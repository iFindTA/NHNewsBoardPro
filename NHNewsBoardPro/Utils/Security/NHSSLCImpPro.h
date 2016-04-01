//
//  NHSSLCImpPro.h
//  NHSSLCImpPro
//
//  Created by hu jiaju on 15/8/18.
//  Copyright (c) 2015年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _sslUtil {
    /**
     *  AES Part default vector 'NHSSLAESCBCSMODE'
     */
    NSString* (*aesGenerateKey)(void);
    NSString* (*aesEncrypt)(NSString *plainData,NSString *key);
    NSString* (*aesDecrypt)(NSString *cipherData,NSString *key);
    /**
     * RSA Part
     */
    NSString* (*rsaEncrypt)(NSString *plainText);
    BOOL (*rsaVerify)(NSString *cipherData,NSString *signData);
    
}NHSSLUtil_t;

#define NHSSLUtil ([NHSSLCImpPro shareUtil])

@interface NHSSLCImpPro : NSObject

+ (NHSSLUtil_t *)shareUtil;

@end
