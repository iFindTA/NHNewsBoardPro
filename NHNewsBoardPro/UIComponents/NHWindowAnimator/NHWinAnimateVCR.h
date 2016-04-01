//
//  NHWinAnimateVCR.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NHAnimate2Night,
    NHAnimate2Darwn
} NHAnimateType;

@interface NHWinAnimateVCR : UIViewController

- (void)show:(NHAnimateType)type;

@end
