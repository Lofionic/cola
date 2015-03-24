//
//  BuildViewHighlightLayer.h
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "BuildView.h"
#import <QuartzCore/QuartzCore.h>

@interface BuildViewHighlightLayer : CALayer

@property (nonatomic, weak) BuildView *buildView;

@end
