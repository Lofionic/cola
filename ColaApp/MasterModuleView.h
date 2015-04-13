//
//  MasterModuleView.h
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ModuleView.h"
@class BuildView;
@interface MasterModuleView : ModuleView

-(instancetype)initWithFrame:(CGRect)frame buildView:(BuildView*)buildView;

@end
