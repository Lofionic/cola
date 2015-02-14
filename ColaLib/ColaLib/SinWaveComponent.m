//
//  SinWaveComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "SinWaveComponent.h"
#import "COLAudioEnvironment.h"

@interface SinWaveComponent () {
    float phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;
@property (nonatomic, strong) COLComponentInput *frequencyIn;
@property (nonatomic, strong) COLComponentInput *amplIn;

@end

@implementation SinWaveComponent

-(void)initializeIO {
    self.frequency = 440.0;
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio];
    
    self.frequencyIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl];
    self.amplIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl];
}

-(NSInteger)numberOfOutputs {
    return 1;
}

-(COLComponentOutput *)outputForIndex:(NSInteger)index {
    if (index == 0) {
        return self.mainOut;
    }
    
    return nil;
}

-(NSInteger)numberOfInputs {
    return 2;
}

-(COLComponentInput *)inputForIndex:(NSInteger)index {
    if (index == 0) {
        return self.frequencyIn;
    } else if (index == 1) {
        return self.amplIn;
    }
    
    return nil;
}

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
    AudioSignalType *frequencyBuffer = [self.frequencyIn renderSamples:numFrames];
    AudioSignalType *ampBuffer = [self.amplIn renderSamples:numFrames];
    
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        phase += (2.0 * M_PI * 220 * (frequencyBuffer[i] + 1)) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        outA[i] = sin(phase) * ampBuffer[i];
    }
}

@end
