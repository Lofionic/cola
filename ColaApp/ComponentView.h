//
//  ComponentView.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>
#import "ComponentDescription.h"

@interface ComponentView : UIView

@property (readonly, weak) COLComponent *component;

-(instancetype)initWithComponentDescription:(ComponentDescription *)componentDescription inFrame:(CGRect)frame;

@end
