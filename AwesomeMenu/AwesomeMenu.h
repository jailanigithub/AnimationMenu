//
//  AwesomeMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenuItem.h"

@protocol AwesomeMenuDelegate;


@interface AwesomeMenu : UIView <AwesomeMenuItemDelegate>
{
    NSArray *_menusArray;
    int _flag;
    NSTimer *_timer;
    AwesomeMenuItem *_addButton;
    
    id<AwesomeMenuDelegate> __weak _delegate;
    BOOL _isAnimating;
    CGPoint commonPoint;
    int menuCount;
}


@property (nonatomic, assign)int menuCount;
@property (nonatomic, assign)CGPoint commonPoint;
@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, copy) NSArray *menusTagArray;

@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, weak) id<AwesomeMenuDelegate> delegate;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;

-(void)removeMenuItems;
-(void)awesomeTouchBegans;
-(void)awesomeTouchEnds;
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray menusTag:(NSArray*)aMenuTagArray;
@end

@protocol AwesomeMenuDelegate <NSObject>
- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(int)idx;
@optional
- (void)AwesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu;
- (void)AwesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu;
@end