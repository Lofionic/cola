//
//  SequencerSubview.h
//  ColaApp
//
//  Created by Chris on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//
#import "ModuleSubview.h"
#import <UIKit/UIKit.h>

@interface SequencerSubview : ModuleSubview

@end

@class Step;
@interface StepSequence : NSObject

@property (readonly) NSUInteger length;

- (instancetype)initWithLength:(NSUInteger)length;
- (Step*)getStep:(NSUInteger)step;

@end

@interface Step : NSObject

@property (nonatomic) NSInteger note;

@end