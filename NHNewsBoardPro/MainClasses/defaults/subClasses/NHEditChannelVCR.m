//
//  NHEditChannelVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/29.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHEditChannelVCR.h"

#pragma mark -- Item for display --

@interface NHItemChannel : UIControl

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIButton *delete;

@property (nonatomic, assign) BOOL isExist;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

/**
 *  @brief wethear show delete button
 *
 *  @param show enable
 */
- (void)showDelete:(BOOL)show;

@end

@interface NHItemChannel ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NHItemChannel

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
    [self addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self);
    }];
    UIFont *font = [UIFont pb_deviceFontForTitle];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self);
    }];
    
    UIImage *mark = [UIImage imageNamed:@"sub_navi_edit_delete"];
    UIButton *tmp = [[UIButton alloc] init];
    [tmp setImage:mark forState:UIControlStateNormal];
    tmp.hidden = true;
    [self addSubview:tmp];
    self.delete = tmp;
    [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.top.left.equalTo(self);
        make.width.height.equalTo(@(mark.size.width*0.5));
    }];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] init];
    longGesture.minimumPressDuration = 1;
    [self addGestureRecognizer:longGesture];
}

- (void)showDelete:(BOOL)show {
    if (self.isExist) {
        self.delete.hidden = !show;
    }
}

- (void)setFont:(UIFont *)font {
    self.titleLabel.font = font;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end

#define NHIndexTitle          @"推荐"

@interface NHEditChannelVCR ()<UIGestureRecognizerDelegate>

@property (nullable, nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *changeFlag,*moreFlag;
@property (nonatomic, strong) UIButton *sortFlag;
@property (nonatomic, assign) BOOL dragEnable;

@property (nonatomic, copy) NSString *selectedChannel;
@property (nonatomic, copy) NHSwitchChannel switchBlock;

@end

@implementation NHEditChannelVCR

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self changeNavigationBarTitle2:@"编辑频道"];
    [self registerBarItems:@[kItemClose] forPlace:NHItemTypeRight];
    
    weakify(self)
    __block UIImageView *subNavi = [[UIImageView alloc] init];
    subNavi.userInteractionEnabled = true;
    subNavi.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [self.view addSubview:subNavi];
    [subNavi mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(NHSubNavigationBarHeight));
    }];
    CGFloat offset = NHBoundaryOffset;
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
    UILabel *label = [[UILabel alloc] init];
    label.font = titleFont;
    label.text = @"切换栏目";
    [subNavi addSubview:label];
    self.changeFlag = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.equalTo(self.view).offset(offset);
        make.centerY.equalTo(subNavi.mas_centerY);
    }];
    CGFloat btn_width = 60.f;
    UIImage *bgImg = [UIImage imageNamed:@"channel_edit_button_bg"];
    UIImage *bgImg_s = [UIImage imageNamed:@"channel_edit_button_bg_s"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(PBSCREEN_WIDTH-btn_width-offset, NHAbove_h+NHSubNavigationBarHeight, btn_width, NHSubNavigationBarHeight*0.5);
    btn.titleLabel.font = titleFont;
    [btn setTitleColor:NHNaviBarDarwnTintColor forState:UIControlStateNormal];
    [btn setTitleColor:NHWhiteColor forState:UIControlStateHighlighted];
    [btn setTitle:@"排序删除" forState:UIControlStateNormal];
    [btn setBackgroundImage:bgImg forState:UIControlStateNormal];
    [btn setBackgroundImage:bgImg_s forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(dragSortAction) forControlEvents:UIControlEventTouchUpInside];
    [subNavi addSubview:btn];
    self.sortFlag = btn;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.centerY.equalTo(subNavi.mas_centerY);
        make.right.equalTo(self.view).offset(-offset);
    }];
    
    self.selectedChannel = PBFormat(@"%@",NHIndexTitle);
    
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.backgroundColor = NHWhiteColor;
    [self.view addSubview:scroll];
    self.scrollView = scroll;
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.mas_equalTo(subNavi.mas_bottom).offset(0);
        make.left.bottom.right.equalTo(self.view).offset(0);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self buildExistChannels];
    
    [self buildOtherChannels];
}

//- (UIScrollView *)scrollView {
//    if (!_scrollView) {
//        UIScrollView *scroll = [[UIScrollView alloc] init];
//        scroll.backgroundColor = NHWhiteColor;
//
//    }
//    return _scrollView;
//}

- (void)navigationBarActionClose {
    [super navigationBarActionClose];
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)dragSortAction {
    
    self.dragEnable = !self.dragEnable;
    NSString *title = self.dragEnable?@"完成":@"排序删除";
    [self.sortFlag setTitle:title forState:UIControlStateNormal];
    title = self.dragEnable?@"拖动排序":@"切换栏目";
    self.changeFlag.text = title;
    NSArray *subviews = [self.scrollView subviews];
    weakify(self)
    [subviews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        if ([obj isKindOfClass:[NHItemChannel class]]) {
            NHItemChannel *item = (NHItemChannel *)obj;
            [item showDelete:self.dragEnable];
        }
    }];
}

// setter method
- (void)setExistSource:(NSArray *)existSource {
    if (_existSource) {
        _existSource = nil;
    }
    _existSource = existSource;
    //[self buildExistChannels];
}
#define NH_ITEM_WIDTH     70
#define NH_ITEM_HEIGHT    30
- (void)buildExistChannels {
    
    //TODO:这里需要考虑iPad
    NSInteger numPerLine = 4;
    CGFloat cap = (PBSCREEN_WIDTH-NHBoundaryOffset*2-NH_ITEM_WIDTH*numPerLine)/(numPerLine-1);
    NSInteger counts = self.existSource.count;
    if (counts == 0) {
        return;
    }
    NSInteger rows = counts/numPerLine;
    if (counts%numPerLine!=0) {
        rows+=1;
    }
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
    UIImage *bgImg_v = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    weakify(self)
    [self.existSource enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        BOOL dragable = [self canDrag:obj];
        
        UIColor *titleColor = dragable?[UIColor lightGrayColor]:[UIColor redColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGRect bounds = CGRectMake(NHBoundaryOffset+(NH_ITEM_WIDTH+cap)*__col, NHBoundaryOffset*2+(NH_ITEM_HEIGHT+cap)*__row, NH_ITEM_WIDTH, NH_ITEM_HEIGHT);
        if (!dragable) {
            UILabel *label = [[UILabel alloc] initWithFrame:bounds];
            label.font = titleFont;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = titleColor;
            label.text = obj;
            [self.scrollView addSubview:label];
        }else{
            UIImageView *imgBg = [[UIImageView alloc] initWithFrame:bounds];
            imgBg.image = dragable?bgImg_v:nil;
            [self.scrollView addSubview:imgBg];
            
            NHItemChannel *tmp = [[NHItemChannel alloc] initWithFrame:bounds];
            tmp.font = titleFont;
            tmp.titleColor = titleColor;
            tmp.title = obj;
            tmp.isExist = true;
            tmp.delete.tag = idx;
            [tmp addTarget:self action:@selector(channelSelectedEvent:) forControlEvents:UIControlEventTouchUpInside];
            [tmp.delete addTarget:self action:@selector(channelDeleteTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
            //手势
            [tmp.longGesture addTarget:self action:@selector(channelLongGesture:)];
            
            [self.scrollView addSubview:tmp];
        }
    }];
    
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, NHBoundaryOffset*2+(NH_ITEM_HEIGHT+cap)*rows);
    self.scrollView.contentSize = contentSize;
}

- (BOOL)canDrag:(NSString * _Nonnull)til {
    
    return ![til isEqualToString:NHIndexTitle];
}
- (void)adjustItemForWidth:(CGFloat)width withCap:(CGFloat)cap toItemWidth:(CGFloat *)item {
    
}
//点击频道
- (void)channelSelectedEvent:(NHItemChannel *)tmp {
    
    NSString *tmp_title = tmp.title;
    if ([tmp_title isEqualToString:NHIndexTitle]) {
        return;
    }
    self.selectedChannel = [tmp_title copy];
    
}
//点击小叉叉
- (void)channelDeleteTouchEvent:(UIButton *)tmp {
    
    NSUInteger __tag = [tmp tag];
    NSLog(@"你点击删除:%zd",__tag);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return true;
}
- (void)channelLongGesture:(UILongPressGestureRecognizer * _Nonnull)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按手势");
    }
}

// setter method
- (void)setOtherSource:(NSArray *)otherSource {
    if (_otherSource) {
        _otherSource = nil;
    }
    _otherSource = otherSource;
}

- (void)buildOtherChannels {
    
    //TODO:这里需要考虑iPad
    NSInteger numPerLine = 4;
    CGFloat cap = (PBSCREEN_WIDTH-NHBoundaryOffset*2-NH_ITEM_WIDTH*numPerLine)/(numPerLine-1);
    NSInteger counts = self.otherSource.count;
    if (counts == 0) {
        return;
    }
    NSInteger rows = counts/numPerLine;
    if (counts%numPerLine!=0) {
        rows+=1;
    }
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
}

#pragma mark -- Block Event --

- (void)handleChannelEditorSwitchEvent:(NHSwitchChannel)event {
    _switchBlock = [event copy];
}

@end
