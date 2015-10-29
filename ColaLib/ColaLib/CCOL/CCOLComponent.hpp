//
//  CCOLComponent.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponent_hpp
#define CCOLComponent_hpp

#include <stdio.h>
#include <vector>
#include "CCOLComponentIO.hpp"
#include "CCOLAudioContext.hpp"

using namespace std;

class CCOLComponentParameter;
class CCOLComponent {
    
public:
    void            init(CCOLAudioContext* context);
    bool            hasRendered();
    virtual void    renderOutputs(unsigned int numFrames);
    void            engineDidRender();
    void            disconnectAll();
    void            parameterDidChange(CCOLComponentParameter* parameter);
    virtual void    assignUniqueName();
    
    unsigned long int           getNumberOfOutputs() { return outputs.size(); }
    CCOLComponentOutput*        getOutputForIndex(long unsigned int index) { return outputs.at(index); }
    CCOLComponentOutput*        getOutputNamed(char* name);
    
    unsigned long int           getNumberOfInputs() { return inputs.size(); }
    CCOLComponentInput*         getInputForIndex(short unsigned int index) { return inputs.at(index); };
    CCOLComponentInput*         getInputNamed(char* name);
    
    unsigned long int           getNumberOfParameters() { return 0; }
    CCOLComponentParameter*     getParameterForIndex(short unsigned int index);
    CCOLComponentParameter*     getParameterNamed(char* name);
    
protected:
    void setInputs(vector<CCOLComponentInput*> inputsIn) {
        inputs = inputsIn;
    }
    
    void setOutputs(vector<CCOLComponentOutput*> outputsIn) {
        outputs = outputsIn;
    }
    
    void setParameters(vector<CCOLComponentParameter*> parametersIn) {
        //parameters = parametersIn;
    }
    
    virtual const char* getDefaultName();
    
private:
    CCOLAudioContext*   context;
    char*               identifier;
    bool                rendered;
    virtual void        initializeIO() { }
    
    vector<CCOLComponentInput*>          inputs;
    vector<CCOLComponentOutput*>         outputs;
    //vector<CCOLComponentParameter>      parameters;
};

#endif /* CCOLComponent_hpp */