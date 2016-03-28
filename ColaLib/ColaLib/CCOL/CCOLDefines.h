//
//  CCOLDefines.h
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLDefines_h
#define CCOLDefines_h

#import "CCOLTypes.h"
#import <UIKit/UIKit.h>

#define WAVETABLE_SIZE      65584
#define ANALOG_HARMONICS    100

extern SignalType ccSinWaveTable[WAVETABLE_SIZE];
extern SignalType ccTriWaveTable[WAVETABLE_SIZE];
extern SignalType ccSawWaveTable[WAVETABLE_SIZE];
extern SignalType ccRampWaveTable[WAVETABLE_SIZE];
extern SignalType ccSquareWaveTable[WAVETABLE_SIZE];

const CFStringRef kCCOLEngineDidForceDisconnectNotification     = CFSTR("CCOLEngineDidForceDisconnectNotification");
const CFStringRef kCCOLSetAudioSessionActiveNotification        = CFSTR("CCOLSetAudioSessionActiveNotification");
const CFStringRef kCCOLSetAudioSessionInactiveNotification      = CFSTR("CCOLSetAudioSessionInactiveNotification");

const CFStringRef kCCOLComponentsKey            = CFSTR("components");
const CFStringRef kCCOLInterfaceComponentKey    = CFSTR("interface");
const CFStringRef kCCOLMIDIComponentKey         = CFSTR("MIDI");
const CFStringRef kCCOLComponentIdentifierKey   = CFSTR("identifier");
const CFStringRef kCCOLComponentTypeKey         = CFSTR("type");
const CFStringRef kCCOLComponentParametersKey   = CFSTR("parameters");
const CFStringRef kCCOLComponentConnectionsKey  = CFSTR("connections");

#endif /* CCOLDefines_h */
