//
//  CCOLComponentIO.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentIO_hpp
#define CCOLComponentIO_hpp

#include <stdio.h>

typedef float SignalType;

class CCOLComponent;
class CCOLComponentIO {
    enum kComponentTIOype {
        kComponentIOTypeAudio,
        kComponentIOTypeControl,
        kComponentIOType1VOct,
        kComponentIOTypeGate,
        kComponentIOTypeDynamic
    };
    
private:
    char*               name;
    kComponentTIOype    type;
    
    CCOLComponent*      component;
    CCOLComponent*      connectedComponent;

public:
    void init(CCOLComponent *component, kComponentTIOype type, char* name);
    void engineDidRender();
    bool disconnect();
    
    bool isConnected();
    bool isDynamic();
};


class CCOLComponentOutput;
class CCOLComponentInput {
    
public:
    SignalType*     getBuffer(unsigned int numFrames);
    bool            makeDynamicConnection(CCOLComponentOutput output);
};

#endif /* CCOLComponentIO_hpp */
