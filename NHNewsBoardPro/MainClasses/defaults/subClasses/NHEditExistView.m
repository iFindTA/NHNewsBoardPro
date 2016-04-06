//
//  NHEditExistView.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/5.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHEditExistView.h"
#import "NHConstaints.h"

@interface NHItemChannel ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, strong) NSMutableDictionary *itemKeySets;
@property (nonatomic, strong) NSMutableArray *itemPosits;

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
    self.bgImg = bg;
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
    self.longGesture = longGesture;
}

- (void)showDelete:(BOOL)show {
    if (self.isExist) {
        self.delete.hidden = !show;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.titleLabel.font = font;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)channelLongGesture:(UILongPressGestureRecognizer * _Nonnull)gesture {
    
    [self doesNotRecognizeSelector:_cmd];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__FUNCTION__);
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__FUNCTION__);
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint _p = [self convertPoint:point toView:self.superview];
    CGRect bounds = self.frame;
    bounds.origin = CGPointMake(_p.x, _p.y);
    self.frame = bounds;
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s",__FUNCTION__);
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__FUNCTION__);
    [super touchesEnded:touches withEvent:event];
}

@end

@interface NHEditExistView ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) NSMutableArray *existSources;
@property (nonatomic, assign) BOOL dragEnable;

@end

@implementation NHEditExistView

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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    [self addGestureRecognizer:longPress];
    self.longPress = longPress;
    
    [self resetGestureState];
}
- (BOOL)canDrag:(NSString * _Nonnull)til {
    
    return ![til isEqualToString:NHNewsForceUpdateChannel];
}
#define NH_ITEM_WIDTH     70
#define NH_ITEM_HEIGHT    30
- (void)buildExistChannels {
    
    //TODO:这里需要考虑iPad
    NSInteger numPerLine = 4;
    CGFloat cap = (PBSCREEN_WIDTH-NHBoundaryOffset*2-NH_ITEM_WIDTH*numPerLine)/(numPerLine-1);
    NSInteger counts = self.existSources.count;
    if (counts == 0) {
        return;
    }
    NSInteger rows = counts/numPerLine;
    if (counts%numPerLine!=0) {
        rows+=1;
    }
    
    CGSize contentSize = CGSizeMake(PBSCREEN_WIDTH, NHBoundaryOffset*2+(NH_ITEM_HEIGHT+cap)*rows);
    CGRect frame = self.frame;
    frame.size = contentSize;
    self.frame = frame;
    
    UIFont *titleFont = [UIFont pb_deviceFontForTitle];
    UIImage *bgImg_v = [UIImage imageNamed:@"channel_compact_placeholder_inactive"];
    weakify(self)
    [self.existSources enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        strongify(self)
        BOOL dragable = [self canDrag:obj];
        
        UIColor *titleColor = dragable?[UIColor lightGrayColor]:[UIColor redColor];
        NSInteger __row = idx/numPerLine;NSInteger __col = idx%numPerLine;
        CGRect bounds = CGRectMake(NHBoundaryOffset+(NH_ITEM_WIDTH+cap)*__col, NHBoundaryOffset*2+(NH_ITEM_HEIGHT+cap)*__row, NH_ITEM_WIDTH, NH_ITEM_HEIGHT);
        if (dragable) {
            UIImageView *imgBg = [[UIImageView alloc] initWithFrame:bounds];
            imgBg.image = dragable?bgImg_v:nil;
            [self addSubview:imgBg];
        }
        
        NHItemChannel *tmp = [[NHItemChannel alloc] initWithFrame:bounds];
        tmp.tag = idx;
        tmp.font = titleFont;
        tmp.titleColor = titleColor;
        tmp.title = obj;
        tmp.isExist = true;
        tmp.delete.tag = idx;
        tmp.bgImg.hidden = !dragable;
        tmp.exclusiveTouch = true;
        [tmp addTarget:self action:@selector(channelSelectedEvent:) forControlEvents:UIControlEventTouchUpInside];
        [tmp.delete addTarget:self action:@selector(channelDeleteTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tmp];
    }];
    
    
}

//点击频道
- (void)channelSelectedEvent:(NHItemChannel *)tmp {
    
    if (self.dragEnable) {
        // 此时正显示删除按钮 所以不可以切换栏目
        return;
    }
//    NSString *tmp_title = tmp.title;
//    if ([tmp_title isEqualToString:self.selectedChannel]) {
//        return;
//    }
//    self.selectedChannel = [tmp_title copy];
//    
//    //excute switch block
//    NSUInteger __tag = tmp.tag;
//    if (self.switchBlock) {
//        self.switchBlock(__tag,self.selectedChannel);
//    }
//    
//    UIColor *titleColor_n = [UIColor lightGrayColor];
//    UIColor *titleColor_s = [UIColor redColor];
//    NSArray *subviews = [self.scrollView subviews];
//    weakify(self)
//    [subviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        strongify(self)
//        if ([obj isKindOfClass:[NHItemChannel class]]) {
//            NHItemChannel *tmp = (NHItemChannel *)obj;
//            if (tmp.isExist) {
//                //点击的是上边的item Event:切换频道
//                BOOL selected = [tmp.title isEqualToString:self.selectedChannel];
//                tmp.titleColor = selected?titleColor_s:titleColor_n;
//            }
//        }
//    }];
}
//点击小叉叉
- (void)channelDeleteTouchEvent:(UIButton *)tmp {
    
    NSUInteger __tag = [tmp tag];
    NSLog(@"你点击删除:%zd",__tag);
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)ges {
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press began");
        
        
        
    }else if (ges.state == UIGestureRecognizerStateChanged){
        NSLog(@"long press changed");
        
        
    }else if (ges.state == UIGestureRecognizerStateEnded){
        NSLog(@"long press ended");
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            
        }];
    }
}
/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch began!");
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch moved");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch end");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch cancelled");
}
//*/

- (void)restartTimerForLongPressDetect {
    
}

- (void)resetGestureState {
    self.longPress.enabled = true;
}

- (void)enableLongPress:(BOOL)enable {
    self.longPress.enabled = enable;
}

- (void)reloadData:(NSArray *)datas {
    
    if (_existSources) {
        [_existSources removeAllObjects];
        _existSources = nil;
    }
    _existSources = [NSMutableArray arrayWithArray:datas];
    
    [self buildExistChannels];
}

@end
