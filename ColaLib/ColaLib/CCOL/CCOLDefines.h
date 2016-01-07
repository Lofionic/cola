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

#define CV_FREQUENCY_RANGE 8372 // C9

#define WAVETABLE_SIZE      8196
#define ANALOG_HARMONICS    50

extern SignalType ccSinWaveTable[WAVETABLE_SIZE];
extern SignalType ccTriWaveTable[WAVETABLE_SIZE];
extern SignalType ccSawWaveTable[WAVETABLE_SIZE];
extern SignalType ccRampWaveTable[WAVETABLE_SIZE];
extern SignalType ccSquareWaveTable[WAVETABLE_SIZE];

const CFStringRef kCCOLEngineDidForceDisconnectNotification     = CFSTR("kCCOLEngineDidForceDisconnectNotification");
const CFStringRef kCCOLSetAudioSessionActiveNotification        = CFSTR("CCOLSetAudioSessionActiveNotification");
const CFStringRef kCCOLSetAudioSessionInactiveNotification      = CFSTR("CCOLSetAudioSessionInactiveNotification");

#endif /* CCOLDefines_h */
