//
//  CCOLParameter.cpp
//  ColaLib
//
//  Created by Chris on 01/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#include "CCOLComponents.h"
#include "CCOLComponentParameter.hpp"

void CCOLComponentParameter::setNormalizedValue(double valueIn) {
    if (valueIn >= 0 && valueIn <= 1) {
        pendingValue = valueIn;
        component->parameterDidChange(this);
    }
}

double CCOLComponentParameter::getNormalizedValue() {
    return pendingValue;
}

void CCOLComponentParameter::engineDidRender() {
    preValue = postValue;
    postValue = pendingValue;
}

double CCOLComponentParameter::getOutputAtDelta(float delta) {
    float f = ((postValue - preValue) * delta) + preValue;
    
    if (f == cachedInput) {
        return cachedOutput;
    } else {
        cachedInput = f;
        f = function(f);
        cachedOutput = f;
        return f;
    }
}