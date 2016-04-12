//
//  NHPreventPager.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventPager.h"

@interface NHPreventPager ()

@property (nonatomic, strong, nullable) NSDate *showDate;
@property (nonatomic, assign) NHPreventState state;
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
    
    self.state = NHPreventStateNone;
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
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self respondsToSelector:@selector(viewDidAppear)]) {
        [self viewDidAppear];
    }
}

#pragma mark -- 父类方法

- (void)preventLoad {
    self.state = NHPreventStatePreLoaded;
}

- (void)viewWillAppear {
    self.state = NHPreventStateWillShow;
}

- (void)viewDidAppear {
    
    self.showDate = [NSDate date];
    
    self.state = NHPreventStateShowing;
}

- (void)reset2LowwerPowerState {
    self.showDate = nil;
    self.state = NHPreventStateLowPower;
}

@end
