//
//  NHContentInfolVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHContentInfolVCR.h"
#import "NHPresentVCR.h"

@interface NHContentInfolVCR ()

@end

@implementation NHContentInfolVCR

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Info";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect infoRect = CGRectMake(100, 100, 100, 50);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:@"test" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)testAction {
    NHPresentVCR *vcr = [[NHPresentVCR alloc] init];
    UINavigationController *testNavi = [[UINavigationController alloc] initWithRootViewController:vcr];
    [self presentViewController:testNavi animated:true completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
