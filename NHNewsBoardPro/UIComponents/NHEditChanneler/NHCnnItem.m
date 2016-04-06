//
//  NHCnnItem.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHCnnItem.h"

@implementation NHCnnItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = true;
        [self __initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = true;
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    //    CGBCornerColor corner = {8,0xF5F5F5};
    //    CGBWidthColor border = {1,0xC8C8C8};
    //    [self pb_addRound:corner withBorder:border];
    weakify(self)
    UIImage *border = [UIImage imageNamed:@"channel_grid_circle"];
    UIImageView *bg = [[UIImageView alloc] initWithImage:border];
    [self addSubview:bg];
    self.bgImg = bg;
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self);
    }];
    UIFont *font = [UIFont pb_deviceFontForTitle];
    self.font = font;
    self.adjustsFontSizeToFitWidth = true;
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment = NSTextAlignmentCenter;
    
    UIImage *mark = [UIImage imageNamed:@"sub_navi_edit_delete"];
    UIButton *tmp = [[UIButton alloc] init];
    [tmp setImage:mark forState:UIControlStateNormal];
    tmp.hidden = true;
    [self addSubview:tmp];
    self.delBtn = tmp;
    [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.equalTo(self);
        make.width.height.equalTo(@(mark.size.width*0.5));
    }];
}

- (void)showDelete:(BOOL)show {
    if (self.isExist) {
        self.delBtn.hidden = !show;
    }
}

@end
