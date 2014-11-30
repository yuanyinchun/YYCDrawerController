//
//  YYCDrawerController.h
//  YYCDrawerControllerDemo
//
//  Created by yuanyinchun on 11/28/14.
//  Copyright (c) 2014 YYC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DrawerLayer){
    DrawerLayerBack=0,
    DrawerLayerFront
};

typedef NS_ENUM(NSUInteger, DrawerSide){
    DrawerSideNone=0,
    DrawerSideLeft,
    DrawerSideRight
};

@interface YYCDrawerController : UIViewController

@property (nonatomic) CGFloat leftDrawerMaxWidth;
@property (nonatomic) CGFloat rightDrawerMaxWidth;
@property (nonatomic) DrawerSide currentDrawerSide;


-(id)initWithCenterViewController:(UIViewController *)centerViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController;
-(void)setCenterViewController:(UIViewController *)centerViewController;
-(void)setLeftViewController:(UIViewController *)leftViewController;
-(void)setRightViewController:(UIViewController *)rightViewController;

-(void)toggleDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
-(void)openDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
-(void)closeDrawer:(DrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;


@end
