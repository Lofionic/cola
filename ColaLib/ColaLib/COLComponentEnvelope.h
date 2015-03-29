//
//  COLCompenentEnvelope.h
//  ColaLib
//
//  Created by Chris on 28/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponent.h"

typedef NS_ENUM(NSUInteger, kCOLEnvelopeState) {
    kCOLEnvelopeStateClosed,
    kCOLEnvelopeStateAttack,
    kCOLEnvelopeStateDecay,
    kCOLEnvelopeStateSustain,
    kCOLEnvelopeStateRelease
};

@interface COLComponentEnvelope : COLComponent

@property (nonatomic) BOOL retriggers;

-(void)openGate;
-(void)closeGate;

@end
