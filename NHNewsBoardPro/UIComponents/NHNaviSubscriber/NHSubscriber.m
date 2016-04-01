//
//  NHSubscriber.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#define kItemDistance       30
#define kExtradPadding      20
#define kItemFontSize       13
#define kEditArrowWidth     40
#define kAnimationDuration  0.25
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define itemPerLine 4
#define kItemW (kScreenW-kExtradPadding*(itemPerLine+1))/itemPerLine
#define kItemH 25

#import "NHSubscriber.h"
#import "NHBaseKits.h"

@interface NHSubscriber ()

@property (nonatomic, assign) NHNaviStyle style;
@property (nonatomic, strong) NSMutableArray *sourceData, *btnSets;
@property (nonatomic, assign) BOOL expadding, outTrigger;
@property (nonatomic, strong) UIView *flagView, *sortBar;
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, strong) UIScrollView *displayScroll;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) UIButton *arrowBtn;

@end

static CGFloat kFlagOffset = 10;
static CGFloat kFlagHeight = 20;

@implementation NHSubscriber

- (id)initWithFrame:(CGRect)frame forStyle:(NHNaviStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setSubscriberSelectIndex:(NSInteger)index {
    
    NSAssert(_dataSource != nil, @"subcriber's datasource must not be nil !");
    NSArray *exsitArr = [_dataSource sourceDataForSubscriber:self];
    NSInteger counts = [exsitArr count];
    if (index < 0 || index >= counts) {
        return;
    }
    _outTrigger = true;
    [self focusIndex:index];
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
//    self.displayScroll.backgroundColor = backgroundColor;
//    self.arrowBtn.backgroundColor = backgroundColor;
//}

- (void)reloadData {
    
    _expadding = false;
    _selectIndex = 0;
    if (_btnSets || [_btnSets count]) {
        [_btnSets removeAllObjects];
        _btnSets = nil;
    }
    _btnSets = [[NSMutableArray alloc] initWithCapacity:0];
    if (_displayScroll != nil) {
        [_displayScroll removeFromSuperview];
        _displayScroll = nil;
    }
    if (_arrowBtn != nil) {
        [_arrowBtn removeFromSuperview];
        _arrowBtn = nil;
    }
    if (_flagView != nil) {
        [_flagView removeFromSuperview];
        _flagView = nil;
    }
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSAssert(_dataSource != nil, @"subcriber's datasource must not be nil !");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self _initSetup];
}

- (void)_initSetup {
    _outTrigger = false;
    __block CGSize selfSize = self.bounds.size;
    //CGSize superSize = [_superView bounds].size;
    NSArray *exist_data = [_dataSource sourceDataForSubscriber:self];
    NSAssert(exist_data.count > 0, @"exsit data must one more thing !");
    
    CGRect infoRect;
    
    _maxWidth = kFlagHeight;
    //generate items for display scroll
    [self addSubview:self.displayScroll];
    [_displayScroll addSubview:self.flagView];
    weakify(self)
    [self addColorChangedBlock:^{
        strongify(self)
        self.flagView.nightBackgroundColor = NHNaviBarNightTintColor;
    }];
    
    __block CGFloat tmpWidthSum = kFlagHeight;
    __block UIColor *btnColor_darwn = [self btnTitleColor];
    __block UIColor *btnColor_night = UIColorFromRGB(0xD0D0D0);
    __block UIColor *selectColor = _style == NHNaviStyleBack?[UIColor whiteColor]:[UIColor redColor];
    //weakify(self)
    [exist_data enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        strongify(self)
        if (title.length > 0) {
            CGSize itemSize = [self calculateSizeWithFont:kItemFontSize Text:title];
            CGRect tmpRect = CGRectMake( tmpWidthSum, 0, itemSize.width, selfSize.height);
            UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tmpBtn.frame = tmpRect;
            tmpBtn.tag = idx;
            tmpBtn.exclusiveTouch = true;
            tmpBtn.titleLabel.font = [UIFont systemFontOfSize:kItemFontSize];
            [tmpBtn setTitle:title forState:UIControlStateNormal];
//            [tmpBtn setTitleColor:btnColor forState:UIControlStateNormal];
            [tmpBtn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addColorChangedBlock:^{
                [tmpBtn setNormalTitleColor:btnColor_darwn];
                [tmpBtn setNightTitleColor:btnColor_night];
            }];
            if (idx == _selectIndex) {
                [tmpBtn setTitleColor:selectColor forState:UIControlStateNormal];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_displayScroll addSubview:tmpBtn];
            });
            [_btnSets addObject:tmpBtn];
            tmpWidthSum += (itemSize.width + kItemDistance);
        }
    }];
    tmpWidthSum += kFlagHeight - kItemDistance;
    CGSize contentSize = CGSizeMake(tmpWidthSum, selfSize.height);
    [_displayScroll setContentSize:contentSize];
    
    infoRect = CGRectMake(selfSize.width-kEditArrowWidth, 0, kEditArrowWidth, selfSize.height);
    UIImage *image = [UIImage imageNamed:@"sub_navi_add_arrow"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setImage:image forState:UIControlStateNormal];
//    btn.backgroundColor = [self mainBackgroundColor];
    [btn addTarget:self action:@selector(arrowBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    _arrowBtn = btn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(darwnWillComing) name:DKNightVersionDawnComingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightWillComing) name:DKNightVersionNightFallingNotification object:nil];
}

- (void)darwnWillComing {
    weakify(self)
    PBMAINDelay(0.002, ^{
        strongify(self)
        [self updateBtnItemsTitleColor];
    });
}

- (void)nightWillComing {
    weakify(self)
    PBMAINDelay(0.002, ^{
        strongify(self)
        [self updateBtnItemsTitleColor];
    });
}

- (void)itemClicked:(UIButton *)btn{
    _outTrigger = false;
    NSInteger btn_tag = [btn tag];
    if (btn_tag < 0 || btn_tag >= [_btnSets count]) {
        return;
    }
    if (btn_tag != _selectIndex) {
        _selectIndex = btn_tag;
        ///modify btn's title color
        [self updateBtnItemsTitleColor];
        ///re move the flag view
        [self updateFlagViewFor:btn];
        ///notify the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(subscriber:didSelectIndex:)]) {
            [_delegate subscriber:self didSelectIndex:_selectIndex];
        }
    }
}

- (void)focusIndex:(NSInteger)index {
    UIButton *dst_btn;
    for (UIButton *tmp in _btnSets) {
        if (index == tmp.tag) {
            dst_btn = tmp;
            break;
        }
    }
    if (index != _selectIndex) {
        _selectIndex = index;
        ///modify btn's title color
        [self updateBtnItemsTitleColor];
        ///re move the flag view
        [self updateFlagViewFor:dst_btn];
        ///notify the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(subscriber:didSelectIndex:)] && !_outTrigger) {
            [_delegate subscriber:self didSelectIndex:_selectIndex];
        }
        _outTrigger = false;
    }
}

- (void)updateBtnItemsTitleColor {
    UIColor *color_n = [self btnTitleColor];
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) {
        color_n = UIColorFromRGB(0xD0D0D0);
    }
    UIColor *color_s = _style == NHNaviStyleBack?[UIColor whiteColor]:[UIColor redColor];
    @synchronized(_btnSets){
        for (UIButton *tmp in _btnSets) {
            [tmp setTitleColor:tmp.tag == _selectIndex?color_s:color_n forState:UIControlStateNormal];
        }
    }
}

- (void)updateFlagViewFor:(UIButton *)btn{
    if (btn) {
        __block CGSize selfSize = self.bounds.size;
        CGRect btn_rect = [btn frame];
        CGSize btn_size = btn_rect.size;
        CGRect flagBounds = _flagView.frame;
        flagBounds.size.width = btn_size.width+kExtradPadding;
        CGRect layerFrame = _lineLayer.frame;
        layerFrame.size.width = flagBounds.size.width;
        CGFloat offset_x = btn.frame.origin.x - kExtradPadding*0.5 - kFlagOffset;
        CGAffineTransform trans = CGAffineTransformMakeTranslation(offset_x, 0);
        CGPoint offsetPt;
        CGSize scrollSize = _displayScroll.bounds.size;
        if (btn_rect.origin.x >= selfSize.width-150 && btn_rect.origin.x < _displayScroll.contentSize.width-scrollSize.width) {
            offsetPt = CGPointMake(btn_rect.origin.x-200, 0);
        }else if (btn_rect.origin.x >= _displayScroll.contentSize.width-scrollSize.width){
            offsetPt = CGPointMake(_displayScroll.contentSize.width-scrollSize.width, 0);
        }else{
            offsetPt = CGPointZero;
        }
        [UIView animateWithDuration:kAnimationDuration animations:^{
            _lineLayer.frame = layerFrame;
            _flagView.frame = flagBounds;
            _flagView.transform = trans;
        } completion:^(BOOL finished) {
            [_displayScroll setContentOffset:offsetPt animated:true];
        }];
    }
}

- (UIColor *)mainBackgroundColor {
    return RGBColor(238.0, 238.0, 238.0);
}

- (UIColor *)btnTitleColor {
    return RGBColor(111.0, 111.0, 111.0);
}

- (UIView *)flagView {
    if (_flagView == nil) {
        CGRect infoRect;UIColor *bgColor;
        CGSize selfSize = self.bounds.size;
        _flagView = [[UIView alloc] initWithFrame:infoRect];
        _flagView.layer.cornerRadius = 5;
        if (_style == NHNaviStyleBack) {
            infoRect = CGRectMake(_maxWidth*0.5, (selfSize.height-kFlagHeight)*0.5, 50, kFlagHeight);
            bgColor = NHNaviBarDarwnTintColor;
        }else{
            infoRect = CGRectMake(_maxWidth*0.5, selfSize.height-kFlagOffset, 50, kFlagOffset*0.5);
            bgColor = NHWhiteColor;
            _lineLayer = [CALayer layer];
            [_lineLayer setBackgroundColor:[UIColor cyanColor].CGColor];
            [_lineLayer setFrame:CGRectMake(0, CGRectGetHeight(infoRect) - 4, CGRectGetWidth(infoRect)-2, 2)];
            [_flagView.layer insertSublayer:_lineLayer atIndex:0];
        }
        _flagView.frame = infoRect;
        _flagView.normalBackgroundColor = bgColor;
        _flagView.layer.cornerRadius = 5;
    }
    return _flagView;
}

- (UIScrollView *)displayScroll{
    if (_displayScroll == nil) {
        CGSize selfSize = self.bounds.size;
        CGRect infoRect = CGRectMake(0, 0, selfSize.width-kEditArrowWidth, selfSize.height);
        _displayScroll = [[UIScrollView alloc] initWithFrame:infoRect];
        _displayScroll.backgroundColor = [UIColor clearColor];
        _displayScroll.showsHorizontalScrollIndicator = false;
        _displayScroll.showsVerticalScrollIndicator = false;
        _displayScroll.contentOffset = CGPointZero;
    }
    return _displayScroll;
}

- (void)arrowBtnEvent:(UIButton *)btn{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectArrowForSubscriber:)]) {
        [_delegate didSelectArrowForSubscriber:self];
    }
    //[self updateArrowState:btn];
}

- (void)updateArrowState:(UIButton *)btn{
    _expadding = !_expadding;
    CGAffineTransform rotation = _expadding?CGAffineTransformMakeRotation(M_PI):CGAffineTransformIdentity;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        btn.imageView.transform = rotation;
    } completion:^(BOOL finished) {
        /// notify the delegate
    }];
}

- (NSArray *)sourceData{
    return [_dataSource sourceDataForSubscriber:self];
}

#pragma mark -- UTIL --

-(CGSize)calculateSizeWithFont:(NSInteger)Font Text:(NSString *)Text{
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font]};
    CGRect bounds = [Text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                       options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attr
                                       context:nil];
    return bounds.size;
}

@end
