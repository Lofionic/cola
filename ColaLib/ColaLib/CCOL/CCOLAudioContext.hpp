//
//  CCOLAudioContext.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLAudioContext_hpp
#define CCOLAudioContext_hpp

#include <stdio.h>
#include <vector>
#include "CCOLInterface.hpp"

using namespace std;

class CCOLComponentInput;
class CCOLAudioEngine;
class CCOLAudioContext {
 
public:
    CCOLAudioContext(CCOLAudioEngine *audioEngineIn, unsigned int interfaceInputCount) {
        
        audioEngine = audioEngineIn;
        
        interfaceComponent = new CCOLInterfaceComponent(this);
        interfaceComponent->initializeIO(interfaceInputCount);
    }
    
    CCOLInterfaceComponent *getInterfaceComponent() {
        return interfaceComponent;
    }
    
    CCOLAudioEngine *getEngine() {
        return audioEngine;
    }
    
private:
    CCOLInterfaceComponent *interfaceComponent;
    CCOLAudioEngine *audioEngine;
    
};

#endif /* CCOLAudioContext_hpp */
