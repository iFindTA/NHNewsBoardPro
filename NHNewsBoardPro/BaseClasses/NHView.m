//
//  NHView.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHView.h"
#import "NHConstaints.h"

@implementation NHView

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
