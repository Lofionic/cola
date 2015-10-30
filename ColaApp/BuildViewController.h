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
@class Preset;
@interface BuildViewController : UIViewController <ComponentShelfDelegate>

@property (readonly) BOOL buildMode;

+(BuildView*)buildView;

-(void)recallPreset:(Preset*)preset completion:(void (^)(BOOL success))completion;
-(void)setKeyboardHidden:(BOOL)keyboardHidden animated:(BOOL)animated;

@end
