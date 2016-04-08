//
//  NHCnnItem.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHCnnItem.h"
#import "NHConstaints.h"

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
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
//    [self addGestureRecognizer:panGesture];
//    panGesture.enabled = false;
//    self.dragGesture = panGesture;
    
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    weakify(self)
    UIImage *border = [UIImage imageNamed:@"channel_grid_circle"];
    //CGFloat offset = NHBoundaryOffset*0.5;
    UIImageView *bg = [[UIImageView alloc] initWithImage:border];
    [self addSubview:bg];
    self.bgImg = bg;
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self)/*.insets(UIEdgeInsetsMake(-offset, -offset*2, -offset, -offset*2))*/;
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

- (id)copyWithZone:(NSZone *)zone {
    NHCnnItem *tmp = [[self class] allocWithZone:zone];
    return tmp;
}

@end

@implementation NHMoreItem

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

+ (id)buttonWithType:(UIButtonType)buttonType {
    NHMoreItem *tmp = [super buttonWithType:buttonType];
    [tmp __initSetup];
    return tmp;
}

- (void)__initSetup {
    
    UIImage *border = [UIImage imageNamed:@"channel_grid_circle"];
    
    [self setBackgroundImage:border forState:UIControlStateNormal];
    [self setBackgroundImage:nil forState:UIControlStateSelected];
//    weakify(self)
//    //CGFloat offset = NHBoundaryOffset*0.5;
//    UIImageView *bg = [[UIImageView alloc] initWithImage:border];
//    [self addSubview:bg];
//    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.edges.equalTo(self)/*.insets(UIEdgeInsetsMake(-offset, -offset*2, -offset, -offset*2))*/;
//    }];
}

@end

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