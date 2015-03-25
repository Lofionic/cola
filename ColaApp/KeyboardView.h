//
//  keyboardView.h
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>

@interface KeyboardView : UIView

@property (nonatomic, weak) COLKeyboardComponent *kbComponent;
@property NSInteger keyboardShift;

@end