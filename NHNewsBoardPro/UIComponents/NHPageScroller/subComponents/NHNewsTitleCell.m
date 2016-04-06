//
//  NHNewsTitleCell.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/26.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHNewsTitleCell.h"
#import "NHReView.h"
#import "NHADsImgCell.h"

@interface NHNewsTitleCell ()<NHReViewDataSource,NHReViewDelegate>

@property (nonatomic, strong, nullable) NHNews *sourceNews;

@property (nonatomic, strong, nullable) NHReView *adsView;

@property (nullable, nonatomic, strong) UIImageView *newsIcon,*newsReplyBubble,*imgNewsIcon1,*imgNewsIcon2,*imgNewsIcon3,*bigImgNewsIcon;

@property (nullable, nonatomic, strong) UILabel *newsTitle,*newsSubTitle,*newsReply,*emptyPlacer;
@property (nullable, nonatomic, strong) UILabel *imgNTitle;
@property (nullable, nonatomic, strong) UILabel *bImgNTitle,*bImgNSubTitle;

@property (nonatomic, copy) adEvent adTouchEvent;

@end

@implementation NHNewsTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForSource:(NHNews * _Nonnull)news {
    if (news.hasAD){
        return ceilf(PBSCREEN_WIDTH*0.5);
    }else if(news.imgType.boolValue) {
        return 170;
    }else if (!PBIsEmpty(news.imgextra)){
        return 130;
    }else{
        return 80;
    }
}

+ (NSString *)identifierForSource:(NHNews * _Nonnull)news {
    
    if (PBIsEmpty(news)) {
        return @"news_empty_cell";
    }
    NSString *identifier;
    if (news.hasAD) {
        identifier = @"ADImageCell";
    }else if (news.imgType.boolValue){
        identifier = @"BigImageCell";
    }else if (!PBIsEmpty(news.imgextra)){
        identifier = @"ImagesCell";
    }else{
        identifier = @"NewsCell";
    }
    //NSLog(@"identifier:%@----title:%@",identifier,news.title);
    return identifier;
}
#define NH_NEWS_TITLE_FONT_OFFSET 2
#define NH_NEWS_TITLE_FONT  ([UIFont pb_deviceFontForTitle])
- (void)__initSetup {
    
    [self configureNewsCell];
    
    [self configureImgNewsCell];
    
    [self configureBigImgNewsCell];
    
    [self configureADsCell];
    
    //CGFloat offset = 8.f;
    CGFloat font_offset = NH_NEWS_TITLE_FONT_OFFSET;
    UIFont *title_font = NH_NEWS_TITLE_FONT;
    UIFont *reply_font = [UIFont fontWithName:title_font.fontName size:title_font.pointSize-font_offset*3];
    //参与
    UILabel *label = [[UILabel alloc] init];
    //label.backgroundColor = [UIColor lightGrayColor];
    label.font = reply_font;
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:label];
    self.newsReply = label;
    weakify(self)
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.bottom.equalTo(self.contentView).offset(-offset);
//        make.right.equalTo(self.contentView).offset(-offset);
//        make.height.equalTo(@(reply_font.pointSize));
//    }];
    //bubble
    UIImage *bubble = [UIImage imageNamed:@"news_reply_bubble"];
    bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(4, 8, 2, 10) resizingMode:UIImageResizingModeStretch];
    self.newsReplyBubble.image = bubble;
    UIImageView *bubble_img = [[UIImageView alloc] initWithImage:bubble];
    //bubble_img.backgroundColor = [UIColor redColor];
    bubble_img.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:bubble_img];
    self.newsReplyBubble = bubble_img;
    [bubble_img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.newsReply).insets(UIEdgeInsetsMake(-2, -4, -2, -4));
    }];
    //线
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).offset(0);
        make.bottom.equalTo(self.contentView).offset(-1);
        make.height.equalTo(@1);
    }];
    
    [self addColorChangedBlock:^{
        strongify(self);
        self.nightBackgroundColor = NHNightBgColor;
        self.normalBackgroundColor = NHDarwnBgColor;
    }];
}

//单张图片cell
- (void)configureNewsCell {
    
    CGFloat offset = 8.f;
    CGFloat icon_width = 80.f;
    CGFloat title_height = 21.f;
    UIImageView *tmp = [[UIImageView alloc] init];
    [self.contentView addSubview:tmp];
    self.newsIcon = tmp;
    weakify(self)
    [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.equalTo(self.contentView).offset(offset);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-offset);
        make.width.equalTo(@(icon_width));
    }];
    CGFloat font_offset = 2;
    UIFont *title_font = NH_NEWS_TITLE_FONT;
    UIFont *sub_title_font = [UIFont fontWithName:title_font.fontName size:title_font.pointSize-font_offset];
    //标题
    UILabel *label = [[UILabel alloc] init];
    label.font = title_font;
    label.textColor = [UIColor blackColor];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:label];
    self.newsTitle = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.newsIcon).offset(0);
        make.left.equalTo(self.newsIcon.mas_right).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
        make.height.equalTo(@(title_height));
    }];
    //子标题
    label = [[UILabel alloc] init];
    label.font = sub_title_font;
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:label];
    self.newsSubTitle = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.newsTitle.mas_bottom).offset(offset);
        make.left.equalTo(self.newsIcon.mas_right).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
    }];
}

//三张图片cell
- (void)configureImgNewsCell {
    CGFloat offset = 8.f;
    CGFloat icon_height = 80.f;
    CGFloat title_height = 21.f;
    
    UIFont *title_font = NH_NEWS_TITLE_FONT;
    //标题
    UILabel *label = [[UILabel alloc] init];
    label.font = title_font;
    label.textColor = [UIColor blackColor];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:label];
    self.imgNTitle = label;
    weakify(self)
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.contentView).offset(offset);
        make.left.equalTo(self.contentView).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
        make.height.equalTo(@(title_height));
    }];
    
    //init image
    UIImageView *tmp = [[UIImageView alloc] init];
    tmp.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:tmp];
    self.imgNewsIcon1 = tmp;
    tmp = [[UIImageView alloc] init];
    [self.contentView addSubview:tmp];
    self.imgNewsIcon2 = tmp;
    tmp = [[UIImageView alloc] init];
    [self.contentView addSubview:tmp];
    self.imgNewsIcon3 = tmp;
    //布局
    [_imgNewsIcon1 mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.imgNTitle.mas_bottom).offset(offset);
        make.left.equalTo(self.contentView).offset(offset);
        //make.bottom.equalTo(self.contentView.mas_bottom).offset(-offset);
        make.height.equalTo(@(icon_height));
        make.width.mas_lessThanOrEqualTo(_imgNewsIcon2.mas_width);
        make.right.mas_equalTo(_imgNewsIcon2.mas_left).offset(-offset);
    }];
    //image2
    [_imgNewsIcon2 mas_makeConstraints:^(MASConstraintMaker *make) {
        //strongify(self)
        make.top.equalTo(_imgNTitle.mas_bottom).offset(offset);
        make.left.equalTo(_imgNewsIcon1.mas_right).offset(offset);
        //make.bottom.equalTo(self.contentView).offset(-offset);
        make.height.equalTo(@(icon_height));
        make.width.mas_equalTo(_imgNewsIcon3.mas_width);
        make.right.mas_equalTo(_imgNewsIcon3.mas_left).offset(-offset);
    }];
    //image3
    [self.imgNewsIcon3 mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.imgNTitle.mas_bottom).offset(offset);
        make.left.equalTo(_imgNewsIcon2.mas_right).offset(offset);
        //make.bottom.equalTo(self.contentView).offset(-offset);
        make.height.equalTo(@(icon_height));
        make.width.mas_equalTo(_imgNewsIcon2.mas_width);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-offset);
    }];

}

//单张大图片cell
- (void)configureBigImgNewsCell {
    CGFloat offset = 8.f;
    
    CGFloat font_offset = NH_NEWS_TITLE_FONT_OFFSET;
    UIFont *sub_title_font = [UIFont fontWithName:NH_NEWS_TITLE_FONT.fontName size:NH_NEWS_TITLE_FONT.pointSize-font_offset];
    //标题
    UILabel *label = [[UILabel alloc] init];
    label.font = NH_NEWS_TITLE_FONT;
    label.textColor = [UIColor blackColor];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:label];
    self.bImgNTitle = label;
    UIImageView *tmp = [[UIImageView alloc] init];
    tmp.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:tmp];
    self.bigImgNewsIcon = tmp;
    label = [[UILabel alloc] init];
    label.font = sub_title_font;
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:label];
    self.bImgNSubTitle = label;
    weakify(self)
    [_bImgNTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.contentView).offset(offset);
        make.left.equalTo(self.contentView).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
        //make.height.equalTo(@(title_height));
        make.bottom.mas_equalTo(_bigImgNewsIcon.mas_top).offset(-offset);
    }];
    
    [_bigImgNewsIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.mas_equalTo(self.bImgNTitle.mas_bottom).offset(offset);
        make.left.equalTo(self.contentView).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
        //make.height.equalTo(@(icon_height));
        make.bottom.mas_equalTo(_bImgNSubTitle.mas_top).offset(-offset);
    }];
    
    [_bImgNSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.mas_equalTo(_bigImgNewsIcon.mas_bottom).offset(offset);
        make.left.equalTo(self.contentView).offset(offset);
        make.right.equalTo(self.contentView).offset(-offset);
        make.bottom.equalTo(self.contentView).offset(-offset);
    }];
}

//AD 轮播
- (void)configureADsCell {
    
    //weakify(self)
    CGRect bounds = CGRectMake(0, 0, PBSCREEN_WIDTH, PBSCREEN_WIDTH*0.5);
    NHReView *tmp = [[NHReView alloc] initWithFrame:bounds];
    tmp.dataSource = self;
    tmp.delegate = self;
    [self.contentView addSubview:tmp];
    self.adsView = tmp;
//    [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.edges.mas_equalTo(self.contentView).offset(0);
//    }];
}

- (void)configureForSource:(NHNews * _Nonnull)news {
    
    self.sourceNews = news;
    [self layoutIfNeeded];
    [self fillingNewsCell];
}

- (void)configureEmpty:(CGFloat)height {
    
    NSArray *subviews = self.contentView.subviews;
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PBSCREEN_WIDTH, height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = NH_NEWS_TITLE_FONT;
    label.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:label];
    self.emptyPlacer = label;
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    if (PBIsEmpty(_sourceNews)) {
        self.emptyPlacer.text = @"爱财经";
    }else{
        NSArray *subviews = self.contentView.subviews;
        CGFloat offset = 8.f;
        CGFloat reply_height = (NH_NEWS_TITLE_FONT.pointSize-NH_NEWS_TITLE_FONT_OFFSET*3);
        weakify(self)
        if (self.sourceNews.hasAD){
            //显示广告
            [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL hidden = (obj == self.adsView);
                [obj setHidden:!hidden];
            }];
//            [self.adsView mas_makeConstraints:^(MASConstraintMaker *make) {
//                strongify(self)
//                make.edges.mas_equalTo(self.contentView).offset(0);
//            }];
        }else if(self.sourceNews.imgType.boolValue) {
            //显示大图
            //图片
            [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL hidden = (obj == self.bImgNTitle)
                ||(obj == self.bImgNSubTitle)
                ||(obj == self.bigImgNewsIcon)
                || (obj == self.newsReply)
                || (obj == self.newsReplyBubble);
                [obj setHidden:!hidden];
            }];
            //修正Reply位置
            [self.newsReply mas_updateConstraints:^(MASConstraintMaker *make) {
                strongify(self)
                make.bottom.equalTo(self.contentView).offset(-offset);
                make.right.equalTo(self.contentView).offset(-offset);
                make.height.equalTo(@(reply_height));
            }];
        }else if (!PBIsEmpty(self.sourceNews.imgextra)){
            //图片
            [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL hidden = (obj == self.imgNTitle)
                ||(obj == self.imgNewsIcon1)
                ||(obj == self.imgNewsIcon2)
                ||(obj == self.imgNewsIcon3)
                || (obj == self.newsReply)
                || (obj == self.newsReplyBubble);
                [obj setHidden:!hidden];
            }];
            //修正Reply位置
            [self.newsReply mas_updateConstraints:^(MASConstraintMaker *make) {
                strongify(self)
                make.top.equalTo(self.contentView).offset(offset);
                make.right.equalTo(self.contentView).offset(-offset);
                //make.bottom.mas_equalTo(self.imgNTitle.mas_bottom);
            }];
        }else{
            //普通新闻
            [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL hidden = (obj == self.newsIcon)
                ||(obj == self.newsTitle)
                ||(obj == self.newsSubTitle)
                || (obj == self.newsReply)
                || (obj == self.newsReplyBubble);
                [obj setHidden:!hidden];
            }];
            //修正Reply位置
            [self.newsReply mas_updateConstraints:^(MASConstraintMaker *make) {
                strongify(self)
                make.bottom.equalTo(self.contentView).offset(-offset);
                make.right.equalTo(self.contentView).offset(-offset);
                make.height.equalTo(@(reply_height));
            }];
        }
    }
}

//填充数据
- (void)fillingNewsCell {
    UIImage *placeHolder = [UIImage imageNamed:@"302"];
    UIColor *titleColor = [[NHDBEngine share] alreadyReadDoc:self.sourceNews.docid]?[UIColor lightGrayColor]:[UIColor blackColor];
    if (self.sourceNews.hasAD){
        //
        //NSLog(@"reload ads !---%@",self.sourceNews.ads);
        [self.adsView reloadData];
    }else if(self.sourceNews.imgType.boolValue) {
        //
        [self.bigImgNewsIcon sd_setImageWithURL:[NSURL URLWithString:self.sourceNews.imgsrc] placeholderImage:placeHolder];
        self.bImgNTitle.textColor = titleColor;
        self.bImgNTitle.text = self.sourceNews.title;
        self.bImgNSubTitle.text = self.sourceNews.digest;
    }else if (!PBIsEmpty(self.sourceNews.imgextra)){
        //
        [self.imgNewsIcon1 sd_setImageWithURL:[NSURL URLWithString:self.sourceNews.imgsrc] placeholderImage:placeHolder];
        self.imgNTitle.textColor = titleColor;
        self.imgNTitle.text = self.sourceNews.title;
        if (self.sourceNews.imgextra.count == 2) {
            [self.imgNewsIcon2 sd_setImageWithURL:[NSURL URLWithString:self.sourceNews.imgextra[0][@"imgsrc"]] placeholderImage:placeHolder];
            [self.imgNewsIcon3 sd_setImageWithURL:[NSURL URLWithString:self.sourceNews.imgextra[1][@"imgsrc"]] placeholderImage:placeHolder];
        }
    }else{
        //赋值
        [self.newsIcon sd_setImageWithURL:[NSURL URLWithString:self.sourceNews.imgsrc] placeholderImage:placeHolder];
        self.newsTitle.textColor = titleColor;
        self.newsTitle.text = self.sourceNews.title;
        self.newsSubTitle.text = self.sourceNews.digest;
    }
    // 如果回复太多就改成几点几万
    CGFloat count =  [self.sourceNews.replyCount intValue];
    NSString *displayCount;
    if (count > 10000) {
        displayCount = [NSString stringWithFormat:@"%.1f万跟帖",count/10000];
    }else{
        displayCount = [NSString stringWithFormat:@"%.0f跟帖",count];
    }
    self.newsReply.text = displayCount;
    [self.newsReply sizeToFit];
}

#pragma mark -- review ads dataSource --

- (NSUInteger)reviewPageCount:(NHReView *)view {
    NSUInteger counts = 0;
    counts = self.sourceNews.ads.count;
    if (counts == 0) {
        counts = 1;
    }
    return counts;
}

- (NHReCell *)review:(NHReView *)view pageViewAtIndex:(NSUInteger)index {
    static NSString *identifier = @"flagCell";
    NHADsImgCell *cell = (NHADsImgCell *)[view dequeueReusablePageWithIdentifier:identifier forPageIndex:index];
    if (cell == nil) {
        cell = [[NHADsImgCell alloc] initWithIdentifier:identifier];
    }
    UIImage *placeHolder = [UIImage imageNamed:@"302"];
    
    NSString *imgName;
    NSUInteger counts = self.sourceNews.ads.count;
    if (counts == 0) {
        imgName = self.sourceNews.imgsrc;
    }else{
        NSDictionary *tmp = [self.sourceNews.ads objectAtIndex:index];
        imgName = [tmp objectForKey:@"imgsrc"];
    }
    [cell.image sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:placeHolder];
    //NSLog(@"+++++");
    //cell.image.backgroundColor = [UIColor pb_randomColor];
    
    //NSLog(@"cell for row:%zd",index);
    return cell;
}

- (void)review:(NHReView *)view didChangeToIndex:(NSUInteger)index {
    NSString *imgName;
    NSUInteger counts = self.sourceNews.ads.count;
    if (counts == 0) {
        imgName = self.sourceNews.title;
    }else{
        NSDictionary *tmp = [self.sourceNews.ads objectAtIndex:index];
        imgName = [tmp objectForKey:@"title"];
    }
    [view changeTitle:imgName];
}

- (void)dealWithAds:(adEvent _Nonnull)event {
    _adTouchEvent = [event copy];
}

- (void)review:(NHReView *)view didTouchIndex:(NSUInteger)index {
    if (_adTouchEvent) {
        NSDictionary *tmp;
        NSUInteger counts = self.sourceNews.ads.count;
        if (counts == 0) {
            tmp = [NSDictionary dictionaryWithObjectsAndKeys:self.sourceNews.url,@"url",self.sourceNews.title,@"title",self.sourceNews.docid,@"docid", nil];
        }else{
            tmp = [NSDictionary dictionaryWithDictionary:[self.sourceNews.ads objectAtIndex:index]];
        }
        _adTouchEvent(tmp);
    }
}

@end
