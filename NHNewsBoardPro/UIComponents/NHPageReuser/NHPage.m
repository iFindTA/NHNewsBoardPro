//
//  NHPage.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHPage.h"
#import "NHBaseKits.h"

@interface NHPage ()

@property (nonatomic, readwrite) NSString *identifier;

@end

@implementation NHPage

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identifier withChannel:(NSString *)channel {
    self = [super initWithFrame:frame];
    if (self) {
        _identifier = [identifier copy];
        _channel = [channel copy];
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
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.normalBackgroundColor = NHDarwnBgColor;
        self.nightBackgroundColor = NHNightBgColor;
    }];
}

- (void)setChannel:(NSString *)channel{
    if (channel && ![channel isEqualToString:_channel]) {
        _channel = channel;
        //NSLog(@"改变了channel");
    }
}

- (void)viewWillApear{}

- (void)viewWillDisappear{}

- (void)drawRect:(CGRect)rect {
    UIFont *font = [UIFont pb_deviceFontForTitle];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil];
    [self.channel drawInRect:rect withAttributes:attributes];
}

@end
