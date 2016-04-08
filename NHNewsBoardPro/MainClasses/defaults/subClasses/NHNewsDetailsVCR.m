//
//  NHNewsDetailsVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/27.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHNewsDetailsVCR.h"

@interface NHNewsDetailsVCR ()<UIWebViewDelegate>

@property (nullable, nonatomic, strong) UIWebView *webView;

@end

@implementation NHNewsDetailsVCR

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = NHWhiteColor;
    //self.navigationController.navigationBar.normalBarTintColor = [UIColor whiteColor];
    // navigationBar
    [self changeStatusBarDarwnColor2:NHWhiteColor];
    [self changeStatusBarNightColor2:NHWhiteColor];
    [self makeNavigationBarLineHidden:false];
    [self registerBarItems:@[kItemBack] forPlace:NHItemTypeLeft];
    [self registerToolBarItems:@[kItemComment,kItemFont,kItemShare]];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.backgroundColor = NHWhiteColor;
    [self.view addSubview:webView];
    self.webView = webView;
    weakify(self)
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self.view).mas_offset(UIEdgeInsetsMake(NHAbove_h, 0, 0, 0));
    }];
    
    //设置黑夜模式
    //weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.webView.nightBackgroundColor = NHNightBgColor;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)setNews:(NHNews *)news {
    _news = news;
    [self getNewsInfo];
}

- (void)getNewsInfo {
    
    if (_news) {
        [SVProgressHUD showWithStatus:@"Loading..."];
        NSString *url = PBFormat(@"nc/article/%@/full.html",self.news.docid);
        [self.requestPaths addObject:url];
        //NSLog(@"content uri:%@",url);
        weakify(self)
        PBBACK(^{
            [[NHAFEngine share] GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                strongify(self)
                NSDictionary *respDic = (NSDictionary *)responseObject;
                NSDictionary *realInfo = [respDic objectForKey:self.news.docid];
                //NSLog(@"get infos:%@",realInfo);
                //body
                NSString *title = [realInfo objectForKey:@"title"];
                NSString *ptime = [realInfo objectForKey:@"ptime"];
                NSString *tmp_body = [realInfo objectForKey:@"body"];
                NSMutableString *body = [NSMutableString string];
                [body appendString:@"<div class=\"title\">"];
                [body appendString:title];
                [body appendString:@"</div>"];
                [body appendString:@"<div class=\"title\">"];
                [body appendString:ptime];
                [body appendString:@"</div>"];
                [body appendString:tmp_body];
                
                //NSLog(@"body:%@",body);
                
                NSArray *imgs = [realInfo objectForKey:@"img"];
                for (NSDictionary *tmp in imgs) {
                    NSString *pixels = [tmp objectForKey:@"pixel"];
                    NSString *src = [tmp objectForKey:@"src"];
                    NSString *ref = [tmp objectForKey:@"ref"];
                    NSMutableString *imgHtml = [NSMutableString string];
                    // 设置img的div
                    [imgHtml appendString:@"<div class=\"img-parent\">"];
                    NSArray *pixel = [pixels componentsSeparatedByString:@"*"];
                    CGFloat width = [[pixel firstObject]floatValue];
                    CGFloat height = [[pixel lastObject]floatValue];
                    // 判断是否超过最大宽度
                    CGFloat maxWidth = PBSCREEN_WIDTH * 0.96;
                    if (width > maxWidth) {
                        height = maxWidth / width * height;
                        width = maxWidth;
                    }
                    
                    NSString *onload = @"this.onclick = function() {"
                    "  window.location.href = 'src=' +this.src;"
                    "};";
                    [imgHtml appendString:@"<img onload=\""];
                    [imgHtml appendString:onload];
                    [imgHtml appendString:@"\" "];
                    [imgHtml appendString:PBFormat(@"width=\"%f\" ",width)];
                    [imgHtml appendString:PBFormat(@"height=\"%f\" ",height)];
                    [imgHtml appendString:PBFormat(@"src=\"%@>\" ",src)];
                    [imgHtml appendString:@"</div>"];
                    //[imgHtml appendFormat:@"<img onload=\"%@\" width=\"%f\" height=\"%f\" src=\"%@\">",onload,width,height,src];
                    [body replaceOccurrencesOfString:ref withString:imgHtml options:NSCaseInsensitiveSearch range:NSMakeRange(0, body.length)];
                }
                //NSLog(@"body:%@",body);
                //css
                NSURL *css = [[NSBundle mainBundle] URLForResource:@"NewsDetails.css" withExtension:nil];
                NSMutableString *html = [NSMutableString string];
                [html appendString:@"<html>"];
                [html appendString:@"<head>"];
                [html appendString:@"<link rel=\"stylesheet\" href=\""];
                [html appendString:css.absoluteString];
                [html appendString:@"\">"];
                //[html appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">",css];
                [html appendString:@"</head>"];
                
                [html appendString:@"<body style=\"background:#f6f6f6\">"];
                [html appendString:body];
                [html appendString:@"</body>"];
                
                [html appendString:@"</html>"];
                //NSLog(@"html:%@",html);
                
                [self loadContents:html];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        });
    }
}

- (void)loadContents:(NSString * _Nonnull)conts {
    
    PBBACK(^{
        if (_webView) {
            [self.webView loadHTMLString:conts baseURL:nil];
        }
        PBMAINDelay(0.5,^{
            [SVProgressHUD dismiss];
        });
    });
}

- (void)navigationBarActionBack {
    [super navigationBarActionBack];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark -- UIWebView Delegate --

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    NSRange range = [url rangeOfString:@"sx:src="];
    if (range.location != NSNotFound) {
        //NSInteger begin = range.location + range.length;
        //NSString *src = [url substringFromIndex:begin];
        //[self savePictureToAlbum:src];
        return NO;
    }
    return YES;
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
