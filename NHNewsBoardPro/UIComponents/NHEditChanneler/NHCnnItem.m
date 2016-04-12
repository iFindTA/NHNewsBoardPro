//
//  NHCnnItem.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHCnnItem.h"
#import "NHConstaints.h"

@interface NHCnnItem ()

@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIButton *delBtn;
@property (nonatomic, strong, nullable) UIImageView *bgImg;

@end

@implementation NHCnnItem

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
//    CGBCornerColor corner = {8,0xF5F5F5};
//    CGBWidthColor border = {1,0xC8C8C8};
//    [self pb_addRound:corner withBorder:border];
    
    weakify(self)
    UIImage *border = [UIImage imageNamed:@"channel_grid_circle"];
    UIImageView *bg = [[UIImageView alloc] initWithImage:border];
    [self insertSubview:bg atIndex:0];
    self.bgImg = bg;
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self)/*.insets(UIEdgeInsetsMake(-offset, -offset*2, -offset, -offset*2))*/;
    }];
    UILabel *label = [[UILabel alloc] init];
    UIFont *font = [UIFont pb_deviceFontForTitle];
    label.font = font;
    label.adjustsFontSizeToFitWidth = true;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(NHBoundaryOffset*0.5, NHBoundaryOffset, NHBoundaryOffset*0.5, NHBoundaryOffset));
    }];
    
    UIImage *mark = [UIImage imageNamed:@"sub_navi_edit_delete"];
    UIButton *tmp = [[UIButton alloc] init];
    [tmp setImage:mark forState:UIControlStateNormal];
    tmp.hidden = true;
    tmp.exclusiveTouch = true;
    [self addSubview:tmp];
    self.delBtn = tmp;
    [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.equalTo(self);
        make.width.mas_equalTo(self.mas_height).multipliedBy(.5f);
        make.height.mas_equalTo(self.mas_height).multipliedBy(.5f);
    }];
}

- (void)showDelete:(BOOL)show {
    if (self.isExist) {
        self.delBtn.hidden = !show;
        //self.dragGesture.enabled = show;
    }
}

- (BOOL)canBecomeFirstResponder {
    return true;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    self.delBtn.tag = tag;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.titleLabel.font = font;
}

- (void)hiddenBgImg:(BOOL)hidden {
    self.bgImg.hidden = hidden;
}

- (void)addTarget:(id)target forAction:(SEL)action {
    [self.delBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end

#pragma mark -- 更多待订阅栏目item
@interface NHOtherCnnItem ()

@property (nonatomic, strong) UIButton *btn;

@end

@implementation NHOtherCnnItem

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
    
    CGRect bounds = self.bounds;
    UIImage *bgImg = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    //CGFloat offset = NHBoundaryOffset*0.5;
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectInset(bounds, 1, 1)];
    bg.image = bgImg;
    [self addSubview:bg];
    
    UIImage *border = [UIImage imageNamed:@"channel_grid_circle"];
    UIButton *tmp = [UIButton buttonWithType:UIButtonTypeCustom];
    tmp.frame = bounds;
    tmp.exclusiveTouch = true;
    tmp.titleLabel.font = [UIFont pb_deviceFontForTitle];
    tmp.titleLabel.adjustsFontSizeToFitWidth = true;
    [tmp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [tmp setBackgroundImage:border forState:UIControlStateNormal];
    [self addSubview:tmp];
    self.btn = tmp;
}

- (void)addTarget:(id)target forAction:(SEL)action {
    [self.btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)hiddenTitle:(BOOL)hidden {
    self.btn.hidden = true;
}

#pragma mark -- public setter methods --

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    self.btn.tag = tag;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.btn setTitle:title forState:UIControlStateNormal];
}

@end