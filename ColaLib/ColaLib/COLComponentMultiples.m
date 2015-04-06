//
//  COLMultiples.m
//  ColaLib
//
//  Created by Chris on 06/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentMultiples.h"

@interface COLComponentMultiples ()

@property (nonatomic, strong) COLComponentInput *inputA;
@property (nonatomic, strong) NSArray *outAs;

@property (nonatomic, strong) COLComponentInput *inputB;
@property (nonatomic, strong) NSArray *outBs;

@end

@implementation COLComponentMultiples

-(void)initializeIO {
    
    self.inputA = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"In A"];
    self.inputB = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"In B"];
    
    NSMutableArray *outputs = [[NSMutableArray alloc] initWithCapacity:8];
    for (NSInteger i = 0; i < 4; i++) {
        COLComponentOutput *newOutputA = [[COLComponentOutput alloc] initWithComponent:self
                                                                               ofType:kComponentIOType1VOct
                                                                             withName:[NSString stringWithFormat:@"Out A%ld", (long)i + 1]];
        [outputs addObject:newOutputA];
    }
    
    for (NSInteger i = 0; i < 4; i++) {
        COLComponentOutput *newOutputB = [[COLComponentOutput alloc] initWithComponent:self
                                                           ofType:kComponentIOTypeControl
                                                         withName:[NSString stringWithFormat:@"Out B%ld", (long)i + 1]];
        
        [outputs addObject:newOutputB];
    }
    
    [self setOutputs:[NSArray arrayWithArray:outputs]];
    [self setInputs:@[self.inputA, self.inputB]];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType *inputABuffer = [self.inputA getBuffer:numFrames];
    AudioSignalType *inputBBuffer = [self.inputB getBuffer:numFrames];
    
    AudioSignalType *outputBuffers[8];
    
    for (int j = 0; j < 8; j++) {
        COLComponentOutput *thisOut = [self.outputs objectAtIndex:j];
        outputBuffers[j] = [thisOut prepareBufferOfSize:numFrames];
    }
    
    for (int i = 0; i < numFrames; i++) {
        
        for (int j = 0; j < 4; j++) {
            COLComponentOutput *outA = [self.outputs objectAtIndex:j];
            if ([outA isConnected]) {
                outputBuffers[j][i] = inputABuffer[i];
            }
            
            COLComponentOutput *outB = [self.outputs objectAtIndex:j + 4];
            if ([outB isConnected]) {
                outputBuffers[j][i] = inputBBuffer[i];
            }
        }
    }
}

@end
