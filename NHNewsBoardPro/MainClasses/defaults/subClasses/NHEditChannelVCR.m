//
//  NHEditChannelVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/29.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHEditChannelVCR.h"
#import "NHEditCNNScroller.h"

@interface NHEditChannelVCR ()<UIGestureRecognizerDelegate>

@property (nullable, nonatomic, strong) NHEditCNNScroller *scrollView;
@property (nonatomic, strong) UILabel *changeFlag,*moreFlag;
@property (nonatomic, strong) UIButton *sortFlag;
@property (nonatomic, assign) BOOL dragEnable;

@property (nonatomic, copy) NSString *selectedChannel;
@property (nonatomic, copy) NHSwitchChannel switchBlock;
@property (nonatomic, copy) NHEditChannel editBlock;
@property (nonatomic, copy) NHSortChannel sortBlock;

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
    
    //self.selectedChannel = PBFormat(@"%@",NHIndexTitle);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)navigationBarActionClose {
    [super navigationBarActionClose];
    
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)dragSortAction {
    
    self.dragEnable = !self.dragEnable;
    [self updateSortDragBtnTitle];
    
    [self.scrollView subNaviEventForSort:self.dragEnable];
}

- (BOOL)canDrag:(NSString * _Nonnull)til {
    
    return ![til isEqualToString:NHNewsForceUpdateChannel];
}

- (void)updateSortDragBtnTitle {
    NSString *title = self.dragEnable?@"完成":@"排序删除";
    [self.sortFlag setTitle:title forState:UIControlStateNormal];
    title = self.dragEnable?@"拖动排序":@"切换栏目";
    self.changeFlag.text = title;
}

//// setter method
//- (void)setExistSource:(NSArray *)existSource {
//    if (_existSource) {
//        _existSource = nil;
//    }
//    _existSource = existSource;
//    
//    [self __initSetupScroll];
//}
//
//// setter method
//- (void)setOtherSource:(NSArray *)otherSource {
//    if (_otherSource) {
//        _otherSource = nil;
//    }
//    _otherSource = otherSource;
//}

- (void)startBuildCnn {
    [self __initSetupScroll];
}

- (void)__initSetupScroll {
    weakify(self)
    CGRect bounds = CGRectMake(0, NHAbove_h+NHSubNavigationBarHeight, PBSCREEN_WIDTH, PBSCREEN_HEIGHT-NHAbove_h-NHSubNavigationBarHeight);
    NHEditCNNScroller *scroll = [[NHEditCNNScroller alloc] initWithFrame:bounds];
    scroll.exists = self.existSource;
    scroll.others = self.otherSource;
    //TODO:需要更改默认选中的title
    [scroll resetSelectedCnnTitle:self.selectedCnn];
    scroll.backgroundColor = NHWhiteColor;
    //长按手势触发
    [scroll handleLongPressTriggerEvent:^(BOOL dragable) {
        strongify(self)
        [self dragSortAction];
    }];
    //增加、删除、选中
    [scroll handleCnnEditEvent:^(NHCnnEditType type, NSUInteger index, NSString * _Nonnull cnn) {
        if (type == NHCnnEditTypeSelect) {
            if (_switchBlock) {
                _switchBlock(index, cnn);
            }
        }else if ((NHCnnEditTypeDelete == type)||(NHCnnEditTypeAdd == type)){
            BOOL add = NHCnnEditTypeAdd == type;
            if (_editBlock) {
                _editBlock(add, index, cnn);
            }
        }
    }];
    //排序
    [scroll handleCnnSortEvent:^(NSUInteger originIdx, NSUInteger destIdx, NSString * _Nonnull cnn) {
        if (_sortBlock) {
            _sortBlock(originIdx, destIdx, cnn);
        }
    }];
    [self.view addSubview:scroll];
    self.scrollView = scroll;
}

#pragma mark -- Block Event --

- (void)handleChannelEditorSwitchEvent:(NHSwitchChannel)event {
    _switchBlock = [event copy];
}

- (void)handleChannelEditorEditEvent:(NHEditChannel)event {
    _editBlock = [event copy];
}

- (void)handleChannelEditorSortEvent:(NHSortChannel)event {
    _sortBlock = [event copy];
}

@end
