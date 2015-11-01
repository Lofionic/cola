//
//  CCOLComponentIO.hpp
//  ColaLib
//
//  Created by Chris on 29/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLComponentIO_hpp
#define CCOLComponentIO_hpp

#include "CCOLDefines.h"

class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLComponent;

class CCOLComponentIO {

public:
    CCOLComponentIO(CCOLComponent *component, kIOType ioType, char* name);
    
    const char*         getName() { return name; }
    
    virtual void        engineDidRender();
    virtual bool        disconnect();
    
    bool                isConnected();
    virtual bool        isDynamic();
    
    virtual kIOType     getIOType();
    CCOLComponent*      getComponent();

    void                setConnected(CCOLComponentIO* connectTo);
    CCOLComponentIO*    getConnected();
    
protected:
    CCOLComponent*      component;
    kIOType             ioType;
    CCOLComponentIO*    connectedTo;
   
    
private:
    char*               name;
};



class CCOLComponentInput : public CCOLComponentIO {
    
public:
    CCOLComponentInput(CCOLComponent *component, kIOType ioType, char* name):CCOLComponentIO(component, ioType, name) { }
    
    SignalType*     getBuffer(unsigned int numFrames);
    bool            makeDynamicConnection(CCOLComponentOutput *outputIn);
    bool            isDynamic() override;
    kIOType         getIOType() override;
    void            engineDidRender() override;
    bool            disconnect() override;
    
private:
    SignalType*     getEmptyBuffer(unsigned int numFrames);
};

class CCOLComponentOutput : public CCOLComponentIO {

public:
    CCOLComponentOutput(CCOLComponent *component, kIOType ioType, char* name):CCOLComponentIO(component, ioType, name) {
        linkedInput = nullptr;
        buffer = nullptr;
        bufferSize = 0;
    }

    SignalType*     getBuffer(unsigned int numFrames);
    SignalType*     prepareBufferOfSize(unsigned int numFrames);
    bool            connect(CCOLComponentInput* inputIn);
    kIOType         getIOType() override;
    void            engineDidRender() override;
    
private:
    SignalType*             buffer;
    unsigned int            bufferSize;
    CCOLComponentInput*     linkedInput = nullptr;
    
    bool                    disconnect() override; // Should be called on inputs only
};

#endif /* CCOLComponentIO_hpp */
