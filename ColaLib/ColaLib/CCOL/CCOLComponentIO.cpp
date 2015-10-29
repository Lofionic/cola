//
//  CCOLComponentIO.cpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponentIO.hpp"

void CCOLComponentIO::init(CCOLComponent *inComponent, kComponentTIOype inType, char* inName) {
    component = inComponent;
    type = inType;
    name = inName;
    
    connectedComponent = nullptr;
}

void CCOLComponentIO::engineDidRender() {
    
}

bool CCOLComponentIO::isConnected() {
    return connectedComponent != nullptr;
}

bool CCOLComponentIO::disconnect() {
    return false;
}

bool CCOLComponentIO::isDynamic() {
    return false;
}
