//
//  WavePlayerComponent.m
//  ColaLib
//
//  Created by Chris on 15/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLDefines.h"
#import "COLComponentWavePlayer.h"
#import "COLAudioEnvironment.h"
#import <AudioToolbox/AudioToolbox.h>

@interface COLComponentWavePlayer() {
    ExtAudioFileRef ref;
    AudioSignalType samples[880000];
    UInt64 sampleCount;
    Float32 samplePosition;
    
    AudioSignalType meterHoldSigma;
    UInt64 meterHoldPosition;
    AudioSignalType meterHold[50];
    
    AudioSignalType meterPeak;
    UInt64 meterAge;

}

@property (nonatomic, strong) COLComponentOutput *outputL;
@property (nonatomic, strong) COLComponentOutput *outputR;

@property (nonatomic, strong) COLComponentOutput *meterOut;

@property (nonatomic, strong) COLComponentInput *freqMod;

@end

@implementation COLComponentWavePlayer

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        samplePosition = 0;
        sampleCount = 0;

    }
    return self;
}

-(void)loadWAVFile:(NSURL*)fileUrl {
    CFURLRef url = (__bridge CFURLRef)fileUrl;
    ExtAudioFileRef fileRef;
    
    OSStatus err = ExtAudioFileOpenURL(url, &fileRef);
    
    // Get the file format description
    AudioStreamBasicDescription fileFormat;
    UInt32 dataSize = sizeof(fileFormat);
    err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat, &dataSize, &fileFormat);
    
    // Set the client format description
    AudioStreamBasicDescription clientFormat = fileFormat;
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved;
    clientFormat.mBitsPerChannel = sizeof(AudioSignalType) * 8;
    clientFormat.mBytesPerPacket = 4;
    clientFormat.mFramesPerPacket = 1;
    clientFormat.mBytesPerFrame = 4;

    err = ExtAudioFileSetProperty(fileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    
    // Find the number of samples
    UInt64 numFrames = 0;
    dataSize = sizeof(numFrames);
    err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileLengthFrames, &dataSize, &numFrames);
    
    sampleCount = numFrames;
    
    // Prepare an audio buffer list to hold the data when we read it from the file
    UInt32 maxReadFrames = 4096;  // number of samples to read at a time
    AudioBufferList *bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (fileFormat.mChannelsPerFrame - 1));
    bufferList->mNumberBuffers = fileFormat.mChannelsPerFrame;
    
    for (int j = 0; j < bufferList->mNumberBuffers; ++j) {
        bufferList->mBuffers[j].mDataByteSize = maxReadFrames * sizeof(AudioSignalType);
        bufferList->mBuffers[j].mData = malloc(bufferList->mBuffers[j].mDataByteSize);
        bzero(bufferList->mBuffers[j].mData, bufferList->mBuffers[j].mDataByteSize);
        bufferList->mBuffers[j].mNumberChannels = 1;
    }

    // Read the frames and write to C array
    UInt32 nextSample = 0;
    
    while (numFrames > 0) {
        UInt32 framesToRead = (maxReadFrames > numFrames) ? (UInt32)numFrames : maxReadFrames;
        err = ExtAudioFileRead(fileRef, &framesToRead, bufferList);
        // PCM data is in bufferList;
        AudioBuffer buf = bufferList->mBuffers[0];
        Float32 *data = buf.mData;
        for (int i = 0; i < framesToRead; i++) {
            //printf("%.4f\n", data[i]);
            samples[nextSample] = (AudioSignalType)data[i];
            nextSample ++;
        }
        
        numFrames = framesToRead;
    }

    // Cleanup
    free(bufferList);
    ExtAudioFileDispose(fileRef);
    
    samplePosition = 0;
}

-(void)initializeIO {
    
    self.outputL = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutL"];
    self.outputR = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutR"];

    self.meterOut = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"Meter Out"];
    
    [self setOutputs:@[self.outputL, self.outputR, self.meterOut]];
    
    self.freqMod = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    [self setInputs:@[self.freqMod]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    // Input buffers
    AudioSignalType *freqMod = [self.freqMod getBuffer:numFrames];
    
    // Output buffers
    AudioSignalType *leftOut = [self.outputL prepareBufferOfSize:numFrames];
    AudioSignalType *rightOut = [self.outputR prepareBufferOfSize:numFrames];
    AudioSignalType *meterOut = [self.meterOut prepareBufferOfSize:numFrames];
    
    int meterHoldSize = sizeof(meterHold) / sizeof(meterHold[0]);
    
    AudioSignalType meterHoldHold = 0;
    
    for (int i = 0; i < numFrames; i++) {
        if (sampleCount > 0) {
            UInt64 sampleIndex = (UInt64)floor(samplePosition);
            AudioSignalType sample = 0;
            if (sampleIndex != samplePosition && sampleIndex < sampleCount) {
                // Interpolate between two samples
                float dec = samplePosition - sampleIndex;
                AudioSignalType sampleA = samples[sampleIndex];
                AudioSignalType sampleB = samples[sampleIndex + 1];
                sample = sampleA + ((sampleB - sampleA) * dec);
            } else {
                sample = samples[sampleIndex];
            }
            leftOut[i] = sample;
            rightOut[i] = sample;
            
            AudioSignalType freq = 1;
            if ([self.freqMod isConnected]) {
                freq = (freqMod[i] * 2.0);
            }
            
            samplePosition = samplePosition + freq;
            if (samplePosition > sampleCount) {
                samplePosition = 0;
            }
            
            if (i % 50 == 0) {
                meterHoldSigma -= meterHold[meterHoldPosition];
                meterHold[meterHoldPosition] = fabsf(sample);
                meterHoldSigma += fabsf(sample);

                meterHoldPosition ++;
                if (meterHoldPosition >= meterHoldSize) {
                    meterHoldPosition = 0;
                }
                
                meterHoldHold = meterHoldSigma / meterHoldSize;
            }
            
            meterOut[i] = meterHoldHold;
            

        } else {
                leftOut[i] = 0;
                rightOut[i] = 0;
        }
    }
}

@end
