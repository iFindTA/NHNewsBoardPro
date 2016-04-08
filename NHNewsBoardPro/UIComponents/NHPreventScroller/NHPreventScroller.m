//
//  NHPreventScroller.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/8.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventScroller.h"

/**在同一时刻最多显示的page个数**/
static const int NH_MAX_LOAD_PAGE_NUM               = 6;

@interface NHPreventScroller ()

@end

@implementation NHPreventScroller

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    //锁定滚动方向
    self.directionalLockEnabled = true;
    
}

@end
