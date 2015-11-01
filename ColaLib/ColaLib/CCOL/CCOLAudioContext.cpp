//
//  CCOLAudioContext.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLAudioContext.hpp"
#include "CCOLComponentIO.hpp"

CCOLAudioContext::CCOLAudioContext() {
    // Constructor
    
    CCOLComponentInput *masterL = new CCOLComponentInput(NULL, kIOTypeAudio, (char*)"Master L");
    CCOLComponentInput *masterR = new CCOLComponentInput(NULL, kIOTypeAudio, (char*)"Master R");
    
    masterInputs = {
        masterL, masterR
    };
    
}