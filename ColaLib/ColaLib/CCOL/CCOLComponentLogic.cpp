//
//  CCOLComponentLogic.cpp
//  ColaLib
//
//  Created by Ed Rutter on 20/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLComponentLogic.hpp"
#include "CCOLAudioEngine.hpp"

#include <math.h>

void CCOLComponentLogic::initializeIO() {
    
    carrier = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Carrier In");
    modulator = new CCOLComponentInput(this, kIOTypeAudio, (char*)"Modulator In");
    setInputs(vector<CCOLComponentInput*> { carrier, modulator });
    
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
    
    
    // Setup offset buffer
    bufferSize = (512 * 3); // work out how to calculate buffer size
    
    offsetBuffer = (SignalType*)malloc(bufferSize * sizeof(SignalType));
    memset(offsetBuffer, 0, bufferSize * sizeof(SignalType));
    
    for (int i = 0 ; i < bufferSize; i++) {
        offsetBuffer[i] = 0.0f;
    }

    bufferReadPos =  -512;
    bufferWritePos = 0;
}

//void CCOLComponentLogic::renderOutputs(unsigned int numFrames) {
//    CCOLComponent::renderOutputs(numFrames);
//    
//    SignalType *carrierBuffer = carrier->getBuffer(numFrames);
//    SignalType *modulatorBuffer = modulator->getBuffer(numFrames);
//    
//    
//    SignalType *outBufferWithOffset = outputModOffset->prepareBufferOfSize(numFrames);
//    
//    for (int i = 0 ; i < numFrames; i++) {
//        offsetBuffer[bufferWritePos] = carrierBuffer[i];
//        
//        bufferWritePos++;
//        if (bufferWritePos >= (numFrames * 3)) {
//            bufferWritePos -= (numFrames * 3);
//        }
//    }
//    
//    //    bufferReadPos = bufferWritePos - numFrames;
//    
//    if (bufferReadPos < 0) {
//        bufferReadPos += numFrames * 3;
//    }
//    
//    for (int i = 0; i < numFrames; i++) {
//        
//        if (bufferReadPos >= (numFrames * 3)) {
//            bufferReadPos -= (numFrames * 3);
//        }
//        
//        float delta = i/(float)numFrames;
//        
//        // Offset the input buffer read by a multiple of the modulator
//        
//        // Get multiplier for the offset (0 - numframes/2)
//        float offsetParamLog = modOffsetAmount->getOutputAtDelta(delta);
//        offsetParamLog = offsetParamLog * offsetParamLog * offsetParamLog; // Approximate log scale
//        
//        float offsetAmount = numFrames/2 * offsetParamLog;
//        int bufferOffset = int(modulatorBuffer[i] * offsetAmount);
//        
//        if (outputModOffset->isConnected()) {
//            outBufferWithOffset[i] = offsetBuffer[bufferReadPos + bufferOffset];
//        }
//        
//        bufferReadPos++;
//    }
//    
//}

void CCOLComponentLogic::renderOutputs(unsigned int numFrames) {
    CCOLComponent::renderOutputs(numFrames);
    
    SignalType *carrierBuffer = carrier->getBuffer(numFrames);
    SignalType *modulatorBuffer = modulator->getBuffer(numFrames);
    
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
        if (outputGreatThanMod->isConnected()) {
            if (fabsf(carrierBuffer[i]) > fabsf(modulatorBuffer[i])) {
                outputBufferGreaterThan[i] = carrierBuffer[i];
            } else {
                outputBufferGreaterThan[i] = 0;
            }
        }
        
        // If the modulator level is positive, output the carrier signal, else output 0.
        if (outputModIsPos->isConnected()) {
            if (modulatorBuffer[i] > 0) {
                outputBufferModIsPos[i] = carrierBuffer[i];
            } else {
                outputBufferModIsPos[i] = 0;
            }
        }
        
        // If carrier and modulator are both positive or both negative then output the carrier, else output 0.
        if (outputSamePolarity->isConnected()) {
            if ((carrierBuffer[i] > 0 && modulatorBuffer[i] > 0) || (carrierBuffer[i] < 0 && modulatorBuffer[i] < 0)) {
                outputBufferSamePolarity[i] = carrierBuffer[i];
            } else {
                outputBufferSamePolarity[i] = 0;
            }
        }
        
        // If carrier and modulator are both positive or both negative then output the carrier, else output the modulator
        if (outputModOffset->isConnected()) {
            if ((carrierBuffer[i] > 0 && modulatorBuffer[i] < 0)
                || (carrierBuffer[i] < 0 && modulatorBuffer[i] > 0)
                || modulatorBuffer[i] == 0 ) {
                outputBufferSamePolarity[i] = carrierBuffer[i];
            } else {
                outputBufferSamePolarity[i] = modulatorBuffer[i];
            }
        }
        
        // Rectified and scaled carrier
        if (outputRectified->isConnected()) {
            outputBufferRectified[i] = (fabsf(carrierBuffer[i]) * 2.0) - 1.0;
        }
        
        // Rectified and scaled carrier multiplied by absolute modulator
        if (outputRectifiedAbsoluteMod->isConnected()) {
            outputBufferRectifiedAbsMod[i] = ((fabsf(carrierBuffer[i]) * 2.0 ) - 1.0) * (fabsf(modulatorBuffer[i]));
        }
        
        // Rectified and scaled carrier multiplied by modulator
        if (outputRectifiedMod->isConnected()) {
            outputBufferRectifiedMod[i] = ((fabsf(carrierBuffer[i]) * 2.0 ) - 1.0) * modulatorBuffer[i];
        }
        
        // Offset the input buffer read by a multiple of the modulator
        
        // Get multiplier for the offset (0 - numframes/2)
        float offsetParamLog = modOffsetAmount->getOutputAtDelta(delta);
        offsetParamLog = offsetParamLog * offsetParamLog * offsetParamLog; // Approximate log scale
        float offsetAmount = numFrames/2 * offsetParamLog;
        int bufferOffset = int(modulatorBuffer[i] * offsetAmount);
        
        // Offset with no bounds
        // May produce weird behaviour if offset pushes the buffer read position outside of buffer range
        if (outputModOffset->isConnected()) {
            outputBufferOffset[i] = carrierBuffer[i+bufferOffset];
        }
        
        // Offset and constrained within buffer (will cause distortion at the beginning and end of the render cycle)
        if (outputModOffset2->isConnected()) {
            if (bufferOffset+i < numFrames && bufferOffset+i >= 0) {
                outputBufferOffset2[i] = carrierBuffer[bufferOffset+i];
            } else if (bufferOffset+i >= numFrames) {
                outputBufferOffset2[i] = carrierBuffer[numFrames-1];
            } else if (bufferOffset+i < 0) {
                outputBufferOffset2[i] = carrierBuffer[0];
            }
        }
        
        // Offset and constrained within buffer but interpolating between values (will cause distortion at the beginning and end of the render cycle)
        
//        if (outputModOffset2->isConnected()) {
//            float bufferOffsetFloat = (inputBuffer2[i] * offsetAmount);
//            
//            if (bufferOffsetFloat+i < numFrames && bufferOffsetFloat+i >= 0) {
//                outputBufferOffset2[i]= inputBuffer1[i] + ((inputBuffer1[i+1] - inputBuffer1[i]) * (bufferOffsetFloat - (int)bufferOffsetFloat));
//            } else if (bufferOffsetFloat+i >= numFrames) {
//                outputBufferOffset2[i] = inputBuffer1[numFrames-1];
//            } else if (bufferOffsetFloat+i < 0) {
//                outputBufferOffset2[i] = inputBuffer1[0];
//            }
//        }
        
        // POSITIVE OFFSET CONSTRAINED: Offset by 0 to 1 * numframes constrained within buffer
        if (outputModOffset3->isConnected()) {
            int offsetPosCon = int((modulatorBuffer[i]+1) * 0.5  * offsetAmount);
            
            if (offsetPosCon+i < numFrames && offsetPosCon+i >= 0) {
                outputBufferOffset3[i] = carrierBuffer[offsetPosCon+i];
            } else if (offsetPosCon+i >= numFrames) {
                outputBufferOffset3[i] = carrierBuffer[numFrames-1];
            } else if (offsetPosCon+i < 0) {
                outputBufferOffset3[i] = carrierBuffer[0];
            }
        }
    }
}

