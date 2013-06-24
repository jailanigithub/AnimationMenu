    //
//  AwesomeMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kAwesomeMenuDefaultNearRadius     = 110.0f;
static CGFloat const kAwesomeMenuDefaultEndRadius      = 300.0f;
static CGFloat const kAwesomeMenuDefaultFarRadius      = 250.0f;

static CGFloat const kAwesomeMenuDefaultStartPointX    = -20.0;
static CGFloat const kAwesomeMenuDefaultStartPointY    = 17.0;

static CGFloat const kAwesomeMenuDisplacedPointX       = 200.0;
static CGFloat const kAwesomeMenuDisplacedPointY       = 0.0;
static CGFloat const kAwesomeMenuItemBounce            = 20.0;
static CGFloat const kAwesomeMenuItemGap               = 40.0;

static CGFloat const kAwesomeMenuDefaultTimeOffset     = 0.15f;
static CGFloat const kAwesomeMenuDefaultRotateAngle    = 0.0;
static CGFloat const kAwesomeMenuDefaultMenuWholeAngle = 90.0;
static CGFloat const kAwesomeMenuDefaultExpandRotation = M_PI;
static CGFloat const kAwesomeMenuDefaultCloseRotation  = M_PI * 2;


static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface AwesomeMenu ()
- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation AwesomeMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation, menuCount;
@synthesize expanding   = _expanding;
@synthesize delegate    = _delegate;
@synthesize menusArray  = _menusArray;
@synthesize commonPoint = _commonPoint;


-(void)removeMenuItems{
    for (UIView *v in self.subviews){
        if([v isKindOfClass:[AwesomeMenuItem class]]){
            AwesomeMenuItem *item = (AwesomeMenuItem*)v;
            NSLog(@"Menu Item tag %d", item.menuItemtag);
            [v removeFromSuperview];
        }
    }
}

-(float)getEndRadius{
    switch (self.menuCount) {
        case 0:
            return 0;
            break;

        case 1:
            return 100.0;
            break;

        case 2:
            return 130;
            break;

        case 3:
            return 170;
            break;
            
        case 4:
            return 230;
            break;
            
        case 5:
            return 290;
            break;
            
        default:
            break;
    }
    return 0.0;
}


#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray menusTag:(NSArray*)aMenuTagArray
{
    self = [super initWithFrame:frame];
    if (self) {

        self.menusArray = aMenusArray;
        self.menusTagArray = aMenuTagArray;
        if(self.menusArray){
            self.menuCount = self.menusArray.count;
        }else{
            self.menuCount = 0;
        }
        

        
        self.commonPoint     = CGPointMake(0.0, 0.0);
        self.backgroundColor = [UIColor clearColor];
		
		self.nearRadius = kAwesomeMenuDefaultNearRadius;
		self.endRadius = [self getEndRadius];
		self.farRadius = kAwesomeMenuDefaultFarRadius;
		self.timeOffset = kAwesomeMenuDefaultTimeOffset;
		self.rotateAngle = kAwesomeMenuDefaultRotateAngle;
		self.menuWholeAngle = kAwesomeMenuDefaultMenuWholeAngle;
		self.startPoint = CGPointMake(kAwesomeMenuDefaultStartPointX, kAwesomeMenuDefaultStartPointY);
        self.expandRotation = kAwesomeMenuDefaultExpandRotation;
        self.closeRotation = kAwesomeMenuDefaultCloseRotation;
        
        // add the "Add" Button.
        _addButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"plus_1.png"]
                                       highlightedImage:[UIImage imageNamed:@"plus_selected"] 
                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
        _addButton.delegate = self;
        _addButton.center = self.startPoint;
        [self addSubview:_addButton];
    }
    return self;
}


#pragma mark - getters & setters

- (void)setStartPoint:(CGPoint)aPoint
{
    startPoint = aPoint;
    _addButton.center = aPoint;
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage*)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
	return _addButton.contentImageView.highlightedImage;
}


                               
#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu is animating, prevent touches
    if (_isAnimating) 
    {
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) 
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
}


-(void)awesomeTouchBegans{
   [self AwesomeMenuItemTouchesBegan:_addButton];
}

-(void)awesomeTouchEnds{
    [self AwesomeMenuItemTouchesEnd:_addButton];
}


#pragma mark - AwesomeMenuItem delegates
- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item
{
    if (item == _addButton)
        self.expanding = !self.isExpanding;
}

- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item
{
    endRadius = [self getEndRadius];
    // exclude the "add" button
    if (item == _addButton) 
    {
        return;
    }

    if ([_delegate respondsToSelector:@selector(AwesomeMenu:didSelectIndex:)])
    {
        //        [_delegate AwesomeMenu:self didSelectIndex:item.tag - 1000];
        NSLog(@"Seleceted Menu tag %d", item.menuItemtag);
        [_delegate AwesomeMenu:self didSelectIndex:item.menuItemtag]; //jai
    }
    return;
    
    
    /* Commented by jai
    
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        AwesomeMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];

        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    */

}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{	
    if (aMenusArray == _menusArray)
    {
        return;
    }
    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
}


- (void)_setMenu {
	int count = [_menusArray count];
//    endRadius = endRadius - ((count + 1) * kAwesomeMenuItemGap);

    NSLog(@"End Radius %f", endRadius);
    for (int i = 0; i < count; i ++)
    {
        endRadius = endRadius - kAwesomeMenuItemGap;
        AwesomeMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
//        item.menuItemtag = self.menusTagArray[i];//jai
        item.startPoint = startPoint;
 
        item.endPoint  = CGPointMake(startPoint.x + endRadius, startPoint.y);
        item.nearPoint = CGPointMake(item.endPoint.x - kAwesomeMenuItemBounce, startPoint.y);
        item.farPoint  = CGPointMake(item.endPoint.x + kAwesomeMenuItemBounce, startPoint.y);

        item.endPoint  = RotateCGPointAroundCenter(item.endPoint, startPoint, rotateAngle);
        item.nearPoint = RotateCGPointAroundCenter(item.nearPoint, startPoint, rotateAngle);
        item.farPoint  = RotateCGPointAroundCenter(item.farPoint, startPoint, rotateAngle);
        

        //Method 1

//        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
//
//        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
//        
//        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
//        
//        item.endPoint  = endPoint;
//        item.nearPoint = nearPoint;
//        item.farPoint  = farPoint;

        
        
        //Method 2
        
//        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
//        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
//        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
//        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
//        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
//        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);

        
        item.center = item.startPoint;
        item.delegate = self;
		
        NSLog(@"ITEM %d: End  point X = %f Y = %f", i+1, item.endPoint.x, item.endPoint.y);
		NSLog(@"ITEM %d: NEAR point X = %f Y = %f", i+1, item.nearPoint.x, item.nearPoint.y);
		NSLog(@"ITEM %d: FAR  point X = %f Y = %f", i+1, item.farPoint.x, item.farPoint.y);

        [self insertSubview:item belowSubview:_addButton];
    }
}

- (BOOL)isExpanding
{
    return _expanding;
}
- (void)setExpanding:(BOOL)expanding
{
	if (expanding) {
		[self _setMenu];
	}
	
    _expanding = expanding;    
    
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    // expand or close animation
    if (!_timer) 
    {
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}



#pragma mark - private methods
- (void)_expand
{
    
    if (_flag == [_menusArray count])
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == [_menusArray count] - 1){
        [animationgroup setValue:@"firstAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_close
{
 
    if (_flag == -1)
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
     AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
//    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
//    rotateAnimation.duration = 0.5f;
//    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
//                                [NSNumber numberWithFloat:.0], 
//                                [NSNumber numberWithFloat:.4],
//                                [NSNumber numberWithFloat:.5], nil]; 
// Add this animation to animation group array if u want rotations  
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == 0){
        [animationgroup setValue:@"lastAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;

    _flag --;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"lastAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(AwesomeMenuDidFinishAnimationClose:)]){
            [self.delegate AwesomeMenuDidFinishAnimationClose:self];
            
        }
    }
    if([[anim valueForKey:@"id"] isEqual:@"firstAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(AwesomeMenuDidFinishAnimationOpen:)]){
            [self.delegate AwesomeMenuDidFinishAnimationOpen:self];
        }
    }
}
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;

    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
