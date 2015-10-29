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
#include "CCOLDefines.h"

enum kIOType {
    kIOTypeAudio,
    kIOTypeControl,
    kIOType1VOct,
    kcIOTypeGate,
    kIOTypeDynamic
};

class CCOLComponentInput;
class CCOLComponentOutput;
class CCOLComponent;

class CCOLComponentIO {

    
private:
    char*               name;
    
protected:
    CCOLComponent*      component;
    kIOType             ioType;
    CCOLComponentIO*    connectedTo;

public:
    virtual void        init(CCOLComponent *component, kIOType ioType, char* name);
    virtual void        engineDidRender();
    virtual bool        disconnect();
    
    bool                isConnected();
    virtual bool        isDynamic();
    
    virtual kIOType     getIOType();
    CCOLComponent*      getComponent();

    void                setConnected(CCOLComponentIO* connectTo);
    CCOLComponentIO*    getConnected();
};



class CCOLComponentInput : public CCOLComponentIO {
    
public:
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
    void            init(CCOLComponent *component, kIOType ioType, char* name) override;
    SignalType*     getBuffer(unsigned int numFrames);
    SignalType*     prepareBufferOfSize(unsigned int numFrames);
    bool            connect(CCOLComponentInput* inputIn);
    bool            disconnect() override;
    void            engineDidRender() override;
    
private:
    SignalType*             buffer;
    unsigned int            bufferSize;
    CCOLComponentInput*     linkedInput = nullptr;

};

#endif /* CCOLComponentIO_hpp */
