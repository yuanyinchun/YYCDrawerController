//
//  YYCDrawerController.m
//  YYCDrawerControllerDemo
//
//  Created by yuanyinchun on 11/28/14.
//  Copyright (c) 2014 YYC. All rights reserved.
//

#import "YYCDrawerController.h"

@interface CenterContainerView : UIView

@property (nonatomic,assign) DrawerSide currentDrawerSide;
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
@end

@implementation CenterContainerView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView &&
       self.currentDrawerSide != DrawerSideNone){
        hitView=nil;
    }
    return hitView;
}

@end


@interface YYCDrawerController ()

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CenterContainerView *centerContainerView;

@end

@implementation YYCDrawerController

#pragma makr - LifeCycle

-(id)initWithCenterViewController:(UIViewController *)centerViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController
{
    NSParameterAssert(centerViewController);
    self=[super init];
    if (self) {
        self.leftDrawerMaxWidth=280.0;
        self.rightDrawerMaxWidth=230.0;
        self.currentDrawerSide=DrawerSideNone;
        [self setCenterViewController:centerViewController];
        [self setLeftViewController:leftViewController];
        [self setRightViewController:rightViewController];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.centerViewController beginAppearanceTransition:YES animated:animated];
    if (self.currentDrawerSide==DrawerSideLeft) {
        [self.leftViewController beginAppearanceTransition:YES animated:animated];
    }
    else if (self.currentDrawerSide==DrawerSideRight){
        [self.rightViewController beginAppearanceTransition:YES animated:animated];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.centerViewController endAppearanceTransition];
    
    if (self.currentDrawerSide==DrawerSideLeft) {
        [self.leftViewController endAppearanceTransition];
    }
    else if (self.currentDrawerSide==DrawerSideRight){
        [self.rightViewController endAppearanceTransition];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.centerViewController beginAppearanceTransition:NO animated:animated];
    
    if (self.currentDrawerSide==DrawerSideLeft) {
        [self.leftViewController beginAppearanceTransition:NO animated:animated];
    }
    else if (self.currentDrawerSide==DrawerSideRight){
       [self.rightViewController beginAppearanceTransition:NO animated:animated];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.centerViewController endAppearanceTransition];
    if (self.currentDrawerSide==DrawerSideLeft) {
        [self.leftViewController endAppearanceTransition];
    }
    else if (self.currentDrawerSide==DrawerSideRight){
        [self.rightViewController endAppearanceTransition];
    }
}

#pragma mark - Gesture
-(void)configGesture
{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandler:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureHandler:)];
    [self.view addGestureRecognizer:panGesture];
}

-(void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture
{
    if (self.currentDrawerSide==DrawerSideNone) {
        return;
    }
    CGRect visibleCenterRect=[self visibleCenterRect];
    CGPoint touchPoint=[tapGesture locationInView:self.centerContainerView];
    if (CGRectContainsPoint(visibleCenterRect, touchPoint)) {
        [self closeDrawer:self.currentDrawerSide animated:YES completion:nil];
    }
}


-(void)panGestureHandler:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //CGPoint translation=[panGesture translationInView:self.containerView];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            
            DrawerSide visibleDrawerSide=[self visibleDrawerSide];
            
            
            CGPoint translationPoint=[panGesture translationInView:self.containerView];
            if (visibleDrawerSide==DrawerSideNone) {
                if (translationPoint.x>0.0) {
                    visibleDrawerSide=DrawerSideLeft;
                }else if (translationPoint.x<0.0){
                    visibleDrawerSide=DrawerSideRight;
                }
            }
            
            UIViewController *viewController=[self viewControllerForDrawerSide:visibleDrawerSide];
            CGRect frame=viewController.view.frame;
            frame.origin.x+=translationPoint.x;
            
            

            if (visibleDrawerSide==DrawerSideLeft) {
               // if ( frame.origin.x>-CGRectGetWidth(viewController.view.frame) && frame.origin.x<0.0) {
                if (frame.origin.x<0.0) {
                    viewController.view.frame=frame;
                }
            }else if (visibleDrawerSide==DrawerSideRight){
                //if (CGRectGetMaxX(frame)>self.containerView.frame.size.width && CGRectGetMaxX(frame)< CGRectGetWidth(self.containerView.frame)+CGRectGetWidth(frame)) {
                if (CGRectGetMaxX(frame)>self.containerView.frame.size.width) {
                    viewController.view.frame=frame;
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            DrawerSide visibleDrawerSide=[self visibleDrawerSide];
            if (visibleDrawerSide==DrawerSideNone) {
                [self resetDrawers];
            }else{
                UIViewController *visibleViewController=[self viewControllerForDrawerSide:visibleDrawerSide];
                CGRect frame=visibleViewController.view.frame;
                
                CGFloat visibleWidth=0.0;
                if (visibleDrawerSide==DrawerSideLeft) {
                    visibleWidth=self.leftDrawerMaxWidth+frame.origin.x;
                }
                if (visibleDrawerSide==DrawerSideRight) {
                    visibleWidth=CGRectGetMaxX(self.containerView.frame)-CGRectGetMinX(frame);
                }
                
                if (visibleWidth<CGRectGetWidth(frame)/2.0) {
                    [self closeDrawer:visibleDrawerSide animated:YES completion:nil];
                    self.currentDrawerSide=DrawerSideNone;
                }
                else{
                    [self openDrawer:visibleDrawerSide animated:YES completion:nil];
                    self.currentDrawerSide=visibleDrawerSide;
                }
                
                [self resetDrawer:visibleDrawerSide==DrawerSideLeft? DrawerSideRight: DrawerSideLeft];
                
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Helper
-(DrawerSide)visibleDrawerSide
{
    if (CGRectGetMaxX(self.leftViewController.view.frame) > 0.0) {
        return DrawerSideLeft;
    }
    if (CGRectGetMinX(self.rightViewController.view.frame) < CGRectGetMaxX(self.containerView.frame)) {
        return DrawerSideRight;
    }
    return DrawerSideNone;
}

-(void)resetDrawers
{
    [self resetDrawer:DrawerSideLeft];
    [self resetDrawer:DrawerSideRight];
}

-(void)resetDrawer:(DrawerSide)drawerSide
{
    switch (drawerSide) {
        case DrawerSideLeft:{
            [self closeDrawer:DrawerSideLeft animated:NO completion:nil];
            break;
        }
        case DrawerSideRight:{
            [self closeDrawer:DrawerSideRight animated:NO completion:nil];
            break;
        }
        default:
            break;
    }
}

-(CGRect)visibleCenterRect
{
    if (self.currentDrawerSide==DrawerSideNone) {
        return self.centerContainerView.frame;
    }
    if (self.currentDrawerSide==DrawerSideLeft) {
        CGRect centerContainerRect=self.centerContainerView.frame;
        CGRect leftRect=self.leftViewController.view.frame;
        return CGRectMake(CGRectGetMaxX(leftRect), CGRectGetMinY(centerContainerRect), CGRectGetWidth(centerContainerRect)-CGRectGetWidth(leftRect), CGRectGetHeight(centerContainerRect));
    }
    if (self.currentDrawerSide==DrawerSideRight) {
        CGRect centerContainerRect=self.centerContainerView.frame;
        CGRect rightRect=self.rightViewController.view.frame;
        return CGRectMake(CGRectGetMinX(centerContainerRect), CGRectGetMinY(centerContainerRect), CGRectGetWidth(centerContainerRect)-CGRectGetWidth(rightRect), CGRectGetHeight(centerContainerRect));
    }
    return CGRectZero;
}

#pragma mark - Getter
-(UIView *)containerView
{
    if (_containerView) {
        return _containerView;
    }
    CGRect frame=self.view.frame;
    _containerView=[[UIView alloc]initWithFrame:frame];
    _containerView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _containerView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_containerView];
    return _containerView;
}

-(CenterContainerView *)centerContainerView
{
    if (_centerContainerView) {
        return _centerContainerView;
    }
    CGRect frame=self.view.frame;
    _centerContainerView=[[CenterContainerView alloc]initWithFrame:frame];
    _centerContainerView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _centerContainerView.backgroundColor=[UIColor clearColor];
    [self.containerView addSubview:_centerContainerView];
    return _centerContainerView;
}

-(UIViewController *)viewControllerForDrawerSide:(DrawerSide)drawerSide
{
    switch (drawerSide) {
        case DrawerSideLeft:
            return self.leftViewController;
            break;
        case DrawerSideRight:
            return self.rightViewController;
        default:
            return nil;
            break;
    }
}
#pragma mark - Setter
-(void)setCenterViewController:(UIViewController *)centerViewController
{
    if ([_centerViewController isEqual:centerViewController] || !centerViewController) {
        return;
    }
    
    if (_centerViewController) {
        //remove old center view controller
        [_centerViewController willMoveToParentViewController:nil];
        [_centerViewController beginAppearanceTransition:NO animated:NO];
        [_centerViewController removeFromParentViewController];
        [_centerViewController.view removeFromSuperview];
        [_centerViewController endAppearanceTransition];
    }
    
    //add new center view controller
    centerViewController.view.frame=self.containerView.frame;
    [centerViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:centerViewController];
    [self.centerContainerView addSubview:centerViewController.view];
    [centerViewController endAppearanceTransition];
    [centerViewController didMoveToParentViewController:self];
    
    _centerViewController=centerViewController;
}

-(void)setLeftViewController:(UIViewController *)leftViewController
{
    if ([_leftViewController isEqual:leftViewController] || !leftViewController) {
        return;
    }
    
    if (_leftViewController) {
        //remove old center view controller
        [_leftViewController willMoveToParentViewController:nil];
        [_leftViewController beginAppearanceTransition:NO animated:NO];
        [_leftViewController removeFromParentViewController];
        [_leftViewController.view removeFromSuperview];
        [_leftViewController endAppearanceTransition];
    }
    
    //add new center view controller
    leftViewController.view.frame=CGRectMake(-self.leftDrawerMaxWidth, 0, self.leftDrawerMaxWidth,self.view.bounds.size.height);
    [leftViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:leftViewController];
    [self.containerView addSubview:leftViewController.view];
    [self.containerView bringSubviewToFront:leftViewController.view];
    [leftViewController endAppearanceTransition];
    [leftViewController didMoveToParentViewController:self];
    
    _leftViewController=leftViewController;
}

-(void)setRightViewController:(UIViewController *)rightViewController
{
    if ([_rightViewController isEqual:rightViewController] || !rightViewController) {
        return;
    }
    
    if (_rightViewController) {
        //remove old center view controller
        [_rightViewController willMoveToParentViewController:nil];
        [_rightViewController beginAppearanceTransition:NO animated:NO];
        [_rightViewController removeFromParentViewController];
        [_rightViewController.view removeFromSuperview];
        [_rightViewController endAppearanceTransition];
    }
    
    //add new center view controller
    rightViewController.view.frame=CGRectMake(self.view.bounds.size.width, 0, self.rightDrawerMaxWidth, self.view.bounds.size.height);
    [rightViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:rightViewController];
    [self.containerView addSubview:rightViewController.view];
    [self.containerView bringSubviewToFront:rightViewController.view];
    [rightViewController endAppearanceTransition];
    [rightViewController didMoveToParentViewController:self];
    
    _rightViewController=rightViewController;
}

#pragma mark - Open & Close Drawer
-(void)toggleDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    
}
-(void)openDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide==DrawerSideLeft || drawerSide==DrawerSideRight);
    UIViewController *viewController=[self viewControllerForDrawerSide:drawerSide];
    CGRect frame=viewController.view.frame;
    switch (drawerSide) {
        case DrawerSideLeft:{
            frame.origin.x=0.0;
            break;
        }
        case DrawerSideRight:{
            frame.origin.x=CGRectGetWidth(self.containerView.frame)-CGRectGetWidth(frame);
            break;
        }
        default:
            break;
    }
    
    [UIView animateWithDuration:animated?1.0:0.0 animations:^{
        viewController.view.frame=frame;
    } completion:completion];
}

-(void)closeDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    NSParameterAssert(drawerSide==DrawerSideLeft || drawerSide==DrawerSideRight);
    UIViewController *viewController=[self viewControllerForDrawerSide:drawerSide];
    CGRect frame=viewController.view.frame;
    switch (drawerSide) {
        case DrawerSideLeft:{
            frame.origin.x=-CGRectGetWidth(frame);
            break;
        }
        case DrawerSideRight:{
            frame.origin.x=CGRectGetMaxX(self.containerView.frame);
            break;
        }
        default:
            break;
    }
    
    [UIView animateWithDuration:animated?1.0:0.0 animations:^{
        viewController.view.frame=frame;
    } completion:completion];
}

@end
