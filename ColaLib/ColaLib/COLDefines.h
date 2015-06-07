//
//  ColaDefines.h
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#define kDictionaryKeyComponentName         @"kDictionaryKeyComponentName"
#define kDictionaryKeyComponentType         @"kDictionaryKeyComponentType"
#define kDictionaryKeyComponentSubtype      @"kDictionaryKeyComponentSubtype"
#define kDictionaryKeyComponentMaufacturer  @"kDictionaryKeyComponentManufacturer"

#define kCOLComponentVCO                    @"COLComponentVCO"
#define kCOLComponentLFO                    @"COLComponentLFO"
#define kCOLComponentWavePlayer             @"COLComponentWavePlayer"
#define kCOLComponentEnvelope               @"COLComponentEnvelope"
#define kCOLComponentVCA                    @"COLComponentVCA"
#define kCOLComponentMultiples              @"COLComponentMultiples"
#define kCOLComponentMultiplesKB            @"COLComponentMultiplesKB"
#define kCOLComponentMixer2                 @"COLComponentMixer2"
#define kCOLComponentVCF                    @"COLComponentVCF"
#define kCOLComponentPan                    @"COLComponentPan"
#define kCOLComponentRingModulator          @"COLComponentRingModulator"
#define kCOLComponentSequencer              @"COLComponentSequencer"
#define kCOLComponentNoiseGenerator         @"COLComponentNoiseGenerator"
#define kCOLComponentDelay                  @"COLComponentDelay"

#define kCOLEventTransportStateUpdated          @"kCOLEventTransportStateUpdated"
#define kCOLEventDynamicInputDidForceDisconnect @"COLEventDynamicInputDidForceDisconnect"

#define kCOLOutputOscillatorMain            0
#define kCOLInputOscillatorFreq             0
#define kCOLInputOscillatorAmp              1

#define kCOLOutputLFOMain                   0
#define kCOLInputLFOFreqIn                  0

#import <Foundation/Foundation.h>
typedef Float32 AudioSignalType;


// Wavetables
#define WAVETABLE_SIZE      8196
#define ANALOG_HARMONICS    50

extern AudioSignalType sinWaveTable[WAVETABLE_SIZE];
extern AudioSignalType triWaveTable[WAVETABLE_SIZE];
extern AudioSignalType sawWaveTable[WAVETABLE_SIZE];
extern AudioSignalType rampWaveTable[WAVETABLE_SIZE];
extern AudioSignalType squareWaveTable[WAVETABLE_SIZE];