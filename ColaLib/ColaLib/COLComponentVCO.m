//
//  SinWaveComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLContinuousParameter.h"
#import "COLDiscreteParameter.h"
#import "COLComponentVCO.h"
#import "COLAudioEnvironment.h"
#import "COLComponentInput.h"
#import "COLKeyboardComponent.h"

#define CV_FREQUENCY_RANGE  8372
#define WAVETABLE_SIZE      8196
#define ANALOG_HARMONICS    50

@interface COLComponentVCO () {
    Float64 phase;
    
    AudioSignalType prevResult;
    AudioSignalType sinWaveTable[WAVETABLE_SIZE];
    AudioSignalType triWaveTable[WAVETABLE_SIZE];
    AudioSignalType sawWaveTable[WAVETABLE_SIZE];
    AudioSignalType squareWaveTable[WAVETABLE_SIZE];
    
    NSInteger waveformIndex;
}

@property (nonatomic, strong) COLComponentInput     *keyboardIn;
@property (nonatomic, strong) COLComponentInput     *fmodIn;

@property (nonatomic, strong) COLComponentOutput    *out;

@property (nonatomic, strong) COLDiscreteParameter      *range;
@property (nonatomic, strong) COLDiscreteParameter      *waveform;
@property (nonatomic, strong) COLContinuousParameter    *tune;
@property (nonatomic, strong) COLContinuousParameter    *fmAmt;

@end

@implementation COLComponentVCO

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        [self buildWavetables];
    }
    return self;
}

-(void)buildWavetables {
    // Generate Sin wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        AudioSignalType a = sin(tablePhase);
        sinWaveTable[i] = a;
    }
    
    // Generate Saw wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j <= ANALOG_HARMONICS; j++) {
            result -= (sin(tablePhase * j) / j) / 2.0;
        }
        sawWaveTable[i] = (AudioSignalType)result;
    }
    
    // Generate Tri wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        
        int harmonicNumber = 1;
        bool inverse = false;
        for (int j = 1; j < (ANALOG_HARMONICS * 2) + 1; j += 2) {
            
            harmonicNumber ++;
            if (inverse) {
                result -= sin(tablePhase * j) / powf(((j) + 1), 2) / 0.5f;
                inverse = false;
            } else {
                result += sin(tablePhase * j) / powf(((j) + 1), 2) / 0.5f;
                inverse = true;
            }
        }
        
        triWaveTable[i] = result;
    }
    
    // Generate Square wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double sum = 0;
        float count = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < ANALOG_HARMONICS + 1;j += 2) {
            sum += sin(tablePhase * j);
            count ++;
        }
        sum /= count;
        squareWaveTable[i] = 0;
    }
    
    // NSLOG a wave
    int res = 10;
    for (int i = 0; i < res; i++) {
        NSInteger sampleIndex = (i / (float)res) * WAVETABLE_SIZE;
        AudioSignalType sample = triWaveTable[sampleIndex];
        
        NSInteger level = ((sample + 1) / 2.0) * 40;
        NSString *padding = [@"" stringByPaddingToLength:level withString:@"-" startingAtIndex:0];
        NSLog(@"%@", [padding stringByAppendingString:@"*"]);
    }
}

-(void)initializeIO {
    // Inputs
    self.keyboardIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"Keyboard In"];
    self.fmodIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FM In"];
    [self setInputs:@[self.keyboardIn, self.fmodIn]];
    
    // Outputs
    self.out = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    [self setOutputs:@[self.out]];
    
    // Parameters
    self.range = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Range" max:4];
    [self.range setSelectedIndex:0];
    self.waveform = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Waveform" max:4];
    [self.waveform setSelectedIndex:0];
    self.tune = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Tune"];
    [self.tune setNormalizedValue:0.5];
    [self.tune setFunction:^float(float inValue) {
        float output = (inValue * 2.0) - 1.0;
        return (powf(powf(2, (1.0 / 12.0)), output * 7));
    }];
    
    self.fmAmt = [[COLContinuousParameter alloc] initWithComponent:self withName:@"FM Amt"];
    [self.fmAmt setNormalizedValue:0.5];
    [self setParameters:@[self.range, self.waveform, self.tune, self.fmAmt]];
}

-(void)renderOutputs:(UInt32)numFrames {

    [super renderOutputs:numFrames];

    // Input Buffers
    AudioSignalType *fmBuffer = [self.fmodIn getBuffer:numFrames];
    
    // Keyboard Buffer
    AudioSignalType *kbBuffer = [self.keyboardIn getBuffer:numFrames];

    // Output Buffers
    AudioSignalType *outBuffer = [self.out prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        
        float sampleIndexFloat = (phase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
        
        NSInteger waveform = [self.waveform selectedIndex];
        AudioSignalType sampleIndexLower = 0;
        AudioSignalType sampleIndexUpper = 0;
        if (waveform == 0) {
            // Sinwave
            sampleIndexLower = sinWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = sinWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 1) {
            // Triwave
            sampleIndexLower = triWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = triWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 2) {
            // Sawtooth
            sampleIndexLower = sawWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = sawWaveTable[(int)ceil(sampleIndexFloat)];
        } else if (waveform == 3) {
            // Square (pulse)
            sampleIndexLower = squareWaveTable[(int)floor(sampleIndexFloat)];
            sampleIndexUpper = squareWaveTable[(int)ceil(sampleIndexFloat)];
        }
        
        float remainder = fmodf(sampleIndexFloat, 1);
        
        AudioSignalType result = sampleIndexLower + (sampleIndexUpper - sampleIndexLower) * remainder;
        
        // Increment phase
        
        AudioSignalType freq = FLT_MIN;
        
        if ([self.keyboardIn isConnected]) {
            freq = kbBuffer[i];
        }
        
        if ([self.fmodIn isConnected]) {
            float delta = i / (float)numFrames;
            float lfoValue = powf(0.5, (-fmBuffer[i] * [self.fmAmt outputAtDelta:delta]));
            freq *= lfoValue;
        }
        
        phase += (M_PI * freq * CV_FREQUENCY_RANGE * powf(2, [self.range selectedIndex]) * [self.tune outputAtDelta:((float)i / numFrames)]) / sampleRate;
        
        if (phase > 2.0 * M_PI) {
            phase -= (2.0 * M_PI);
        }
        
        // Change waveform on zero crossover
        if ((result > 0) != (prevResult < 0) || result == 0) {
            if (waveformIndex != [self.waveform selectedIndex]) {
                waveformIndex = [self.waveform selectedIndex];
                phase = 0;
            }
        }
        
        outBuffer[i] = result;
        prevResult = result;
    }
}

@end
