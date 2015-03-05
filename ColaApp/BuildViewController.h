//
//  BuildViewController.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentTrayView.h"
#import "BuildView.h"

#import <UIKit/UIKit.h>

@interface BuildViewController : UIViewController <ComponentTrayDelegate>

@property (nonatomic, strong) BuildView             *buildView;
@property (nonatomic, strong) ComponentTrayView     *componentTray;

@property (nonatomic, strong) UIView                *dragView;

@end
