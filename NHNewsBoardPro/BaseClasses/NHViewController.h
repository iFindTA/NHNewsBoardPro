//
//  NHViewController.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NHBaseKits.h"

/**
 item's place for bar
 */
typedef enum {
    NHItemTypeLeft    =  1 << 0,
    NHItemTypeRight   =  1 << 1
}NHItemType;

@interface NHViewController : UIViewController

/**
 *  @brief the root navigation controller for push/pop action
 */
@property (nonnull, nonatomic, strong) UINavigationController *rootNaviVCR;

/**
 *  @brief status bar and navibar
 */
@property (nonatomic, strong, readonly, nonnull) UILabel *statusBar;
@property (nonatomic, strong, readonly, nonnull) UILabel *navigationBar;
//@property (nonatomic, strong, readonly, nonnull) UINavigationBar *navigationBar;

@property (nonatomic, nullable, readonly, strong) NSMutableArray *requestPaths;

/**
 *  @brief change the status and navigation darwn color
 *
 *  @param color darwn's color
 */
- (void)changeStatusBarDarwnColor2:(UIColor * _Nonnull)color;

/**
 *  @brief change the status and navigation night color
 *
 *  @param color night's color
 */
- (void)changeStatusBarNightColor2:(UIColor * _Nonnull)color;

/**
 *  @brief change the navigation's title
 *
 *  @param title display bar's title
 */
- (void)changeNavigationBarTitle2:(NSString * _Nonnull)title;

/**
 *  @brief wethear hiden bar's down line
 *
 *  @param hidden wethear hidden
 */
- (void)makeNavigationBarLineHidden:(BOOL)hidden;

/**
 *  @brief custom bar's titleView
 *
 *  @param view the title View
 */
- (void)customNavigationBarTitleView:(UIView * _Nonnull)view;

/**
 *  @brief generate bar's item
 *
 *  @param items the items below such as:kItemBack
 *  @param type  the items place
 */
- (void)registerBarItems:(NSArray * _Nonnull)items forPlace:(NHItemType)type;

/**
 *  @brief generate tool bar
 *
 *  @param items toolbar functions
 */
- (void)registerToolBarItems:(NSArray * _Nonnull)items;

/**
 *	@brief	generate empty view for self's bounds
 *
 *	@param 	icon 	the placehodler icon
 *	@param 	info 	the placeholder info
 *
 *	@return	the empty view
 */
- (UIView * _Nonnull)emptyPlaceHolderView:(NSString * _Nullable)icon withInfo:(NSString * _Nullable)info;

#pragma mark -- UINavigationBar Actions --

- (void)navigationBarActionBack NS_REQUIRES_SUPER;

- (void)navigationBarActionClose NS_REQUIRES_SUPER;

- (void)navigationBarActionSearch NS_REQUIRES_SUPER;

- (void)navigationBarActionBell NS_REQUIRES_SUPER;

#pragma mark -- ToolBar Actions --

- (void)toolBarActionComment NS_REQUIRES_SUPER;

- (void)toolBarActionFont NS_REQUIRES_SUPER;

- (void)toolBarActionShare NS_REQUIRES_SUPER;

#pragma mark -- prevent loads Actions --

- (void)preloadSomeLaziest2DifficultCreate NS_REQUIRES_SUPER;

@end

#pragma mark -- UINavigationBar items --
/**
 *  @brief navigationBar item for back
 */
extern const NSString * _Nonnull kItemBack;

/**
 *  @brief navigationBar item for search
 */
extern const NSString * _Nonnull kItemSearch;

/**
 *  @brief navigationBar item for 24 hour
 */
extern const NSString * _Nonnull kItemBell;

/**
 *  @brief navigationBar item for search
 */
extern const NSString * _Nonnull kItemClose;

/**
 *  @brief navigationBar item for search
 */
extern const NSString * _Nonnull kItemAdd;

/**
 *  @brief navigationBar item for search
 */
extern const NSString * _Nonnull kItemPhoto;

/**
 *  @brief navigationBar item for search
 */
extern const NSString * _Nonnull kItemMore;

#pragma mark -- ToolBar items --

/**
 *  @brief toolBar item for comment
 */
extern const NSString * _Nonnull kItemComment;

/**
 *  @brief toolBar item for font
 */
extern const NSString * _Nonnull kItemFont;

/**
 *  @brief toolBar item for share
 */
extern const NSString * _Nonnull kItemShare;

