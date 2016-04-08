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

@interface NHEditCNNScroller ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL dragEnable;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
/** 长按手势作用域 **/
@property (nonatomic, assign) CGPoint seperatePoint;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemCap;
@property (nonatomic, assign) int numsPerLine;

@property (nonatomic, copy) NSString *selectedCnn;
@property (nonatomic, strong) NHCnnItem *selectedItem;

//@property (nonatomic, strong) NSMutableDictionary *itemKeySets;
//@property (nonatomic, strong) NSMutableArray *itemPosits;

//非拖动下 单机状态记录
/**touch began后记录**/
@property (nonatomic, strong, nullable) NHCnnItem *preTouchItem;

@property (nonatomic, copy) NHDragSortAble event;

//item集合
@property (nonatomic, strong, nullable) NSMutableArray *existItems,*otherItems;
@property (nonatomic, strong) UIView *moreCnnView;

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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    longPress.minimumPressDuration = 1.f;
    longPress.delegate = self;
    //[self addGestureRecognizer:longPress];
    self.longPress = longPress;
    
    //注册观察者
    [self addObserver:self forKeyPath:NH_OBSERVER_KEYPATH options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NH_OBSERVER_KEYPATH]) {
        NSLog(@"keyPath value changed!");
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
    //下方的存储
    if (_otherItems) {
        [_otherItems removeAllObjects];
        _otherItems = nil;
    }
    _otherItems = [NSMutableArray array];
    
    self.itemSize = size;self.numsPerLine = numPerLine;self.itemCap = cap;
    __block CGRect bounds = (CGRect){.origin=CGPointZero,.size = size};
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
    UIImage *bgImg_v = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    weakify(self)
    [self.exists enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        BOOL dragable = [self canDrag:obj];
        BOOL selected = [self isSelected:obj];
        //NSLog(@"building---->%@...",obj);
        UIColor *titleColor = selected?[UIColor redColor]:[UIColor lightGrayColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGPoint origin = CGPointMake(NHBoundaryOffset+(size.width+cap)*__col, NHBoundaryOffset*2+(size.height+cap)*__row);
        bounds.origin = origin;
        
        if (dragable) {
            CGRect tmpBounds = CGRectInset(bounds, 1, 1);
            UIImageView *imgBg = [[UIImageView alloc] initWithFrame:tmpBounds];
            imgBg.image = dragable?bgImg_v:nil;
            [self addSubview:imgBg];
        }
        
        NHCnnItem *tmp = [[NHCnnItem alloc] initWithFrame:bounds];
        //tmp.backgroundColor = [UIColor pb_randomColor];
        tmp.tag = idx;
        tmp.font = titleFont;
        tmp.textColor = titleColor;
        tmp.text = obj;
        tmp.isExist = true;
        tmp.delBtn.tag = idx;
        tmp.bgImg.hidden = !dragable;
        tmp.exclusiveTouch = true;
        //[tmp.delete addTarget:self action:@selector(channelDeleteTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tmp];
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
        UIColor *titleColor = [UIColor lightGrayColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGPoint origin = CGPointMake(NHBoundaryOffset+(size.width+cap)*__col, cur_y+(size.height+cap)*__row);
        bounds.origin = origin;
        
        CGRect tmpBounds = CGRectInset(bounds, 1, 1);
        UIImageView *imgBg = [[UIImageView alloc] initWithFrame:tmpBounds];
        imgBg.image = bgImg_v;
        imgBg.tag = idx;
        [self.moreCnnView addSubview:imgBg];
        
        NHMoreItem *tmp = [[NHMoreItem alloc] initWithFrame:bounds];
        tmp.tag = idx;
        tmp.titleLabel.font = titleFont;
        [tmp setTitle:obj forState:UIControlStateNormal];
        [tmp setTitleColor:titleColor forState:UIControlStateNormal];
        [tmp addTarget:self action:@selector(moreitemTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.moreCnnView addSubview:tmp];
        [self.otherItems addObject:tmp];
    }];
    
    
    
    tmp_point_y += down_height;
    //重置content size
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, tmp_point_y);
    self.contentSize = contentSize;
}

//创建新栏目
- (NHCnnItem *)m_newInstance:(CGRect)bounds _title:(NSString *)title _tag:(NSUInteger)tag {
    NHCnnItem *tmp = [[NHCnnItem alloc] initWithFrame:bounds];
    //tmp.backgroundColor = [UIColor pb_randomColor];
    tmp.tag = tag;
    tmp.font = [UIFont pb_deviceFontForTitle];
    tmp.textColor = [UIColor lightGrayColor];
    tmp.text = title;
    tmp.isExist = true;
    tmp.delBtn.tag = tag;
    tmp.exclusiveTouch = true;
    return tmp;
}

//当点击下方的栏目时 判断是否需要下移更多栏目view
- (BOOL)needMoveDownMoreView {
    NSUInteger counts = [self.exists count];
    return (counts%self.numsPerLine == 0);
}

//下部item点击事件
- (void)moreitemTouchEvent:(NHMoreItem *)item {
    [self tmpEndReceiveTouchEvent];
    
    //是否下移down view
    BOOL need_move = [self needMoveDownMoreView];
    
    NSString *__title = item.titleLabel.text;
    CGRect origin = item.frame;
    CGRect bounds = [self convertRect:origin fromView:self.moreCnnView];
    //NSLog(@"origin:%@---convert:%@",NSStringFromCGRect(origin),NSStringFromCGRect(bounds));
    
    NSUInteger __tag = [self.exists count];
    __block NHCnnItem *tmp = [self m_newInstance:bounds _title:__title _tag:__tag];
    //先添加再隐藏
    [self addSubview:tmp];
    item.hidden = true;
    //最终目的地
    bounds = [self getDestinationBoundsForNew];
    __tag = [item tag];
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
            [tmpArr removeObjectAtIndex:__tag];
            self.others = [tmpArr copy];
            [self adjustMoreItemAfterAddNewChannel:__tag];
        }];
    });
    
    [self startReceiveTouchEvent];
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
            NHMoreItem *tmp = [self.otherItems objectAtIndex:i];
            tmp.tag = i-1;
            NSLog(@"moving:%zd---title:%@",i,tmp.titleLabel.text);
            CGRect tmpBounds = [self getDestinationBoundsForMoreIndex:i-1];
            PBMAINDelay(NH_ANIMATE_DELAY, ^{
                [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
                    tmp.frame = tmpBounds;
                }];
            });
        }
        
        [self.otherItems removeObjectAtIndex:__tag];
    }
    
    NSArray *subviews = [self.moreCnnView subviews];
    [subviews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]] && (obj.tag == tmpCounts-1)) {
            [obj removeFromSuperview];
            *stop = true;
        }
    }];
    
    NSUInteger counts = [self.otherItems count];
    NSUInteger rows = counts/self.numsPerLine;
    if (counts%self.numsPerLine!=0) {
        rows+=1;
    }
    
    CGFloat down_height = NHSubNavigationBarHeight+NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*rows;
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
    weakify(self)
    PBMAINDelay(NH_ANIMATE_DELAY, ^{
        [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
            strongify(self)
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

//更多栏目中 添加后 重新排序剩余item
- (CGRect)getDestinationBoundsForMoreIndex:(NSUInteger)index {
    NSUInteger __idx = index;
    CGRect bounds = (CGRect){.origin=CGPointZero,.size = self.itemSize};
    NSInteger __row = __idx/self.numsPerLine;NSInteger __col = __idx%self.numsPerLine;
    CGPoint origin = CGPointMake(NHBoundaryOffset+(self.itemSize.width+self.itemCap)*__col, NHSubNavigationBarHeight+NHBoundaryOffset*2+(self.itemSize.height+self.itemCap)*__row);
    bounds.origin = origin;
    return bounds;
}

//更新分割点
- (void)updateSeperatePoint {
    NSInteger counts = self.exists.count;
    NSInteger rows = counts/self.numsPerLine;
    if (counts%self.numsPerLine!=0) {
        rows+=1;
    }
    //记录当前分割点
    CGFloat tmp_point_y = NHBoundaryOffset*3+(self.itemSize.height+self.itemCap)*rows-self.itemCap;
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

#pragma mark -- 与外部交互事件
//子导航条上的排序删除按钮
- (void)subNaviEventForSort:(BOOL)sort {
    
    self.dragEnable = sort;
    NSArray *subviews = [self subviews];
    weakify(self)
    [subviews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        if ([obj isKindOfClass:[NHCnnItem class]]) {
            NHCnnItem *item = (NHCnnItem *)obj;
            BOOL t_can = [self canDrag:item.text];
            [item showDelete:(self.dragEnable&&t_can)];
        }
    }];
}

- (void)handleLongPressTriggerEvent:(NHDragSortAble)event {
    _event = [event copy];
}

- (void)afterIntervalInvokeLongPressState {
    //显示delete
    [self subNaviEventForSort:true];
    //通知子导航栏目同步状态
    if (_event) {
        _event(true);
    }
    NSLog(@"long long long press!");
}

- (void)cancelInvokeLongPressState {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(afterIntervalInvokeLongPressState) object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touch began");
    
    CGPoint m_point = [self pointAtTouch:touches];
    if (m_point.y > self.seperatePoint.y) {
        NSLog(@"touch 越界...");
        return;
    }
    //在非排序条件下 才有切换栏目可能
    if (!self.dragEnable) {
        self.preTouchItem = [self itemForPoint:m_point];
    }else{
        //此时在拖动排序情况下 放大效果
        
        NHCnnItem *tmp = [self itemForPoint:m_point];
    }
    
    //尝试实现长按手势:预选中频道&&非拖动频道&&上部的item
    if (self.preTouchItem != nil && !self.dragEnable && m_point.y < self.seperatePoint.y) {
        [self performSelector:@selector(afterIntervalInvokeLongPressState) withObject:nil afterDelay:1.f];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"touch moved");
    //如果有预选的item
    if (self.preTouchItem != nil) {
        CGPoint m_point = [self pointAtTouch:touches];
        CGRect bounds = self.preTouchItem.frame;
        bounds = [self insetsBoundsForTouch:bounds];
        if (!CGRectContainsPoint(bounds, m_point)) {
            [self cleanPreTouchItem];
        }
    }
    [self cancelInvokeLongPressState];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"touch end");
    
    if (!self.dragEnable) {
        //在非拖动排序的情况下响应
        CGPoint m_point = [self pointAtTouch:touches];
        NHCnnItem *tmp = [self itemForPoint:m_point];
        if (tmp != nil && _preTouchItem != nil && tmp.tag == _preTouchItem.tag) {
            //触发了单机 切换栏目
            NSLog(@"点击切换栏目:%@",tmp.text);
        }
    }
    
    [self cleanPreTouchItem];
    
    [self cancelInvokeLongPressState];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"touch cancelled");
    [self cleanPreTouchItem];
    
    [self cancelInvokeLongPressState];
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
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (tmpP.y < self.seperatePoint.y && !self.dragEnable) {
            return true;
        }
        return false;
    }else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        if (self.dragEnable) {
            
        }
    }
    
    return true;
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long began");
        
        //长按手势触发
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        NSLog(@"long change");
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"long end");
        
        //[self dragSortAction];
    }
}

@end
