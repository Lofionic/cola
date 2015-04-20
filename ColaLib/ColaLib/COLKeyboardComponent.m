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
    bool gateOpen;
    bool gateTrigger;
}

@property (nonatomic, strong) COLComponentOutput *keyboardOut;
@property (nonatomic, strong) COLComponentOutput *gateOut;

@property (nonatomic) BOOL gliss;
@property (nonatomic) float pitchbend;
@property (nonatomic) NSInteger pitchWheelRange;

@end

@implementation COLKeyboardComponent

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        noteOns = [[NSMutableArray alloc] initWithCapacity:10];
        gateOpen = NO;
        self.gliss = NO;
    }
    return self;
}

-(void)initializeIO {
    self.keyboardOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"1VOct Out"];
    self.gateOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeGate withName:@"Gate Out"];
    [self setOutputs:@[self.keyboardOut, self.gateOut]];
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

-(void)allNotesOff {
    [noteOns removeAllObjects];
    [self closeGate];
    [self setFrequency];
}

-(void)setFrequency {
    if ([noteOns count] > 0) {
        // play last note
        NSInteger note = [[noteOns lastObject] integerValue];
        
        // Calculate note frequency
        float frequency = powf(2, (note - 69) / 12.0) * 440;
        
        // Convert to decimal value
        outputValue = frequency / CV_FREQUENCY_RANGE;
    } else {
        outputValue = 0;
    }
}

-(void)openGate {
    gateOpen = YES;
    gateTrigger = YES;

}

-(void)closeGate {
    gateOpen = NO;
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    // Output Buffers
    AudioSignalType *keyboardOutBuffer = [self.keyboardOut prepareBufferOfSize:numFrames];
    AudioSignalType *gateOutBuffer = [self.gateOut prepareBufferOfSize:numFrames];
    
    float pitchbendDelta = (self.pitchbend - prevPitchbend) / numFrames;
    
    for (int i = 0; i < numFrames; i++) {
        
        float pitchbendNormalized = prevPitchbend + (i * pitchbendDelta);
        
        float adjustValue = (pitchbendNormalized * 2.0) - 1.0;
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * self.pitchWheelRange));
        
        keyboardOutBuffer[i] = outputValue * adjustValue;
        
        if (gateOpen) {
            gateOutBuffer[i] = 1;
        } else {
            gateOutBuffer[i] = 0;
        }
    }
    
    if (gateTrigger && gateOpen) {
        gateOutBuffer[0] = 0;
        gateTrigger = NO;
    }
    
    prevPitchbend = self.pitchbend;
}

+(NSString *)defaultName {
    return @"KB";
}

@end
