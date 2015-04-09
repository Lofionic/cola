//
//  ComponentView.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>

@class ModuleView;

@protocol ModuleViewDelegate <NSObject>

-(void)moduleView:(ModuleView*)moduleView didBeginDraggingWithGesture:(UIGestureRecognizer*)gesture;
-(void)moduleView:(ModuleView*)moduleView didContinueDraggingWithGesture:(UIGestureRecognizer*)gesture;
-(void)moduleView:(ModuleView*)moduleView didEndDraggingWithGesture:(UIGestureRecognizer*)gesture;

@end

@class ModuleDescription;
@interface ModuleView : UIView

@property (nonatomic, weak) id<ModuleViewDelegate>  delegate;
@property (readonly, weak) COLComponent             *component;
@property (readonly, strong) ModuleDescription      *moduleDescription;
@property (readonly, strong) NSString               *identifier;

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame;
-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription;
-(UIImage*)snapshot;
-(void)trash;

@end
