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
    
public:
    CCOLComponentParameter(CCOLComponent *componentIn, char* nameIn) {
        component = componentIn;
        name = nameIn;
    }
    char*   getName() {
        return name;
    }

    virtual void engineDidRender() { };

protected:
    CCOLComponent   *component;
private:
    char*           name;

};

typedef double (*parameterFunction)(double valueIn);
class CCOLContinuousParameter : public CCOLComponentParameter {
    
public:
    CCOLContinuousParameter(CCOLComponent *componentIn, char* nameIn) : CCOLComponentParameter(componentIn, nameIn) {
        setParameterFunction([] (double valueIn) -> double {
            return valueIn;
        });
        
        preValue        = 0;
        postValue       = 0;
        pendingValue    = 0;
    }
    void    setNormalizedValue(double newValue);
    double  getNormalizedValue();
    double  getOutputAtDelta(float delta);
    void    setParameterFunction(parameterFunction functionIn) {
        function = functionIn;
    }
    void    engineDidRender() override;
    
private:
    double  normalizedValue;
    double  preValue;
    double  postValue;
    double  pendingValue;
    double  cacheIn;
    double  cacheOut;
    
    parameterFunction function;
};

class CCOLDiscreteParameter : public CCOLComponentParameter {
    
public:
    CCOLDiscreteParameter(CCOLComponent *component, char* name, CCOLDiscreteParameterIndex maxIndexIn):CCOLComponentParameter(component, name) {
        maxIndex = maxIndexIn;
    }
    
    CCOLDiscreteParameterIndex getMaxIndex() {
        return maxIndex;
    }
    
    CCOLDiscreteParameterIndex getSelectedIndex() {
        return selectedIndex;
    }
    
    void setSelectedIndex(CCOLDiscreteParameterIndex indexIn) {
        selectedIndex = indexIn;
        component->parameterDidChange(this);
    }
    
private:
    CCOLDiscreteParameterIndex  maxIndex;
    CCOLDiscreteParameterIndex  selectedIndex;
    
    
};

#endif /* CCOLParameter_hpp */
