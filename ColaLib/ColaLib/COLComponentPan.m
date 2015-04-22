//
//  COLComponentPan.m
//  ColaLib
//
//  Created by Chris on 22/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentPan.h"
#import "COLContinuousParameter.h"

@interface COLComponentPan ()

@property (nonatomic, strong) COLComponentInput *input;
@property (nonatomic, strong) COLComponentInput *cvIn;

@property (nonatomic, strong) COLComponentOutput *output1;
@property (nonatomic, strong) COLComponentOutput *output2;

@property (nonatomic, strong) COLContinuousParameter *pan;

@end

@implementation COLComponentPan

-(void)initializeIO {
    
    self.input = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In"];
    self.cvIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"CV In"];
    self.inputs = @[self.input, self.cvIn];
    
    self.output1 = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out 1"];
    self.output2 = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out 2"];
    
    self.outputs = @[self.output1, self.output2];
    
    self.pan = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Pan"];
    self.parameters = @[self.pan];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    AudioSignalType *inputBuffer = [self.input getBuffer:numFrames];
    
    AudioSignalType *output1Buffer = [self.output1 prepareBufferOfSize:numFrames];
    AudioSignalType *output2Buffer = [self.output2 prepareBufferOfSize:numFrames];
    
    AudioSignalType *cvInBuffer = [self.cvIn getBuffer:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
 
        float pan;
        if ([self.cvIn isConnected]) {
            pan = (cvInBuffer[i] / 2.0) + [self.pan outputAtDelta:(float)i / numFrames];
            if (pan > 1) {
                pan = 1;
            } else if (pan < 0) {
                pan = 0;
            }
        } else {
            pan = [self.pan outputAtDelta:(float)i / numFrames];
        }
        
        output1Buffer[i] = inputBuffer[i] * pan;
        output2Buffer[i] = inputBuffer[i] * (1 - pan);
    }
}


@end
