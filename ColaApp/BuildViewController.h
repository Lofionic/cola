//
//  BuildViewController.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ComponentShelfView.h"
#import "IAAView.h"

@class BuildView;
@class Preset;
@interface BuildViewController : UIViewController <ComponentShelfDelegate, IAAViewDelegate>

@property (nonatomic, strong) NSString *filename;
@property (readonly) BOOL buildMode;

+(BuildView*)buildView;

-(void)recallPreset:(NSString*)presetName onCompletion:(void (^)(BOOL success))completion onError:(void (^)(NSError *error))error;
-(void)setBottomPanelHidden:(BOOL)keyboardHidden animated:(BOOL)animated onCompletion:(void (^)())onCompletion;
-(void)clear;

@end
