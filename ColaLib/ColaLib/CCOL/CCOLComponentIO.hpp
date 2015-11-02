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

class CCOLComponentConnector {

public:
    CCOLComponentConnector(CCOLComponent *component, kIOType ioType, char* name);
    
    const char*         getName() { return name; }
    
    virtual void        engineDidRender();
    virtual bool        disconnect();
    
    bool                isConnected();
    virtual bool        isDynamic();
    
    virtual kIOType     getIOType();
    CCOLComponent*      getComponent();

    void                        setConnected(CCOLComponentConnector* connectTo);
    CCOLComponentConnector*    getConnected();
    
protected:
    CCOLComponent*              component;
    kIOType                     ioType;
    CCOLComponentConnector*    connectedTo;
   
    
private:
    char*               name;
};



class CCOLComponentInput : public CCOLComponentConnector {
    
public:
    CCOLComponentInput(CCOLComponent *component, kIOType ioType, char* name):CCOLComponentConnector(component, ioType, name) { }
    
    SignalType*     getBuffer(unsigned int numFrames);
    bool            makeDynamicConnection(CCOLComponentOutput *outputIn);
    bool            isDynamic() override;
    kIOType         getIOType() override;
    void            engineDidRender() override;
    bool            disconnect() override;
    
private:
    SignalType*     getEmptyBuffer(unsigned int numFrames);
};

class CCOLComponentOutput : public CCOLComponentConnector {

public:
    CCOLComponentOutput(CCOLComponent *component, kIOType ioType, char* name):CCOLComponentConnector(component, ioType, name) {
        linkedInput = nullptr;
        buffer = nullptr;
        bufferSize = 0;
    }

    SignalType*             getBuffer(unsigned int numFrames);
    SignalType*             prepareBufferOfSize(unsigned int numFrames);
    bool                    connect(CCOLComponentInput* inputIn);
    kIOType                 getIOType() override;
    void                    engineDidRender() override;
    CCOLComponentInput*     getLinkedInput() {
        return linkedInput;
    }
    
private:
    SignalType*             buffer;
    unsigned int            bufferSize;
    CCOLComponentInput*     linkedInput = nullptr;
    
    bool                    disconnect() override; // Should be called on inputs only
};

#endif /* CCOLComponentIO_hpp */
