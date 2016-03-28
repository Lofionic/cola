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

-(NSInteger)getRowForX:(CGFloat)x;
-(NSInteger)getColumnForY:(CGFloat)y;

@end

@class ModuleDescription;
@class ConnectorView;
@class ModuleControl;
@interface ModuleView : UIView

@property (nonatomic, weak) id<ModuleViewDelegate>  delegate;
@property (readonly) CCOLComponentAddress           component;
@property (readonly, strong) ModuleDescription      *moduleDescription;
@property (nonatomic, strong) NSArray               *connectorViews;
@property (nonatomic, strong) NSArray               *controlViews;
@property (nonatomic, strong) NSArray               *subviewViews;

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame componentID:(NSString*)componentID;
-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription;
-(void)setParametersFromDictionary:(NSDictionary*)dictionary; 
-(void)trash;

-(ConnectorView*)connectorForName:(NSString*)name;

-(NSDictionary*)getDictionary;

@end
