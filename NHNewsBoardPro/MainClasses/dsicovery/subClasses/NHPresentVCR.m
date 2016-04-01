//
//  NHPresentVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHPresentVCR.h"

@interface NHPresentVCR ()

@end

@implementation NHPresentVCR

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect infoRect = CGRectMake(0, 0, 50, 30);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = infoRect;
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationController.navigationItem.leftBarButtonItem = item;
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.view.nightBackgroundColor = [UIColor blueColor];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self cancelAction];
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:true completion:^{
        
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
