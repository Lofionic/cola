//
//  BuildViewController.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentShelfView.h"
#import "BuildView.h"

#import <UIKit/UIKit.h>

@interface BuildViewController : UIViewController <ComponentShelfDelegate>

+(BuildView*)buildView;

@end
