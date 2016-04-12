//
//  NHPreventCustomer.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventCustomer.h"
#import "NHNewsTitleCell.h"
#import <MJRefresh.h>

@interface NHPreventCustomer ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation NHPreventCustomer

+ (instancetype)prevent:(CGRect)bounds withChannel:(NSString *)cnn {
    NHPreventCustomer *tmp = [[NHPreventCustomer alloc] initWithFrame:bounds withCnn:cnn];
    return tmp;
}

#pragma mark -- 父类方法
- (void)preventLoad {
    [super preventLoad];
    
    if (!self.table) {
        self.table.dataSource = self;
        self.table.delegate = self;
        [self addSubview:self.table];
//        self.table.mj_header = [];
    }
    self.table.hidden = false;
    if (self.state == NHPreventStateShowing
        || self.state == NHPreventStatePreLoaded) {
        NSLog(@"栏目:%@....---->已经preload!",self.cnn);
        return;
    }
    NSLog(@"栏目:%@....---->preload!",self.cnn);
    
    self.state = NHPreventStatePreLoaded;
}

- (void)viewWillAppear {
    [super viewWillAppear];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    self.showDate = [NSDate date];
    
    self.state = NHPreventStateShowing;
}

- (void)reset2LowwerPowerState {
    
    //如果还没有显示过则忽略
    if (!self.showDate) {
        return;
    }
    
    NSLog(@"栏目:%@---->置为低内存状态",self.cnn);
    [super reset2LowwerPowerState];
}

#pragma mark == table dataSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSources count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *idetifier = @"preventCell";
    NHNewsTitleCell *cell = (NHNewsTitleCell *)[tableView dequeueReusableCellWithIdentifier:idetifier];
    if (cell == nil) {
        cell = [[NHNewsTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idetifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
