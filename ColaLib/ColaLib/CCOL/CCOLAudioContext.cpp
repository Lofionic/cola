//
//  CCOLAudioContext.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLAudioContext.hpp"

CCOLAudioContext::CCOLAudioContext() {
    // Constructor
    
    CCOLComponentInput masterL;
    masterL.init(NULL, kIOTypeAudio, (char*)"Master L");
    
    CCOLComponentInput masterR;
    masterR.init(NULL, kIOTypeAudio, (char*)"Master R");
    
    masterInputs = {
        masterL, masterR
    };
    
}