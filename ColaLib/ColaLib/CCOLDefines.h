//
//  CCOLDefines.h
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLDefines_h
#define CCOLDefines_h

typedef float SignalType;

#define CV_FREQUENCY_RANGE 8372 // C9

#define WAVETABLE_SIZE      8196
#define ANALOG_HARMONICS    50

extern SignalType sinWaveTable[WAVETABLE_SIZE];
extern SignalType triWaveTable[WAVETABLE_SIZE];
extern SignalType sawWaveTable[WAVETABLE_SIZE];
extern SignalType rampWaveTable[WAVETABLE_SIZE];
extern SignalType squareWaveTable[WAVETABLE_SIZE];

#endif /* CCOLDefines_h */
