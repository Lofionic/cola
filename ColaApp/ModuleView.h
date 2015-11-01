//
//  ComponentView.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/CCOLTypes.h>
#import <UIKit/UIKit.h>

@class ModuleView;

@protocol ModuleViewDelegate <NSObject>

-(void)moduleView:(ModuleView*)moduleView didBeginDraggingWithGesture:(UIGestureRecognizer*)gesture;
-(void)moduleView:(ModuleView*)moduleView didContinueDraggingWithGesture:(UIGestureRecognizer*)gesture;
-(void)moduleView:(ModuleView*)moduleView didEndDraggingWithGesture:(UIGestureRecognizer*)gesture;

@end

@class ModuleDescription;
@class ConnectorView;
@class ModuleControl;
@interface ModuleView : UIView

@property (nonatomic, weak) id<ModuleViewDelegate>  delegate;
@property (readonly) CCOLComponentAddress           component;
@property (readonly, strong) ModuleDescription      *moduleDescription;
@property (nonatomic, strong) NSString              *identifier;
@property (nonatomic, strong) NSArray               *connectorViews;
@property (nonatomic, strong) NSArray               *controlViews;

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame identifier:(NSString*)identifier;
-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription;
-(void)setParametersFromDictionary:(NSDictionary*)parametersDictionary;
-(void)trash;

-(ConnectorView*)connectorForName:(NSString*)name;

@end
