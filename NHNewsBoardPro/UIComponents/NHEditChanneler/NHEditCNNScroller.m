//
//  NHEditCNNScroller.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHEditCNNScroller.h"
#import "NHConstaints.h"
#import "NHCnnItem.h"

#define NH_ANIMATE_DELAY   0.002
#define NH_SCALE_FACTOR    1.09//放大因子

@interface NHEditCNNScroller ()

@property (nonatomic, assign) BOOL dragEnable;

/** 长按手势作用域 **/
@property (nonatomic, assign) CGPoint seperatePoint;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemCap;
@property (nonatomic, assign) int numsPerLine;

@property (nonatomic, copy) NSString *selectedCnn;
//拖动状态下 记录当前选择的item
@property (nonatomic, strong) NHCnnItem *selectedItem;
@property (nonatomic, assign) NSUInteger movingIdx;
//松开后的目的地
@property (nonatomic, assign) CGRect destBounds;

//非拖动下 单机状态记录
/**touch began后记录**/
@property (nonatomic, strong, nullable) NHCnnItem *preTouchItem;

@property (nonatomic, nonnull, copy) NHDragSortAble dragEvent;
@property (nonatomic, nonnull, copy) NHCnnSortEvent sortEvent;
@property (nonatomic, nonnull, copy) NHCnnEditEvent editEvent;

//item集合
@property (nonatomic, strong, nullable) NSMutableArray *existItems,*otherItems;
@property (nonatomic, strong) UIView *moreCnnView;
@property (nonatomic, strong) NSMutableArray *existBgItems;

@end

#define NH_OBSERVER_KEYPATH  @"dragEnable"

@implementation NHEditCNNScroller

- (void)dealloc {
    [self removeObserver:self forKeyPath:NH_OBSERVER_KEYPATH];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    
    //注册观察者
    [self addObserver:self forKeyPath:NH_OBSERVER_KEYPATH options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NH_OBSERVER_KEYPATH]) {
        //NSLog(@"keyPath value changed!");
        BOOL m_new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        //self.longPress.enabled = !m_new;
        
        self.moreCnnView.hidden = m_new;
    }
}

- (void)resetSelectedCnnTitle:(NSString *)title {
    
    self.selectedCnn = [title copy];
    self.dragEnable = false;
    
    [self __buildUI];
}
//该按钮是否可以拖动(默认除了'头条'均不可拖动)
- (BOOL)canDrag:(NSString * _Nonnull)til {
    return ![til isEqualToString:NHNewsForceUpdateChannel];
}
//是否选中当前频道
- (BOOL)isSelected:(NSString * _Nonnull)til {
    return [til isEqualToString:self.selectedCnn];
}
//根据屏幕 计算item size
- (void)caculateItemSize:(CGSize *)size andCap:(CGFloat *)cap numPerLine:(int *)num {
    
    CGSize tmp_size = CGSizeZero;CGFloat tmp_cap = 0;
    int numPerLine = 4;//每行四个item
    CGFloat width_cap_scale = 0.2;
    CGFloat width = (PBSCREEN_WIDTH-NHBoundaryOffset*2)/(numPerLine+(numPerLine-1)*width_cap_scale);
    tmp_cap = width*width_cap_scale;
    CGFloat item_w_h_scale = 0.42;
    tmp_size = CGSizeMake(width, width*item_w_h_scale);
    //赋值
    *size = tmp_size;*cap = tmp_cap;*num = numPerLine;
}
//创建UI
- (UIImageView *)verturalBgForBounds:(CGRect)bounds {
    UIImage *bgImg_v = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    CGRect tmpBounds = CGRectInset(bounds, 1, 1);
    UIImageView *imgBg = [[UIImageView alloc] initWithFrame:tmpBounds];
    imgBg.image = bgImg_v;
    return imgBg;
}
//#define NH_ITEM_WIDTH     70
//#define NH_ITEM_HEIGHT    30
- (void)__buildUI {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //TODO:这里需要考虑iPad
    NSInteger counts = self.exists.count;
    if (counts == 0) {
        return;
    }
    //计算宽度和间隙
    int numPerLine;CGFloat cap;CGSize size;
    [self caculateItemSize:&size andCap:&cap numPerLine:&numPerLine];
    NSInteger rows = counts/numPerLine;
    if (counts%numPerLine!=0) {
        rows+=1;
    }
    
    //用来存item
    //_itemPosits = [NSMutableArray arrayWithCapacity:0];
    if (_existItems) {
        [_existItems removeAllObjects];
        _existItems = nil;
    }
    _existItems = [NSMutableArray array];
    //上方背景的存储
    if (_existBgItems) {
        [_existBgItems removeAllObjects];
        _existBgItems = nil;
    }
    _existBgItems = [NSMutableArray array];
    //下方的存储
    if (_otherItems) {
        [_otherItems removeAllObjects];
        _otherItems = nil;
    }
    _otherItems = [NSMutableArray array];
//    //下方背景的存储
//    if (_moreBgItems) {
//        [_moreBgItems removeAllObjects];
//        _moreBgItems = nil;
//    }
//    _moreBgItems = [NSMutableArray array];
    
    self.itemSize = size;self.numsPerLine = numPerLine;self.itemCap = cap;
    __block CGRect bounds = (CGRect){.origin=CGPointZero,.size = size};
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
    UIImage *bgImg_v = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    weakify(self)
    [self.exists enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        BOOL dragable = [self canDrag:obj];
        BOOL selected = [self isSelected:obj];
        NSLog(@"building---->%@...",obj);
        UIColor *titleColor = selected?[UIColor redColor]:[UIColor lightGrayColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGPoint origin = CGPointMake(NHBoundaryOffset+(size.width+cap)*__col, NHBoundaryOffset*2+(size.height+cap)*__row);
        bounds.origin = origin;
        
        if (dragable) {
            CGRect tmpBounds = CGRectInset(bounds, 1, 1);
            UIImageView *imgBg = [[UIImageView alloc] initWithFrame:tmpBounds];
            imgBg.image = dragable?bgImg_v:nil;
            [self insertSubview:imgBg atIndex:0];
            [self.existBgItems addObject:imgBg];
        }
        
        NHCnnItem *tmp = [[NHCnnItem alloc] initWithFrame:bounds];
        //tmp.backgroundColor = [UIColor pb_randomColor];
        tmp.tag = idx;
        tmp.title = obj;
        tmp.isExist = true;
        tmp.titleColor = titleColor;
        tmp.exclusiveTouch = true;
        [tmp hiddenBgImg:!dragable];
        //[tmp.delBtn addTarget:self action:@selector(channelDeleteTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [tmp addTarget:self forAction:@selector(channelDeleteTouchEvent:)];
        [self insertSubview:tmp atIndex:10];
        [self.existItems addObject:tmp];
    }];
    
    //更新当前分割点
    [self updateSeperatePoint];
    CGFloat tmp_point_y = NHBoundaryOffset*3+(size.height+cap)*rows-cap;
    
//    UILabel *flag = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 2, tmp_point_y)];
//    flag.backgroundColor = [UIColor pb_randomColor];
//    [self insertSubview:flag atIndex:0];
    
    //中部及下部
    counts = [self.others count];
    rows = counts/numPerLine;
    if (counts%numPerLine!=0) {
        rows+=1;
    }
    
    CGFloat down_height = NHSubNavigationBarHeight+NHBoundaryOffset*2+(size.height+cap)*rows;
    bounds = CGRectMake(0, tmp_point_y, PBSCREEN_WIDTH, down_height);
    UIView *tmp = [[UIView alloc] initWithFrame:bounds];
    [self addSubview:tmp];
    _moreCnnView = tmp;
    
    //中部导航
    bounds = CGRectMake(0, 0, PBSCREEN_WIDTH, NHSubNavigationBarHeight);
    UIImageView *subNavi = [[UIImageView alloc] initWithFrame:bounds];
    subNavi.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [self.moreCnnView addSubview:subNavi];
    
    UILabel *label = [[UILabel alloc] init];
    //label.backgroundColor = UIColorFromRGB(0xE6E6E6);
    label.font = titleFont;
    label.text = PBFormat(@"%@",@"点击添加更多栏目");
    [subNavi addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(subNavi).insets(UIEdgeInsetsMake(0, NHBoundaryOffset, 0, -NHBoundaryOffset));
    }];
    
    CGFloat cur_y = NHSubNavigationBarHeight+NHBoundaryOffset*2;
    bounds = (CGRect){.origin=CGPointZero,.size = size};
    //下部item
    [self.others enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        //NSLog(@"building---->%@...",obj);
        //UIColor *titleColor = [UIColor lightGrayColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGPoint origin = CGPointMake(NHBoundaryOffset+(size.width+cap)*__col, cur_y+(size.height+cap)*__row);
        bounds.origin = origin;
        
        //UIImageView *imgBg = [self verturalBgForBounds:bounds];
        //[self.moreCnnView addSubview:imgBg];
        //[self.moreBgItems addObject:imgBg];
        
//        NHMoreItem *tmp = [[NHMoreItem alloc] initWithFrame:bounds];
//        tmp.tag = idx;
//        tmp.titleLabel.font = titleFont;
//        [tmp setTitle:obj forState:UIControlStateNormal];
//        [tmp setTitleColor:titleColor forState:UIControlStateNormal];
//        [tmp addTarget:self action:@selector(moreitemTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
//        [self.moreCnnView addSubview:tmp];
//        [self.otherItems addObject:tmp];
        
        NHOtherCnnItem *tmp = [[NHOtherCnnItem alloc] initWithFrame:bounds];
        tmp.tag = idx;
        tmp.title = obj;
        [tmp addTarget:self forAction:@selector(moreitemTouchEvent:)];
        [self.moreCnnView addSubview:tmp];
        [self.otherItems addObject:tmp];
    }];
    
    tmp_point_y += down_height;
    //重置content size
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, tmp_point_y);
    self.contentSize = contentSize;
}

//创建新栏目
- (NHCnnItem *)m_newExistCnn:(CGRect)bounds _title:(NSString *)title _tag:(NSUInteger)tag {
    NHCnnItem *tmp = [[NHCnnItem alloc] initWithFrame:bounds];
    //tmp.backgroundColor = [UIColor pb_randomColor];
    tmp.tag = tag;
    tmp.title = title;
    tmp.isExist = true;
    tmp.titleColor = [UIColor lightGrayColor];
    tmp.exclusiveTouch = true;
    //[tmp.delBtn addTarget:self action:@selector(channelDeleteTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tmp addTarget:self forAction:@selector(channelDeleteTouchEvent:)];
    return tmp;
}

//创建新的待订阅栏目
- (NHOtherCnnItem *)m_newOtherCnn:(CGRect)bounds _title:(NSString *)title _tag:(NSUInteger)tag {
    NHOtherCnnItem *tmp = [[NHOtherCnnItem alloc] initWithFrame:bounds];
    tmp.tag = tag;
    tmp.title = title;
    [tmp addTarget:self forAction:@selector(moreitemTouchEvent:)];
    return tmp;
}

//当点击下方的栏目时 判断是否需要下移更多栏目view
- (BOOL)needMoveDownMoreView {
    NSUInteger counts = [self.exists count];
    return (counts%self.numsPerLine == 0);
}
#pragma mark -- 添加栏目
//下部item点击事件:添加栏目
- (void)moreitemTouchEvent:(UIButton *)item {
    [self tmpEndReceiveTouchEvent];
    
    //是否下移down view
    NSUInteger __exist_counts = [self.exists count];
    BOOL need_move = [self needMoveDownMoreView];
    
    NSUInteger __tag__ = item.tag;
    NHOtherCnnItem *add_tmp = [self.otherItems objectAtIndex:__tag__];
    NSString *__title = add_tmp.title;
    CGRect origin = add_tmp.frame;
    CGRect bounds = [self convertRect:origin fromView:self.moreCnnView];
    //NSLog(@"origin:%@---convert:%@",NSStringFromCGRect(origin),NSStringFromCGRect(bounds));
    
    NSUInteger __tag = [self.exists count];
    __block NHCnnItem *tmp = [self m_newExistCnn:bounds _title:__title _tag:__tag];
    //先添加再隐藏 最后移除
    [self addSubview:tmp];
    [add_tmp hiddenTitle:true];
    
    //最终目的地
    bounds = [self getDestinationBoundsForNew];
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        
        if (need_move) {
            strongify(self)
            CGRect _origin = self.moreCnnView.frame;
            _origin.origin.y += (self.itemSize.height+self.itemCap);
            weakify(self)
            [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                strongify(self)
                self.moreCnnView.frame = _origin;
            }];
        }
        
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            tmp.frame = bounds;
        } completion:^(BOOL finished) {
            strongify(self)
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.exists];
            [tmpArr addObject:__title];
            self.exists = [tmpArr copy];
            [self.existItems addObject:tmp];
            tmpArr = [NSMutableArray arrayWithArray:self.others];;
            [tmpArr removeObjectAtIndex:__tag__];
            self.others = [tmpArr copy];
            UIImageView *tmpBg = [self verturalBgForBounds:bounds];
            [self insertSubview:tmpBg atIndex:0];
            [self.existBgItems addObject:tmpBg];
            [self adjustMoreItemAfterAddNewChannel:__tag__];
            
            [add_tmp removeFromSuperview];
            if (finished) {
                [self startReceiveTouchEvent];
            }
        }];
    });
    
    //通知添加了栏目
    if (_editEvent) {
        //NSLog(@"添加了栏目:%@",__title);
        _editEvent(NHCnnEditTypeAdd,__exist_counts, __title);
    }
}

//添加完毕新频道后 调整下方的moreview
- (void)adjustMoreItemAfterAddNewChannel:(NSUInteger)__tag {
    
    NSUInteger tmpCounts = [self.otherItems count];
    if (__tag >= tmpCounts) {
        NSLog(@"\"%s\" occured error!",__FUNCTION__);
        return;
    }
    
    NSLog(@"__tag:%zd-----__count:%zd",__tag,tmpCounts);
    @synchronized (self.otherItems) {
        for (int i = __tag+1; i < tmpCounts; i++) {
            NHOtherCnnItem *tmp = [self.otherItems objectAtIndex:i];
            tmp.tag = i-1;
            //NSLog(@"moving:%zd---title:%@",i,tmp.titleLabel.text);
            CGRect tmpBounds = [self getDestinationBoundsForMoreIndex:i-1];
            [self animateWithView:tmp destBounds:tmpBounds];
        }
        
        [self.otherItems removeObjectAtIndex:__tag];
    }
    
    NSUInteger counts = [self.otherItems count];
    NSUInteger rows = counts/self.numsPerLine;
    if (counts%self.numsPerLine!=0) {
        rows+=1;
    }
    
    CGFloat down_height = [self getOtherCnnHeight];
    CGRect bounds = self.moreCnnView.frame;
    bounds.size.height = down_height;
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
            self.moreCnnView.frame = bounds;
        }];
    });
    
    CGFloat cont_h = bounds.origin.y+down_height;
    //重置content size
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, cont_h);
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
            self.contentSize = contentSize;
        }];
    });
    
    //更新当前分割点
    [self updateSeperatePoint];
}

//统一动画
- (void)animateWithView:(UIView * _Nonnull)tmp destBounds:(CGRect)bounds {
    //weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            //strongify(self)
            tmp.frame = bounds;
        }];
    });
}
//获取新订阅栏目的最终目标位置
- (CGRect)getDestinationBoundsForNew {
    NSInteger counts = self.exists.count;
    NSUInteger __idx = counts;
    CGRect bounds = (CGRect){.origin=CGPointZero,.size = self.itemSize};
    NSInteger __row = __idx/self.numsPerLine;NSInteger __col = __idx%self.numsPerLine;
    CGPoint origin = CGPointMake(NHBoundaryOffset+(self.itemSize.width+self.itemCap)*__col, NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*__row);
    bounds.origin = origin;
    return bounds;
}

//更多栏目中 减少后 重新排序剩余item
- (CGRect)getDestinationBoundsForMoreIndex:(NSUInteger)index {
    NSUInteger __idx = index;
    CGRect bounds = (CGRect){.origin=CGPointZero,.size = self.itemSize};
    NSInteger __row = __idx/self.numsPerLine;NSInteger __col = __idx%self.numsPerLine;
    CGPoint origin = CGPointMake(NHBoundaryOffset+(self.itemSize.width+self.itemCap)*__col, NHSubNavigationBarHeight+NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*__row);
    bounds.origin = origin;
    return bounds;
}

//已订阅栏目中 删除后 重新排序剩余item
- (CGRect)getDestinationBoundsForExistIndex:(NSUInteger)index {
    NSUInteger __idx = index;
    CGRect bounds = (CGRect){.origin=CGPointZero,.size = self.itemSize};
    NSInteger __row = __idx/self.numsPerLine;NSInteger __col = __idx%self.numsPerLine;
    CGPoint origin = CGPointMake(NHBoundaryOffset+(self.itemSize.width+self.itemCap)*__col, NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*__row);
    bounds.origin = origin;
    return bounds;
}

//更新分割点
- (void)updateSeperatePoint {
    //记录当前分割点
    CGFloat tmp_point_y = [self getExistCnnHeight];
    self.seperatePoint = CGPointMake(0, tmp_point_y);
}

//开始接收点击
- (void)startReceiveTouchEvent {
    self.userInteractionEnabled = true;
}
//关闭接收点击
- (void)tmpEndReceiveTouchEvent {
    self.userInteractionEnabled = false;
}
#pragma mark -- 删除栏目 -- 

//当点击栏目的X按钮时 判断是否需要上移更多栏目view
- (BOOL)needMoveUpMoreView {
    NSUInteger counts = [self.exists count];
    return (counts%self.numsPerLine == 1);
}

- (void)channelDeleteTouchEvent:(UIButton *)tmp {
    
    NSUInteger __exist_counts = [self.existItems count];
    NSUInteger __tag = tmp.tag;
    if (__exist_counts <= __tag) {
        NSLog(@"delete channel occured error!");
        return;
    }
    
    //停止接收点击事件
    [self tmpEndReceiveTouchEvent];
    
    BOOL need_move = [self needMoveUpMoreView];
    NHCnnItem *tmp_cnn = [self.existItems objectAtIndex:__tag];
    NSString *__title = [tmp_cnn title];
    NSLog(@"取消订阅栏目:%@",__title);
    
    //渐隐消失
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            tmp_cnn.alpha = 0;
        } completion:^(BOOL finished) {
            [tmp_cnn removeFromSuperview];
            
            if (need_move) {
                strongify(self)
                CGRect _origin = self.moreCnnView.frame;
                _origin.origin.y -= (self.itemSize.height+self.itemCap);
                weakify(self)
                [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                    strongify(self)
                    self.moreCnnView.frame = _origin;
                }];
            }
        }];
    });
    
    [self adjustExistItems:__tag];
    
    //加入下部更多栏目
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.others];
    [tmpArr insertObject:__title atIndex:0];
    self.others = [tmpArr copy];
    [self relayoutMoreCnnView];
    
    //通知取消订阅
    if (_editEvent) {
        _editEvent(NHCnnEditTypeDelete,__tag,__title);
    }
    //开始接收点击事件
    [self startReceiveTouchEvent];
}

- (void)adjustExistItems:(NSUInteger)__tag {
    
    NSUInteger __exist_counts = [self.exists count];
    
    @synchronized (self.existItems) {
        for (int i = __tag+1; i < __exist_counts; i++) {
            NHCnnItem *tmp = [self.existItems objectAtIndex:i];
            tmp.tag = i-1;
            //tmp.delBtn.tag = i-1;
            CGRect bounds = [self getDestinationBoundsForExistIndex:i-1];
            [self animateWithView:tmp destBounds:bounds];
        }
        
        [self.existItems removeObjectAtIndex:__tag];
    }
    
    //删除最后一个虚线框
    UIImageView *tmpBg = [self.existBgItems lastObject];
    [tmpBg removeFromSuperview];
    [self.existBgItems removeLastObject];
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.exists];
    [tmpArr removeObjectAtIndex:__tag];
    self.exists = [tmpArr copy];
}

- (void)relayoutMoreCnnView {
    
    CGFloat down_height = [self getOtherCnnHeight];
    CGRect bounds = self.moreCnnView.frame;
    bounds.size.height = down_height;
    self.moreCnnView.frame = bounds;
    
    //新增栏目
    NSUInteger __tag = 0;
    NSString *title = [self.others firstObject];
    bounds = [self getDestinationBoundsForMoreIndex:__tag];
    NHOtherCnnItem *add_tmp = [self m_newOtherCnn:bounds _title:title _tag:__tag];
    [self.moreCnnView addSubview:add_tmp];
    NSUInteger __other_counts = [self.otherItems count];
    @synchronized (self.otherItems) {
        for (int i = __tag; i < __other_counts; i++) {
            NHOtherCnnItem *tmp = [self.otherItems objectAtIndex:i];
            tmp.tag = i+1;
            //NSLog(@"moving:%zd---title:%@",i,tmp.titleLabel.text);
            CGRect tmpBounds = [self getDestinationBoundsForMoreIndex:i+1];
            [self animateWithView:tmp destBounds:tmpBounds];
        }
        
        [self.otherItems insertObject:add_tmp atIndex:__tag];
    }
    
    CGFloat cont_h = bounds.origin.y+down_height;
    //重置content size
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, cont_h);
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
            self.contentSize = contentSize;
        }];
    });
    
    //更新当前分割点
    [self updateSeperatePoint];
}

- (void)existItemDragEvent:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"exist item drag start...");
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        NSLog(@"exist item drag change...");
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"exist item drag end...");
    }
}

#pragma mark -- 排序栏目 --
#define NH_AUTO_SCROLL_OFFSET   10
#define NH_AUTO_SCROLL_STEP     2
//实时检测当前point
- (void)checkTouchPoint:(CGPoint)point {
    
    NSUInteger __tag = self.movingIdx;
    @synchronized (self.existItems) {
        weakify(self)
        [self.existItems enumerateObjectsUsingBlock:^(NHCnnItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            strongify(self)
            NSUInteger __tag__ = obj.tag;
            CGRect bounds = [obj frame];
            bounds = [self insetsBoundsForTouch:bounds];
            if (CGRectContainsPoint(bounds, point)) {
                if (__tag__ != __tag && __tag__ != 0) {
                    NSString *_title = obj.title;
                    //NSLog(@"将与%@交换位置:%zd...",_title,__tag__);
                    //通知事件block
                    if (_sortEvent) {
                        _sortEvent(__tag, __tag__, _title);
                    }
                    //更新目的地
                    self.destBounds = obj.frame;
                    [self animateSort:__tag destIndex:__tag__];
                    *stop = true;
                }
            }
        }];
    }
    
    [self autoCheckIfNeedScroll:point];
}
//scrollView size 较大时 需要滚动
- (void)autoCheckIfNeedScroll:(CGPoint)point {
    CGFloat __tmp_con_height = [self getExistCnnHeight];
    CGFloat __tmp_fra_height = CGRectGetHeight(self.bounds);
    
    if (!self.dragEnable && __tmp_con_height <= __tmp_fra_height) {
        return;
    }
    CGPoint offset = self.contentOffset;
    //NSLog(@"pan===%f---%@&%f&%f",offset.y+point.y,NSStringFromCGSize(contentSize),__tmp_con_height,__tmp_fra_height);
    int abs_offset = fabs(__tmp_fra_height-point.y);
    if (abs_offset < NH_AUTO_SCROLL_OFFSET) {
        //should move uping
        if (offset.y+__tmp_fra_height >= __tmp_con_height) {
            return;
        }
        //offset.y += NH_AUTO_SCROLL_STEP;
        //一步到位
        offset.y = __tmp_con_height-__tmp_fra_height;
        weakify(self)
        PBMAINDelay(NH_ANIMATE_DELAY, ^{
            strongify(self)
            [self setContentOffset:offset animated:true];
            //[self autoCheckIfNeedScroll:point];
        });
    }else{
        abs_offset = fabs(point.y-offset.y);
        if (abs_offset < NH_AUTO_SCROLL_OFFSET) {
            if (offset.y <= 0) {
                return;
            }
            //offset.y -= NH_AUTO_SCROLL_STEP;
            //一步到位
            offset = CGPointZero;
            weakify(self)
            PBMAINDelay(NH_ANIMATE_DELAY, ^{
                strongify(self)
                [self setContentOffset:offset animated:true];
                //[self autoCheckIfNeedScroll:point];
            });
        }
    }
}

- (void)animateSort:(NSUInteger)origin destIndex:(NSUInteger)destIdx {
    
    if (origin < destIdx) {
        //开始时在前边 需要后移
        @synchronized (self.existItems) {
            for (int i = origin; i <= destIdx; i++) {
                NHCnnItem *tmp = [self.existItems objectAtIndex:i];
                NSUInteger __tag = i-1;
                if (i == origin) {
                    __tag = destIdx;
                }
                CGRect bounds = [self getDestinationBoundsForExistIndex:__tag];
                tmp.tag = __tag;
                //tmp.delBtn.tag = __tag;
                [self animateWithView:tmp destBounds:bounds];
            }
        }
    }else{
        //开始在后边 需要前移
        @synchronized (self.existItems) {
            for (int i = destIdx; i <= origin; i++) {
                NHCnnItem *tmp = [self.existItems objectAtIndex:i];
                NSUInteger __tag = i+1;
                if (i == origin) {
                    __tag = destIdx;
                }
                CGRect bounds = [self getDestinationBoundsForExistIndex:__tag];
                tmp.tag = __tag;
                //tmp.delBtn.tag = __tag;
                [self animateWithView:tmp destBounds:bounds];
            }
        }
    }
    
    self.movingIdx = destIdx;
    //self.selectedItem.tag = destIdx;
    //self.selectedItem.delBtn.tag = destIdx;
    //数组排序
    NHCnnItem *tmp = [self.existItems objectAtIndex:origin];
    //tmp.tag = destIdx;
    //tmp.delBtn.tag = destIdx;
    //tmp.frame = self.destBounds;
    [self.existItems removeObjectAtIndex:origin];
    [self.existItems insertObject:tmp atIndex:destIdx];
    //栏目排序
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.exists];
    NSString *tmp_title = [tmpArr objectAtIndex:origin];
    [tmpArr removeObjectAtIndex:origin];
    [tmpArr insertObject:tmp_title atIndex:destIdx];
    self.exists = [tmpArr copy];
    
    NSLog(@"当前订阅栏目counts:%zd==%zd",self.exists.count,self.existItems.count);
}

#pragma mark -- 切换栏目 --
//已在touch end事件里实现

#pragma mark -- 长按触发排序、删除动作 --
//子导航条上的排序删除按钮
- (void)subNaviEventForSort:(BOOL)sort {
    
    self.dragEnable = sort;
    NSArray *subviews = [self subviews];
    weakify(self)
    [subviews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        if ([obj isKindOfClass:[NHCnnItem class]]) {
            NHCnnItem *item = (NHCnnItem *)obj;
            BOOL t_can = [self canDrag:item.title];
            [item showDelete:(self.dragEnable&&t_can)];
        }
    }];
    
    [self adjustInnerContentSize];
    
    //处于编辑状态时 字体均为灰色 结束排序时再选中对应的栏目
    [self updateSubscribedCnnsTitleColor];
}

//更新当前选中的栏目标题
- (void)updateCurrentSelectCnn:(NSString * _Nonnull)_title {
    
    if (_selectedCnn != nil) {
        _selectedCnn = nil;
    }
    _selectedCnn = [_title copy];
    [self updateSubscribedCnnsTitleColor];
}

//更新已订阅栏目标题的颜色
- (void)updateSubscribedCnnsTitleColor {
    
    @synchronized (self.existItems) {
        for (NHCnnItem *tmp in self.existItems) {
            BOOL selected = [self isSelected:tmp.title];
            selected &= !self.dragEnable;
            //NSLog(@"building---->%@...",obj);
            UIColor *titleColor = selected?[UIColor redColor]:[UIColor lightGrayColor];
            tmp.titleColor = titleColor;
        }
    }
    
}

- (CGFloat)getExistCnnHeight {
    NSUInteger __exist_counts = [self.exists count];
    NSInteger rows = __exist_counts/self.numsPerLine;
    if (__exist_counts%self.numsPerLine!=0) {
        rows+=1;
    }
    CGFloat up_height = NHBoundaryOffset*3+(self.itemSize.height+self.itemCap)*rows-self.itemCap;
    return up_height;
}

- (CGFloat)getOtherCnnHeight {
    NSUInteger counts = [self.others count];
    NSUInteger rows = counts/self.numsPerLine;
    if (counts%self.numsPerLine!=0) {
        rows+=1;
    }
    CGFloat down_height = NHSubNavigationBarHeight+NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*rows;
    return down_height;
}

//调整self 的content size
- (void)adjustInnerContentSize {
    
    CGFloat up_height = [self getExistCnnHeight];

    CGFloat down_height = self.moreCnnView.hidden?0:CGRectGetHeight(self.moreCnnView.bounds);
    //重置content size
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, up_height+down_height);
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
            self.contentSize = contentSize;
        }];
    });
    
    //更新当前分割点
    [self updateSeperatePoint];
}

#pragma mark -- 与外部交互事件
- (void)handleLongPressTriggerEvent:(NHDragSortAble)event {
    _dragEvent = [event copy];
}

- (void)handleCnnSortEvent:(NHCnnSortEvent)event {
    _sortEvent = [event copy];
}

- (void)handleCnnEditEvent:(NHCnnEditEvent)event {
    _editEvent = [event copy];
}

#pragma mark -- Touch 事件 --
- (void)afterIntervalInvokeLongPressState {
    //显示delete
    [self subNaviEventForSort:true];
    //通知子导航栏目同步状态
    if (_dragEvent) {
        _dragEvent(true);
    }
    NSLog(@"long long long press!");
    
    //依当前的选择的preTouch为selectItem
    if (_preTouchItem != nil && _preTouchItem.tag != 0) {
        CGRect bounds = _preTouchItem.frame;
        self.destBounds = bounds;
        self.movingIdx = _preTouchItem.tag;
        //创建一个新的cnn 然后隐藏真正的cnn
        NHCnnItem *m_new = [self m_newExistCnn:bounds _title:_preTouchItem.title _tag:_preTouchItem.tag];
        [m_new showDelete:true];
        [self addSubview:m_new];
        self.selectedItem = m_new;
        _preTouchItem.hidden = true;
        
        NSLog(@"origin bounds:%@",NSStringFromCGRect(self.destBounds));
        weakify(self)
        PBMAINDelay(NH_ANIMATE_DELAY, ^{
            [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, NH_SCALE_FACTOR, NH_SCALE_FACTOR);
                strongify(self)
                UIFont *oldFont = [UIFont pb_deviceFontForTitle];
                UIFont *m_font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize*NH_SCALE_FACTOR];
                self.selectedItem.font = m_font;
                self.selectedItem.transform = transform;
            }];
        });
    }
}

- (void)cancelInvokeLongPressState {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(afterIntervalInvokeLongPressState) object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //NSLog(@"touch began");
    
    CGPoint m_point = [self pointAtTouch:touches];
    if (m_point.y > self.seperatePoint.y) {
        //NSLog(@"touch 越界...");
        return;
    }
    //在非排序条件下 才有切换栏目可能
    if (!self.dragEnable) {
        self.preTouchItem = [self itemForPoint:m_point];
    }else{
        //此时在拖动排序情况下 放大效果
        NHCnnItem *tmp = [self itemForPoint:m_point];
        if (tmp != nil && tmp.tag != 0) {
            CGRect bounds = tmp.frame;
            self.destBounds = bounds;
            self.movingIdx = tmp.tag;
            //创建一个新的cnn 然后隐藏真正的cnn
            NHCnnItem *m_new = [self m_newExistCnn:bounds _title:tmp.title _tag:tmp.tag];
            [m_new showDelete:true];
            [self addSubview:m_new];
            self.selectedItem = m_new;
            tmp.hidden = true;
            
            //NSLog(@"origin bounds:%@",NSStringFromCGRect(self.destBounds));
            weakify(self)
            PBMAINDelay(NH_ANIMATE_DELAY, ^{
                [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, NH_SCALE_FACTOR, NH_SCALE_FACTOR);
                    strongify(self)
                    UIFont *oldFont = [UIFont pb_deviceFontForTitle];
                    UIFont *m_font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize*NH_SCALE_FACTOR];
                    self.selectedItem.font = m_font;
                    self.selectedItem.transform = transform;
                }];
            });
            
            [self updateScrollPanGestureState];
        }
    }
    
    //尝试实现长按手势:预选中频道&&非拖动频道&&上部的item
    if (self.preTouchItem != nil && !self.dragEnable && m_point.y < self.seperatePoint.y) {
        [self performSelector:@selector(afterIntervalInvokeLongPressState) withObject:nil afterDelay:1.f];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    //NSLog(@"touch moved");
    //如果有预选的item
    CGPoint m_point = [self pointAtTouch:touches];
    if (self.preTouchItem != nil) {
        CGRect bounds = self.preTouchItem.frame;
        bounds = [self insetsBoundsForTouch:bounds];
        if (!CGRectContainsPoint(bounds, m_point)) {
            [self cleanPreTouchItem];
        }
    }
    
    if (self.dragEnable  && self.selectedItem != nil) {
        //自动滚动可视区域
        self.selectedItem.center = m_point;
        PBBACK(^{[self checkTouchPoint:m_point];});
    }
    
    [self cancelInvokeLongPressState];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    //NSLog(@"touch end");
    
    if (!self.dragEnable) {
        //在非拖动排序的情况下响应
        CGPoint m_point = [self pointAtTouch:touches];
        NHCnnItem *tmp = [self itemForPoint:m_point];
        if (tmp != nil && _preTouchItem != nil && tmp.tag == _preTouchItem.tag) {
            //触发了单机 切换栏目
            //NSLog(@"点击切换栏目:%@",tmp.text);
            NSString * _tmp = tmp.title;
            if (![_tmp isEqualToString:self.selectedCnn]) {
                [self updateCurrentSelectCnn:[_tmp copy]];
                if (_editEvent) {
                    _editEvent(NHCnnEditTypeSelect, tmp.tag, [_tmp copy]);
                }
            }
        }
    }else{
        [self resetCurrentSelectedItemWhenTouchRelease];
    }
    
    [self cleanPreTouchItem];
    
    [self cancelInvokeLongPressState];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    //NSLog(@"touch cancelled");
    if (self.dragEnable) {
        [self resetCurrentSelectedItemWhenTouchRelease];
    }
    
    [self cleanPreTouchItem];
    
    [self cleanSelectItem];
    
    [self cancelInvokeLongPressState];
}

//TODO:当处于拖动状态时 size如果大于frame 则可能会冲突
//方案1:当状态切换到排序时 如果此时选中item则禁用/启用panGesture end则启用
- (void)updateScrollPanGestureState {
    
    if (self.dragEnable && (self.selectedItem != nil)) {
        CGFloat __tmp_con_height = [self getExistCnnHeight];
        CGFloat __tmp_fra_height = CGRectGetHeight(self.bounds);
        BOOL __enable = (__tmp_fra_height < __tmp_con_height) ;
        self.panGestureRecognizer.enabled = !__enable;
        //NSLog(@"panGesture enabled:%zd",__enable);
    }else{
        self.panGestureRecognizer.enabled = true;
    }
}

//重置当前拖动的item when:end/cancel
- (void)resetCurrentSelectedItemWhenTouchRelease {
    //拖动结束
    //        if (self.selectedItem) {
    //            NSLog(@"end end end:%@ ...",NSStringFromCGRect(self.destBounds));
    //        }
    weakify(self)
    PBMAIN( ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
            UIFont *oldFont = [UIFont pb_deviceFontForTitle];
            self.selectedItem.font = oldFont;
            self.selectedItem.transform = CGAffineTransformIdentity;
            self.selectedItem.frame = self.destBounds;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                strongify(self)
                NHCnnItem *m_old = [self.existItems objectAtIndex:self.movingIdx];
                m_old.hidden = false;
                if (finished) {
                    [self cleanSelectItem];
                    [self updateScrollPanGestureState];
                }
            }];
        }];
    });
}

#pragma mark -- Util Methods --
- (CGRect)insetsBoundsForTouch:(CGRect)bounds {
    return CGRectInset(bounds, NHBoundaryOffset, NHBoundaryOffset*0.5);
}
- (CGPoint)pointAtTouch:(NSSet<UITouch *> *)touchs {
    return [[touchs anyObject] locationInView:self];
}
//touch cancel/move/end 后置空
- (void)cleanPreTouchItem {
    _preTouchItem = nil;
}

- (void)cleanSelectItem {
    [_selectedItem removeFromSuperview];
    _selectedItem = nil;
}

//根据点击的point寻找item
- (NHCnnItem * _Nullable)itemForPoint:(CGPoint)tmp {
    
    NHCnnItem *m_dst = nil;
    @synchronized (self.existItems) {
        for (NHCnnItem *m_tmp in self.existItems) {
            CGRect bounds = m_tmp.frame;
            bounds = [self insetsBoundsForTouch:bounds];
            if (CGRectContainsPoint(bounds, tmp)) {
                m_dst = m_tmp;
                break;
            }
        }
    }
    return m_dst;
}






#pragma mark -- UIGesture Delegate --

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tmpP = [gestureRecognizer locationInView:self];
    
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (tmpP.y < self.seperatePoint.y && !self.dragEnable) {
//            return true;
//        }
//        return false;
//    }else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
//        if (self.dragEnable) {
//            
//        }
//    }
    
    return true;
}

@end
