//
//  COLKeyboardComponent.m
//  ColaLib
//
//  Created by Chris on 25/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLKeyboardComponent.h"

#define CV_FREQUENCY_RANGE 8372 // C9

@interface COLKeyboardComponent () {
    NSMutableArray *noteOns;
    AudioSignalType outputValue;
    float prevPitchbend;
}

@property (nonatomic, strong) COLComponentOutput *keyboardOut;

@property (nonatomic) BOOL gliss;
@property (nonatomic) float pitchbend;
@property (nonatomic) NSInteger pitchWheelRange;

@end

@implementation COLKeyboardComponent

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        noteOns = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(void)initializeIO {
    self.keyboardOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"Out"];
    [self setOutputs:@[self.keyboardOut]];
}

-(void)noteOn:(NSInteger)note {
    
    // Note has been added
    NSNumber *noteNumber = [NSNumber numberWithInteger:note];
    
    if (![noteOns containsObject:noteNumber]) {
        
        if (self.gliss) {
            [noteOns addObject:noteNumber];
            // Only open gate on first note
            if ([noteOns count] == 1) {
                [self openGate];
            }
        } else {
            [noteOns addObject:noteNumber];
            [self openGate];
        }
        [self setFrequency];
    }
}

-(void)noteOff:(NSInteger)note {
    
    // Note has been removed
    NSNumber *noteNumber = [NSNumber numberWithInteger:note];
    
    if ([noteOns containsObject:noteNumber]) {
        
        NSNumber *lastOn = [noteOns lastObject];
        
        [noteOns removeObject:noteNumber];
        
        if ([noteOns count] == 0) {
            [self closeGate];
        } else {
            [self setFrequency];
            if (!self.gliss && noteNumber == lastOn) {
                [self openGate];
            }
        }
    }
}

-(void)setFrequency {
    // play last note
    NSInteger note = [[noteOns lastObject] integerValue];
    
    // Calculate note frequency
    float frequency = powf(2, (note - 69) / 12.0) * 440;
    
    // Convert to decimal value
    outputValue = frequency / CV_FREQUENCY_RANGE;
}

-(void)openGate {
    // Trigger open gate in every gate component

}

-(void)closeGate {
    // Trigger close gate in every gate component

}

-(void)renderOutputs:(UInt32)numFrames {
    // Output Buffers
    AudioSignalType *keyboardOutBuffer = [self.keyboardOut prepareBufferOfSize:numFrames];
    
    float pitchbendDelta = (self.pitchbend - prevPitchbend) / numFrames;
    
    for (int i = 0; i < numFrames; i++) {
        
        float pitchbendNormalized = prevPitchbend + (i * pitchbendDelta);
        
        float adjustValue = (pitchbendNormalized * 2.0) - 1.0;
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * self.pitchWheelRange));
        
        keyboardOutBuffer[i] = outputValue * adjustValue;
    }
    
    prevPitchbend = self.pitchbend;
}

@end
