//
//  CCOLTypes.h
//  ColaLib
//
//  Created by Chris on 30/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLTypes_h
#define CCOLTypes_h

typedef float               SignalType;
typedef unsigned long long  CCOLComponentAddress;
typedef unsigned long long  CCOLInputAddress;
typedef unsigned long long  CCOLOutputAddress;
typedef unsigned long long  CCOLConnectorAddress;
typedef unsigned long long  CCOLParameterAddress;

#define kCCOLComponentTypeVCO           "CCOLComponentTypeVCO"
#define kCCOLComponentTypeEG            "CCOLComponentTypeEG"
#define kCCOLComponentTypeLFO           "CCOLComponentTypeLFO"
#define kCCOLComponentTypeVCA           "CCOLComponentTypeVCA"
#define kCCOLComponentTypeMultiples     "CCOLComponentTypeMultiples"
#define kCCOLComponentTypeMixer         "CCOLComponentTypeMixer"
#define kCCOLComponentTypePan           "CCOLComponentTypePan"
#define kCCOLComponentTypeSequencer     "CCOLComponentTypeSequencer"
#define KCCOLComponentTypeMIDI          "CCOLMIDIComponent"
#define kCCOLComponentNoiseGenerator    "CCOLComponentNoiseGenerator"
#define kCCOLComponentTypeVCF           "CCOLComponentTypeVCF"

// Interapp audio keys
#define kDictionaryKeyComponentName         @"kDictionaryKeyComponentName"
#define kDictionaryKeyComponentType         @"kDictionaryKeyComponentType"
#define kDictionaryKeyComponentSubtype      @"kDictionaryKeyComponentSubtype"
#define kDictionaryKeyComponentMaufacturer  @"kDictionaryKeyComponentManufacturer"

// Engine events
#define kCCOLEventEngineDidForceDisconnect  @"NSNoteEngineDidForceDisconnect"

typedef enum kIOType {
    kIOTypeInput    = 1,
    kIOTypeOutput   = 2,
    kIOTypeAudio    = 4,
    kIOTypeControl  = 8,
    kIOType1VOct    = 16,
    kIOTypeGate     = 32,
    kIOTypeDynamic  = 64
} kIOType;

typedef unsigned int CCOLDiscreteParameterIndex;

typedef unsigned int NoteIndex;

#endif /* CCOLTypes_h */
