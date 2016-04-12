//
//  NHPreventPager.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventPager.h"

@interface NHPreventPager ()

//@property (nonatomic, assign) NHPreventState state;
@property (nonatomic, strong) UIView *placeHolder;
@property (nonatomic, copy, readwrite) NSString *cnn;

@end

@implementation NHPreventPager

- (id)initWithFrame:(CGRect)frame withCnn:(NSString *)cnn {
    self = [super initWithFrame:frame];
    if (self) {
        self.cnn = [cnn copy];
        [self __initSetup];
    }
    return self;
}

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
    
    self.state = NHPreventStateLowPower;
}

- (void)drawRect:(CGRect)rect {
    
    NSString *info = PBFormat(@"%@",@"网易新闻Pro");
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    CGSize size = [info sizeWithAttributes:attrs];
    CGRect infoRect = (CGRect){.origin=(CGPoint){(rect.size.width-size.width)*0.5,(rect.size.height-size.height)*0.5},size};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextFillRect(ctx, rect);
    [info drawInRect:infoRect withAttributes:attrs];
    //[info drawAtPoint:<#(CGPoint)#> withAttributes:<#(nullable NSDictionary<NSString *,id> *)#>]
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self respondsToSelector:@selector(viewDidAppear)]) {
        [self viewDidAppear];
    }
}

#pragma mark -- Lazy load methods

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSources;
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _table;
}

#pragma mark -- 父类方法

- (void)preventLoad {}

- (void)viewWillAppear {}

- (void)viewDidAppear {}

- (void)reset2LowwerPowerState {
    if (_dataSources) {
        [_dataSources removeAllObjects];
        _dataSources = nil;
    }
    [self.table reloadData];
    self.table.hidden = true;
}

@end
