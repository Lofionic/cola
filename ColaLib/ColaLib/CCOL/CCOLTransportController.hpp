//
//  CCOLTransportController.hpp
//  ColaLib
//
//  Created by Chris Rivers on 01/12/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLTransportController_hpp
#define CCOLTransportController_hpp

#include "CCOLAudioEngine.hpp"
#include <stdio.h>

class CCOLTransportController {
    CCOLAudioEngine*    engine;
    
    double          timeInMS;
    unsigned short  currentStep;
    double          tempo;
    
    unsigned long   bufferSize;
    double          currentBeat;
    
    bool            playing;
    double*         beatBuffer;
    
    void postUpdateNotification();
    void syncWithIAA();
    
public:
    
    CCOLTransportController(CCOLAudioEngine *inEngine) {
        engine = inEngine;
        
        timeInMS        = 0;
        currentStep     = 0;
        tempo           = 120;
        
        bufferSize  = 0;
        currentBeat = 0;
        
        playing = false;
        beatBuffer = nullptr;
    }
    
    bool isPlaying() {
        return playing;
    }
    
    double* getBeatBuffer() {
        return beatBuffer;
    }
    
    void start();
    void stop();
    void stopAndReset();
    void renderOutputs(unsigned int numFrames, double sampleRate);
    void interappAudioTransportStateDidChange(bool hostIsPaying);
};

#endif /* CCOLTransportController_hpp */
