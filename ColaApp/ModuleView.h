//
//  ComponentView.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import "ComponentShelfView.h"
#import <UIKit/UIKit.h>

@class ModuleDescription;

@interface ModuleView : UIView

@property (weak) id<ComponentShelfDelegate> componentShelfDelegate;
@property (readonly, weak) COLComponent *component;

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame;
-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription;
-(UIImage*)snapshot;

@end
