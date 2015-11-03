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
class CCOLAudioContext {
 
public:
    CCOLAudioContext(unsigned int interfaceInputCount) {
        interfaceComponent = new CCOLInterfaceComponent(this);
        interfaceComponent->initializeIO(2);
    }
    
    CCOLInterfaceComponent *getInterfaceComponent() {
        return interfaceComponent;
    }
    
private:
    CCOLInterfaceComponent *interfaceComponent;
    
};

#endif /* CCOLAudioContext_hpp */
