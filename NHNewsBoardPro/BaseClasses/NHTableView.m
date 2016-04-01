//
//  NHTableView.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHTableView.h"
#import "NHConstaints.h"

@implementation NHTableView

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

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self _initSetup];
    }
    return self;
}

- (void)_initSetup {

    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.nightBackgroundColor = NHNightBgColor;
        self.normalBackgroundColor = NHDarwnBgColor;
        self.normalSeparatorColor = UIColorFromRGB(0xDBDBDB);
        self.nightSeparatorColor = [UIColor lightGrayColor];
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
