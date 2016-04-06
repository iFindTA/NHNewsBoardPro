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

@interface NHEditCNNScroller ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL dragEnable;
/** 长按手势作用域 **/
@property (nonatomic, assign) CGPoint seperatePoint;

@property (nonatomic, copy) NSString *selectedCnn;
@property (nonatomic, strong) NHCnnItem *selectedItem;

@property (nonatomic, strong) NSMutableDictionary *itemKeySets;
@property (nonatomic, strong) NSMutableArray *itemPosits;

//非拖动下 单机状态记录
@pro

@end

@implementation NHEditCNNScroller

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
    [self addGestureRecognizer:longPress];
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
    _itemPosits = [NSMutableArray arrayWithCapacity:0];
    
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
            CGRect tmpBounds = CGRectInset(bounds, 2, 2);
            UIImageView *imgBg = [[UIImageView alloc] initWithFrame:tmpBounds];
            imgBg.image = dragable?bgImg_v:nil;
            [self addSubview:imgBg];
        }
        
        NHCnnItem *tmp = [[NHCnnItem alloc] initWithFrame:bounds];
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
        [self.itemPosits addObject:tmp];
    }];
    
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, NHBoundaryOffset*3+(size.height+cap)*rows-cap);
    self.contentSize = contentSize;
    self.seperatePoint = CGPointMake(0, contentSize.height);
    
    UILabel *flag = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 2, contentSize.height)];
    flag.backgroundColor = [UIColor pb_randomColor];
    [self insertSubview:flag atIndex:0];
}
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
        
        //[self dragSortAction];
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        NSLog(@"long change");
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"long end");
        
        //[self dragSortAction];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touch began");
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"touch moved");
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"touch end");
    
    if (!self.dragEnable) {
        //在非拖动排序的情况下响应
        CGPoint m_point = [[touches anyObject] locationInView:self];
        NHCnnItem *tmp = [self itemForPoint:m_point];
        if (tmp != nil) {
            //触发了单机 切换栏目
            NSLog(@"点击切换栏目:%@",tmp.text);
        }
    }
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"touch cancelled");
}

//根据点击的point寻找item
- (NHCnnItem * _Nullable)itemForPoint:(CGPoint)tmp {
    
    NHCnnItem *m_dst = nil;
    @synchronized (self.itemPosits) {
        for (NHCnnItem *m_tmp in self.itemPosits) {
            CGRect bounds = m_tmp.frame;
            bounds = CGRectInset(bounds, NHBoundaryOffset, NHBoundaryOffset*0.5);
            if (CGRectContainsPoint(bounds, tmp)) {
                m_dst = m_tmp;
                break;
            }
        }
    }
    return m_dst;
}

@end
