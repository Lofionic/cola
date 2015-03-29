//
//  kCOLCompomentVCA.m
//  ColaLib
//
//  Created by Chris on 29/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentVCA.h"

@interface COLComponentVCA ()

@property (nonatomic, strong) COLComponentInput *input;
@property (nonatomic, strong) COLComponentInput *CVIn;

@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLComponentParameter *level;
@property (nonatomic, strong) COLComponentParameter *CVAmt;

@end


@implementation COLComponentVCA

-(void)initializeIO {
    
    self.input = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In"];
    self.CVIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"CV In"];
    [self setInputs:@[self.input, self.CVIn]];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    [self setOutputs:@[self.output]];
    
    self.level = [[COLComponentParameter alloc] initWithComponent:self withName:@"Level"];
    [self.level setNormalizedValue:0.5];
    
    self.CVAmt = [[COLComponentParameter alloc] initWithComponent:self withName:@"CV Amt"];
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
        AudioSignalType output = inputBuffer[i]  * [self.level outputAtDelta:delta];
        
        if ([self.CVIn isConnected]) {
            output = output + (((cvBuffer[i] * output) - output) * [self.CVAmt outputAtDelta:delta]);
        }

        outputBuffer[i] = output;
    }
}


@end
