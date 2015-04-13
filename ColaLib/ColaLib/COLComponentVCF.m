//
//  COLComponentVCF.m
//  ColaLib
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentVCF.h"
#import "COLContinuousParameter.h"

@interface COLComponentVCF ()

@property (nonatomic, strong) COLComponentInput *input;
@property (nonatomic, strong) COLComponentInput *cvIn;

@property (nonatomic, strong) COLComponentOutput *lpOut;
@property (nonatomic, strong) COLComponentOutput *hpOut;
@property (nonatomic, strong) COLComponentOutput *bpOut;
@property (nonatomic, strong) COLComponentOutput *notchOut;

@property (nonatomic, strong) COLContinuousParameter *freq;
@property (nonatomic, strong) COLContinuousParameter *resonance;
@property (nonatomic, strong) COLContinuousParameter *cvAmount;


@end


@implementation COLComponentVCF {
    float f, p, q;             //filter coefficients
    float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
    float t1, t2;
}

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        f = p = q = b0 = b1 = b2 = b3 = b4 = t1 = t2 = 0;
    }
    return self;
}

-(void)initializeIO {
    self.input = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In"];
    self.cvIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"CV In"];
    self.inputs = @[self.input, self.cvIn];
    
    self.lpOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"LP Out"];
    self.hpOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"HP Out"];
    self.bpOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"BP Out"];
    self.notchOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Notch Out"];
    self.outputs = @[self.lpOut, self.hpOut, self.bpOut, self.notchOut];
    
    self.freq = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Cutoff"];
    self.resonance = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Resonance"];
    self.cvAmount = [[COLContinuousParameter alloc] initWithComponent:self withName:@"CV Amt"];
    self.parameters = @[self.freq, self.resonance, self.cvAmount];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType *inputBuffer = [self.input getBuffer:numFrames];
    AudioSignalType *cvBuffer = [self.cvIn getBuffer:numFrames];
    AudioSignalType *lpOut = [self.lpOut prepareBufferOfSize:numFrames];
    AudioSignalType *hpOut = [self.hpOut prepareBufferOfSize:numFrames];
    AudioSignalType *bpOut = [self.bpOut prepareBufferOfSize:numFrames];
    AudioSignalType *notchOut = [self.notchOut prepareBufferOfSize:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
        
        AudioSignalType valueIn = inputBuffer[i];
        
        if (valueIn > 1) {
            valueIn = 1;
        } else if (valueIn < -1) {
            valueIn = -1;
        }
        
        float delta = (i / (float)numFrames);
        float cutoff = [self.freq outputAtDelta:delta];
        
        if ([self.cvIn isConnected]) {
            cutoff = cutoff + (cvBuffer[i] * [self.cvAmount outputAtDelta:delta]);
            cutoff = MIN(MAX(cutoff, 0), 1);
        }
        
        
        q = 1.0f - cutoff;
        p = cutoff + 0.8f * cutoff * q;
        f = p + p - 1.0f;
        
        float res = [self.resonance outputAtDelta:delta];
        q = res * (1.0f + 0.5f * q * (1.0f - q + 5.6f * q * q));
        
        valueIn -= q * b4; //feedback
        
        t1 = b1;  b1 = (valueIn + b0) * p - b1 * f;
        t2 = b2;  b2 = (b1 + t1) * p - b2 * f;
        t1 = b3;  b3 = (b2 + t2) * p - b3 * f;
        b4 = (b3 + t1) * p - b4 * f;
        hpOut[i] = (AudioSignalType)b4;
        
        b4 = b4 - b4 * b4 * b4 * 0.166667f;    //clipping
        
        if ([self.lpOut isConnected]) {
            lpOut[i] = (AudioSignalType)b4;
        }
        
        if ([self.hpOut isConnected]) {
            hpOut[i] = (AudioSignalType)(valueIn - b4);
        }
        
        if ([self.bpOut isConnected]) {
            bpOut[i] = (AudioSignalType)(3.0f * (b3 - b4));
        }
        
        if ([self.notchOut isConnected]) {
            notchOut[i] = (AudioSignalType)(valueIn - (3.0f * (b3 - b4)));
        }
        
        b0 = valueIn;
    }

}

@end
