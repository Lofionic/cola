//
//  kCOLCompomentVCA.m
//  ColaLib
//
//  Created by Chris on 29/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLContinuousParameter.h"
#import "COLComponentVCA.h"

@interface COLComponentVCA ()

@property (nonatomic, strong) COLComponentInput *input;
@property (nonatomic, strong) COLComponentInput *CVIn;

@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLContinuousParameter *level;
@property (nonatomic, strong) COLContinuousParameter *CVAmt;

@end


@implementation COLComponentVCA

-(void)initializeIO {
    
    self.input = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In"];
    self.CVIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"CV In"];
    [self setInputs:@[self.input, self.CVIn]];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    [self setOutputs:@[self.output]];
    
    self.level = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Level"];
    [self.level setNormalizedValue:0];
    
    self.CVAmt = [[COLContinuousParameter alloc] initWithComponent:self withName:@"CV Amt"];
    [self.CVAmt setNormalizedValue:0];
    
    [self setParameters:@[self.level, self.CVAmt]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    AudioSignalType *inputBuffer = [self.input getBuffer:numFrames];
    AudioSignalType *outputBuffer = [self.output prepareBufferOfSize:numFrames];
    
    AudioSignalType *cvBuffer = [self.CVIn getBuffer:numFrames];
    
   
    for (int i = 0; i < numFrames; i++) {
        float delta = i / (float)numFrames;
        float amp = [self.level outputAtDelta:delta];
        if ([self.CVIn isConnected]) {
            amp = amp + (cvBuffer[i] * [self.CVAmt outputAtDelta:delta]);
            amp = MIN(MAX(amp, 0), 1);
        }
        
        AudioSignalType output = inputBuffer[i]  *amp;
        
        outputBuffer[i] = output;
    }
}


@end
