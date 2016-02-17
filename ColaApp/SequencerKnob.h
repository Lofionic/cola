//
//  SequenerKnob.h
//  ColaApp
//
//  Created by Chris on 04/02/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SequencerSubview;
@class SequencerKnob;
@protocol SequencerKnobDelegate <NSObject>
-(void)sequencerKnob:(SequencerKnob*)knob didChangeLevelTo:(float)level;
@end

@interface SequencerKnob : UIControl
@property (nonatomic, readonly) double level;
@property (nonatomic, weak) IBOutlet SequencerSubview<SequencerKnobDelegate> *delegate;

-(void)setLevel:(double)level animated:(BOOL)animated;

@end
