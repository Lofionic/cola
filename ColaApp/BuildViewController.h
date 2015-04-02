//
//  BuildViewController.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentShelfView.h"

#import <UIKit/UIKit.h>

@class BuildView;
@interface BuildViewController : UIViewController <ComponentShelfDelegate>

@property (readonly) BOOL buildMode;

+(BuildView*)buildView;

@end
