//
//  NHLabel.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHLabel.h"
#import "NHConstaints.h"

@implementation NHLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSetup];
    }
    return self;
}

- (void)_initSetup {
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.normalBackgroundColor = NHDarwnBgColor;
        self.nightBackgroundColor = NHNightBgColor;
    }];
}

@end
