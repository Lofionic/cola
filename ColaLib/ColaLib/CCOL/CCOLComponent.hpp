//
//  CCOLComponent.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponent_hpp
#define CCOLComponent_hpp

#include <vector>
#include "CCOLComponentIO.hpp"
#include "CCOLComponentParameter.hpp"

using namespace std;

class CCOLComponentParameter;
class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLAudioContext;
class CCOLComponent {
    
public:
    CCOLComponent(CCOLAudioContext* contextIn);
    
    void            disconnectAll();
    virtual void    parameterDidChange(CCOLComponentParameter* parameter) { };
   
    bool            hasRendered();
    void            engineDidRender(unsigned int numFrames);

    virtual void    initializeIO() { }
    virtual void    renderOutputs(unsigned int numFrames);
    
    unsigned long int           getNumberOfOutputs() { return outputs.size(); }
    CCOLComponentOutput*        getOutputForIndex(long unsigned int index) {
        if (index < outputs.size()) {
        return outputs.at(index);
        } else {
            return NULL;
        }
    };
    CCOLComponentOutput*        getOutputNamed(char* name);
    
    unsigned long int           getNumberOfInputs() { return inputs.size(); }
    virtual CCOLComponentInput* getInputForIndex(short unsigned int index) {
        if (index < inputs.size()) {
            return inputs.at(index);
        } else {
            return NULL;
        }};
    CCOLComponentInput*         getInputNamed(char* name);
    
    unsigned long int           getNumberOfParameters() { return parameters.size(); }
    CCOLComponentParameter*     getParameterForIndex(short unsigned int index) {
        if (index < parameters.size()) {
            return parameters.at(index);
        } else {
            return NULL;
        }
    };
    CCOLComponentParameter*     getParameterNamed(char* name);
    CCOLAudioContext*           getContext() {
        return context;
    }
    
    char* getIdentifier() {
        return componentIdentifier;
    }

    virtual void dealloc();
    
    virtual const char*               getComponentType() { return "undetermined"; } // Used for model export.
    CFDictionaryRef                   getDictionary();
    
    void setIdentifier(char* inIdentifier);
    static vector<std::string> usedIDs;
    
    
protected:
    void setInputs(vector<CCOLComponentInput*> inputsIn) {
        inputs = inputsIn;
    }
    
    void setOutputs(vector<CCOLComponentOutput*> outputsIn) {
        outputs = outputsIn;
    }
    
    void setParameters(vector<CCOLComponentParameter*> parametersIn) {
        parameters = parametersIn;
    }

private:
    CCOLAudioContext*   context;
    char*         componentType;
    char*         componentIdentifier;
    bool                rendered;
    
    vector<CCOLComponentInput*>          inputs;
    vector<CCOLComponentOutput*>         outputs;
    vector<CCOLComponentParameter*>      parameters;
};

#endif /* CCOLComponent_hpp */
