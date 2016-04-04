//
//  RenameFileViewController.h
//  ColaApp
//
//  Created by Chris on 01/04/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresetController;
@interface RenameFileViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSString*     presetName;

@property (readonly) UIImageView *thumbnailView;
@property (readonly) UITextField *textField;

@end
