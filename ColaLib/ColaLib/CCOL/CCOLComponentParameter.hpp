//
//  CCOLParameter.hpp
//  ColaLib
//
//  Created by Chris on 01/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLParameter_hpp
#define CCOLParameter_hpp

#include <stdio.h>
#include "CCOLComponent.hpp"

class CCOLComponentParameter {

typedef double (*parameterFunction)(double valueIn);
    
public:
    CCOLComponentParameter(CCOLComponent *componentIn, char* nameIn) {
        component = componentIn;
        name = nameIn;
        
        preValue = postValue = pendingValue = 0;
    }
    
    char*   getName() {
        return name;
    }

    void    engineDidRender();
    void    setNormalizedValue(double newValue);
    double  getNormalizedValue();
    void    setParameterFunction(parameterFunction functionIn) {
        function = functionIn;
    }
    double  getOutputAtDelta(float delta);
    
protected:
    CCOLComponent   *component;
    
private:
    char*               name;
    double              value;
    parameterFunction   function;
    
    double preValue, postValue, pendingValue;
    double cachedInput, cachedOutput;

};

#endif /* CCOLParameter_hpp */
