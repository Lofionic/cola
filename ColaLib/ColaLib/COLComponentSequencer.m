//
//  COLComponentSequencer.m
//  ColaLib
//
//  Created by Chris on 27/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentSequencer.h"
#import "COLAudioEnvironment.h"
#import "COLDiscreteParameter.h"
#import "COLContinuousParameter.h"
#import "COLTransportController.h"

#define CV_FREQUENCY_RANGE 8372 // C9

@interface COLComponentSequencer () {
    
    float frequency;
    
}

@property (nonatomic, strong) COLComponentOutput *pitchOut;
@property (nonatomic, strong) COLComponentOutput *gateOut;

@property (nonatomic, strong) NSArray *pitchControls;
@property (nonatomic, strong) NSArray *gateControls;

@end

@implementation COLComponentSequencer

-(void)initializeIO {
    
    self.pitchOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"Pitch"];
    self.gateOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeGate withName:@"Gate"];
    [self setOutputs:@[self.pitchOut, self.gateOut]];
    
    NSMutableArray *controls = [[NSMutableArray alloc] initWithCapacity:48];
    NSMutableArray *pitchControls = [[NSMutableArray alloc] initWithCapacity:16];
    NSMutableArray *gateControls = [[NSMutableArray alloc] initWithCapacity:16];
    
    for (int i = 0; i < 16; i++) {
        NSString *name = [NSString stringWithFormat:@"Pitch %lu", (long)i + 1];
        COLContinuousParameter *pitchControl = [[COLContinuousParameter alloc] initWithComponent:self withName:name];
        [pitchControl setFunction:^float(float inValue) {
            float outValue = roundf(inValue * 12);
            
            return outValue;
        }];
        
        [pitchControls addObject:pitchControl];
        [controls addObject:pitchControl];
        
        name = [NSString stringWithFormat:@"Gate %lu", (long)i + 1];
        COLDiscreteParameter *gateControl = [[COLDiscreteParameter alloc] initWithComponent:self withName:name max:3];
        [gateControls addObject:gateControl];
        [controls addObject:gateControl];
    }
    
    self.gateControls = gateControls;
    self.pitchControls = pitchControls;
    [self setParameters:controls];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType *pitchOutputBuffer = [self.pitchOut prepareBufferOfSize:numFrames];
    AudioSignalType *gateOutputBuffer = [self.gateOut prepareBufferOfSize:numFrames];
    
    COLTransportController *transportController = [[COLAudioEnvironment sharedEnvironment] transportController];
    
    for (int i = 0; i < numFrames; i++) {
        
        UInt16 step = transportController.stepBuffer[i];
        
        gateOutputBuffer[i] = 0;
        
        if ([transportController isPlaying]) {
            COLDiscreteParameter *gateParameter = [self.gateControls objectAtIndex:step];
            if ([gateParameter selectedIndex] == 1) {
                if (transportController.stepDeltaBuffer[i] < 0.8) {
                    gateOutputBuffer[i] = 1;
                }
                COLContinuousParameter *pitchParameter = [self.pitchControls objectAtIndex:step];
                NSInteger pitchOutput = [pitchParameter outputAtDelta:((float)i / numFrames)];
                
                NSInteger note =  60 + pitchOutput;
                frequency = powf(2, (note - 69) / 12.0) * 440;
            }
        }
        
        pitchOutputBuffer[i] = frequency / CV_FREQUENCY_RANGE;
    }
}

@end
