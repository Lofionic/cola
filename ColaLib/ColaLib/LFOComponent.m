//
//  LFOComponent.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "LFOComponent.h"
#import "COLAudioEnvironment.h"

@interface LFOComponent () {
    float phase;
}

@property (nonatomic, strong) COLComponentOutput *mainOut;

@end

@implementation LFOComponent

-(void)initializeIO {
    self.frequency = 1;
    self.mainOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl];
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

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
        
    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        phase += (2.0 * M_PI * self.frequency) / sampleRate;
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        outA[i] = 0.5 + (sin(phase) / 2);
    }
}

@end
