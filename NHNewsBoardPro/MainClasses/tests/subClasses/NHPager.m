//
//  NHPager.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/2/15.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPager.h"

#pragma mark == PlaceHolder View ==

typedef enum {
    NHPageHolderTypeNone,
    NHPageHolderTypeNormal,
    NHPageHolderTypeWiFi
}NHPageHolderType;

typedef void(^NHTouchEvent)(NHPageHolderType type);

@interface NHPageHolder : UIView

- (void)setHolderType:(NHPageHolderType)type;

- (void)handleTouchEvent:(NHTouchEvent)event;

@end

@interface NHPageHolder ()

@property (nonatomic, nullable, copy) NHTouchEvent retEvent;
@property (nonatomic, assign) NHPageHolderType eventType;

@end

@implementation NHPageHolder

- (void)setHolderType:(NHPageHolderType)type {
    
    self.eventType = type;
    
    if (NHPageHolderTypeNormal == type) {
        self.backgroundColor = [UIColor blueColor];
    }else if (NHPageHolderTypeWiFi == type) {
        self.backgroundColor = [UIColor redColor];
    }
    
    [self setNeedsDisplay];
}

- (void)handleTouchEvent:(NHTouchEvent)event {
    _retEvent = [event copy];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_retEvent) {
        _retEvent(_eventType);
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIFont *font = [UIFont pb_deviceFontForTitle];
    NSString *info ;
    if (self.eventType == NHPageHolderTypeNormal) {
        info = @"nothing";
    }else if (NHPageHolderTypeWiFi == self.eventType) {
        info = @"wifi disconnect";
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil];
    [info drawInRect:rect withAttributes:attributes];
}

@end

#pragma mark == NHPager ==

@interface NHPager ()

@property (nullable, nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong, nullable) UITableView *table;
@property (nonatomic, strong, nullable) NHPageHolder *placeHolder;

@property (nullable, nonatomic, strong) NSString *channel;

- (id)initWithFrame:(CGRect)frame withChannel:(NSString *)channel;

@end

@protocol NHPagerProtocol <NSObject>

- (NSString *)channelForDisplaying;

@end

@implementation NHPager

- (id)initWithFrame:(CGRect)frame withChannel:(NSString *)channel {
    self = [super initWithFrame:frame];
    if (self) {
        self.channel = [channel copy];
        
        [self _initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSetup];
    }
    return self;
}

- (void)_initSetup {
    [self setNeedsDisplay];
}

- (void)viewWillAppear {
    [self loadAndDisplay];
}

- (void)viewDidAppear {
    ///检查时间戳是否需要更新
}

- (void)viewDidDisappear {
    ///停止网络请求 页面更新等
}

- (void)loadAndDisplay {
    
    if (_placeHolder) {
        self.placeHolder.hidden = true;
    }
    self.table.hidden = false;
    [self bringSubviewToFront:self.table];
    if (![_dataSource pb_isEmpty]) {
        [self.table reloadData];
    }
    
    self.showDate = nil;
    self.showDate = [NSDate date];
}

- (void)lowMemoryState {
    [_dataSource removeAllObjects];
    _dataSource = nil;
    
    if (_table) {
        [_table reloadData];
        _table.hidden = true;
    }
    self.placeHolder.hidden = false;
    [self bringSubviewToFront:self.placeHolder];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (UITableView *)table {
    if (!_table) {
        CGRect bounds = self.bounds;
        _table = [[UITableView alloc] initWithFrame:bounds style:UITableViewStylePlain];
        [self addSubview:_table];
    }
    return _table;
}

- (NHPageHolder *)placeHolder {
    if (!_placeHolder) {
        CGRect bounds = self.bounds;
        _placeHolder = [[NHPageHolder alloc] initWithFrame:bounds];
        _placeHolder.backgroundColor = [UIColor grayColor];
        [self addSubview:_placeHolder];
    }
    [_placeHolder setHolderType:NHPageHolderTypeNormal];
    return _placeHolder;
}

//*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIFont *font = [UIFont pb_deviceFontForTitle];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil];
    [self.channel drawInRect:rect withAttributes:attributes];
}
//*/

@end
