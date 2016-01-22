//
//  CCOLComponentLogic.cpp
//  ColaLib
//
//  Created by Ed Rutter on 20/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentLogic.hpp"
#include <math.h>

void CCOLComponentLogic::initializeIO() {
    
    input1 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Carrier In");
    input2 = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Modulator In");
    setInputs(vector<CCOLComponentInput*> { input1, input2 });
    
    outputGreatThanMod  = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"GreatThanMod Out");
    outputModIsPos      = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"IfModIsPos Out");
    outputSamePolarity  = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"SamePolarity Out");
    
    outputRectified             = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"Rectified Out");
    outputRectifiedAbsoluteMod  = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"RectifiedAbsMod Out");
    outputRectifiedMod          = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"RectifiedMod Out");
    
    outputModOffset     = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModOffset Out");
    outputModOffset2    = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModOffset2 Out");
    outputModOffset3    = new CCOLComponentOutput(this, kIOTypeAudio, (char*)"ModOffset3 Out");
    
    setOutputs(vector<CCOLComponentOutput *> {
        outputGreatThanMod,
        outputModIsPos,
        outputSamePolarity,
        outputRectified,
        outputRectifiedAbsoluteMod,
        outputRectifiedMod,
        outputModOffset,
        outputModOffset2,
        outputModOffset3 });
    
    
    modOffsetAmount    = new CCOLComponentParameter(this, (char*)"modOffsetAmount");
    setParameters(vector<CCOLComponentParameter*> { modOffsetAmount });
    modOffsetAmount->setNormalizedValue(0.5);
}

void CCOLComponentLogic::renderOutputs(unsigned int numFrames) {
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *inputBuffer1 = input1->getBuffer(numFrames);
    SignalType *inputBuffer2 = input2->getBuffer(numFrames);
    
    SignalType *outputBufferGreaterThan = outputGreatThanMod->prepareBufferOfSize(numFrames);
    SignalType *outputBufferModIsPos = outputModIsPos->prepareBufferOfSize(numFrames);
    SignalType *outputBufferSamePolarity = outputSamePolarity->prepareBufferOfSize(numFrames);
    
    SignalType *outputBufferRectified = outputRectified->prepareBufferOfSize(numFrames);
    SignalType *outputBufferRectifiedAbsMod = outputRectifiedAbsoluteMod->prepareBufferOfSize(numFrames);
    SignalType *outputBufferRectifiedMod = outputRectifiedMod->prepareBufferOfSize(numFrames);
    
    SignalType *outputBufferOffset = outputModOffset->prepareBufferOfSize(numFrames);
    SignalType *outputBufferOffset2 = outputModOffset2->prepareBufferOfSize(numFrames);
    SignalType *outputBufferOffset3 = outputModOffset3->prepareBufferOfSize(numFrames);
    
    
    
    for (int i = 0; i < numFrames; i++) {
        
        float delta = i/(float)numFrames;
        
        // If the absolute carrier level is greater than the absolute modulator level, output the carrier signal else output 0.
        if (fabsf(inputBuffer1[i]) > fabsf(inputBuffer2[i])) {
            outputBufferGreaterThan[i] = inputBuffer1[i];
        } else {
            outputBufferGreaterThan[i] = 0;
        }
        
        // If the modulator level is positive, output the carrier signal, else output 0.
        if (inputBuffer2[i] > 0) {
            outputBufferModIsPos[i] = inputBuffer1[i];
        } else {
            outputBufferModIsPos[i] = 0;
        }
        
        // If carrier and modulator are both positive or both negative then output the carrier, else output 0.
        if ((inputBuffer1[i] > 0 && inputBuffer2[i] > 0) || (inputBuffer1[i] < 0 && inputBuffer2[i] < 0)) {
            outputBufferSamePolarity[i] = inputBuffer1[i];
        } else {
            outputBufferSamePolarity[i] = 0;
        }
        
        // If carrier and modulator are both positive or both negative then output the carrier, else output the modulator
        if ((inputBuffer1[i] > 0 && inputBuffer2[i] < 0)
            || (inputBuffer1[i] < 0 && inputBuffer2[i] > 0)
            || inputBuffer2[i] == 0 ) {
            outputBufferSamePolarity[i] = inputBuffer1[i];
        } else {
            outputBufferSamePolarity[i] = inputBuffer2[i];
        }
        
        // Rectified and scaled carrier
        outputBufferRectified[i] = (fabsf(inputBuffer1[i]) * 2.0) - 1.0;

        // Rectified and scaled carrier multiplied by absolute modulator
        outputBufferRectifiedAbsMod[i] = ((fabsf(inputBuffer1[i]) * 2.0 ) - 1.0) * (fabsf(inputBuffer2[i]));
        
        // Rectified and scaled carrier multiplied by modulator
        outputBufferRectifiedMod[i] = ((fabsf(inputBuffer1[i]) * 2.0 ) - 1.0) * inputBuffer2[i];
        

        // Offset the input buffer read by a multiple of the modulator
        // May produce weird behaviour if offset pushes the buffer read position outside of buffer range
        
        // Get multiplier for the offset (0 - numframes/2)
        float offsetParamLog = modOffsetAmount->getOutputAtDelta(delta);
        offsetParamLog = offsetParamLog * offsetParamLog * offsetParamLog; // Approximate log scale
        float offsetAmount = numFrames/2 * offsetParamLog;
        
        // Offset with no bounds
        int bufferOffset = int(inputBuffer2[i] * offsetAmount);
        outputBufferOffset[i] = inputBuffer1[i+bufferOffset];
        
        // Offset and constrained within buffer (will cause distortion at the beginning and end of the render cycle)
        if (bufferOffset+i < numFrames && bufferOffset+i >= 0) {
            outputBufferOffset2[i] = inputBuffer1[bufferOffset+i];
        } else if (bufferOffset+i >= numFrames) {
            outputBufferOffset2[i] = inputBuffer1[numFrames-1];
        } else if (bufferOffset+i < 0) {
            outputBufferOffset2[i] = inputBuffer1[0];
        }
        
        
        // POSITIVE OFFSET CONSTRAINED: Offset by 0 to 1 * numframes constrained within buffer
        int bufferOffset2 = int((inputBuffer2[i]+1) * 0.5  * offsetAmount);
        
        if (bufferOffset2+i < numFrames && bufferOffset2+i >= 0) {
            outputBufferOffset3[i] = inputBuffer1[bufferOffset2+i];
            outputBufferOffset3[i] = inputBuffer1[i];
        } else if (bufferOffset2+i >= numFrames) {
            outputBufferOffset3[i] = inputBuffer1[numFrames-1];
        } else if (bufferOffset2+i < 0) {
            outputBufferOffset3[i] = inputBuffer1[0];
        }
        
        
        
    }

}