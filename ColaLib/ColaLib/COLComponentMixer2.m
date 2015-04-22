//
//  COLComponentMixer2.m
//  ColaLib
//
//  Created by Chris on 06/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentMixer2.h"
#import "COLContinuousParameter.h"

@interface COLComponentMixer2 ()

@property (nonatomic, strong) COLComponentInput *input1;
@property (nonatomic, strong) COLComponentInput *input2;
@property (nonatomic, strong) COLComponentInput *cvIn;

@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLContinuousParameter *pan;

@end

@implementation COLComponentMixer2

-(void)initializeIO {
    
    self.input1 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 1"];
    self.input2 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 2"];
    self.cvIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"CV In"];
    
    self.inputs = @[self.input1, self.input2, self.cvIn];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    self.outputs = @[self.output];
    
    self.pan = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Pan"];
    [self.pan setNormalizedValue:0.5];
    self.parameters = @[self.pan];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    AudioSignalType *input1Buffer = [self.input1 getBuffer:numFrames];
    AudioSignalType *input2Buffer = [self.input2 getBuffer:numFrames];
    AudioSignalType *cvInBuffer = [self.cvIn getBuffer:numFrames];
    
    AudioSignalType *outputBuffer = [self.output prepareBufferOfSize:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
        
        float pan;
        if ([self.cvIn isConnected]) {
            pan = (cvInBuffer[i] / 2.0) + [self.pan outputAtDelta:(float)i / numFrames];
            if (pan > 1) {
                pan = 1;
            } else if (pan < -1) {
                pan = -1;
            }
        } else {
            pan = [self.pan outputAtDelta:(float)i / numFrames];
        }
        
        AudioSignalType result = input1Buffer[i] + (input2Buffer[i] - input1Buffer[i]) * pan;
        
        outputBuffer[i] = result;
    }
}

+(NSString *)defaultName {
    return @"Mix2";
}

@end
