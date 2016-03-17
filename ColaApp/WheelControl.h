//
//  WheelControl.h
//  Ogre
//
//  Created by Chris on 10/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, WheelControlType) {
    WheelControlTypePitchbend,
    WheelControlTypeModulation
};
@interface WheelControl : UIControl

@property WheelControlType wheelControlType;
@property (nonatomic, strong) UIImage* spriteSheet;
@property CGSize spriteSize;
@property CGFloat value;

@end