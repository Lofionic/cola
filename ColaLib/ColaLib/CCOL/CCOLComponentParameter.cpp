//
//  CCOLParameter.cpp
//  ColaLib
//
//  Created by Chris on 01/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponents.h"
#include "CCOLComponentParameter.hpp"

void CCOLContinuousParameter::setNormalizedValue(double newValue) {
    if (newValue >= 0 && newValue <= 1) {
        pendingValue = newValue;
        component->parameterDidChange(this);
    }
}

double CCOLContinuousParameter::getNormalizedValue() {
    return pendingValue;
}

void CCOLContinuousParameter::engineDidRender() {
    preValue = postValue;
    postValue = pendingValue;
}

double CCOLContinuousParameter::getOutputAtDelta(float delta) {
    float f = ((postValue - preValue) * delta) + preValue;
    
    if (f == cacheIn) {
        return cacheOut;
    } else {
        cacheIn = f;
        f = function(f);
        cacheOut = f;
        return f;
    }
}