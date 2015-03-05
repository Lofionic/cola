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
    AudioSignalType samplesL[880000];
    AudioSignalType samplesR[880000];
    UInt64 sampleCount;
    Float32 samplePosition;
    
    BOOL stereo;
}

@property (nonatomic, strong) COLComponentOutput *outputL;
@property (nonatomic, strong) COLComponentOutput *outputR;

@property (nonatomic, strong) COLComponentInput *freqMod;
@property (nonatomic, strong) COLComponentInput *ampIn;

@property (nonatomic, strong) COLComponentParameter *speed;

@end

@implementation COLComponentWavePlayer

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {
        samplePosition = 0;
        sampleCount = 0;

    }
    return self;
}

-(void)initializeIO {
    
    self.outputL = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutL"];
    self.outputR = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutR"];
    
    [self setOutputs:@[self.outputL, self.outputR]];
    
    self.freqMod = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FreqIn"];
    self.ampIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"AmpIn"];
    [self setInputs:@[self.freqMod, self.ampIn]];
    
    self.speed = [[COLComponentParameter alloc] initWithComponent:self withName:@"Speed"];
    [self.speed setFunction:^float (float normalizedValue) {
        normalizedValue = 1 + (powf(normalizedValue - 0.5, 3) * 8);
        if (normalizedValue < 0.5) {
            normalizedValue = 0.5;
        }
        return normalizedValue;
    }];
    
    [self setParameters:@[self.speed]];
}

-(BOOL)loadWAVFile:(NSURL*)fileUrl {
    CFURLRef url = (__bridge CFURLRef)fileUrl;
    ExtAudioFileRef fileRef;
    
    OSStatus err = ExtAudioFileOpenURL(url, &fileRef);
    if (err) {
        return NO;
    }
    
    // Get the file format description
    AudioStreamBasicDescription fileFormat;
    UInt32 dataSize = sizeof(fileFormat);
    err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat, &dataSize, &fileFormat);
    if (err) {
        return NO;
    }
    
    // Set the client format description
    AudioStreamBasicDescription clientFormat = fileFormat;
    clientFormat.mSampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved;
    clientFormat.mBitsPerChannel = sizeof(AudioSignalType) * 8;
    clientFormat.mBytesPerPacket = 4;
    clientFormat.mFramesPerPacket = 1;
    clientFormat.mBytesPerFrame = 4;

    err = ExtAudioFileSetProperty(fileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    if (err) {
        return NO;
    }
    
    // Find the number of samples
    UInt64 numFrames = 0;
    dataSize = sizeof(numFrames);
    err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileLengthFrames, &dataSize, &numFrames);
    if (err) {
        return NO;
    }
    
    sampleCount = numFrames * (clientFormat.mSampleRate / fileFormat.mSampleRate);
    
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
        if (err) {
            return NO;
        }
        
        // PCM data is in bufferList;

        if (bufferList->mNumberBuffers == 1) {
            // read mono
            stereo = NO;
            AudioBuffer buffer = bufferList->mBuffers[0];
            AudioSignalType *data = buffer.mData;
            for (int i = 0; i < framesToRead; i++) {
                samplesL[nextSample] = (AudioSignalType)data[i];
                nextSample ++;
            }
        } else {
            // read stereo
            stereo = YES;
            AudioBuffer bufferLeft = bufferList->mBuffers[0];
            AudioBuffer bufferRight = bufferList->mBuffers[1];
            AudioSignalType *dataLeft = bufferLeft.mData;
            AudioSignalType *dataRight = bufferRight.mData;
            for (int i = 0; i < framesToRead; i++) {
                //printf("%.4f\n", data[i]);
                samplesL[nextSample] = (AudioSignalType)dataLeft[i];
                samplesR[nextSample] = (AudioSignalType)dataRight[i];
                nextSample ++;
            }
        }
        
        numFrames = framesToRead;
    }

    // Cleanup
    free(bufferList);
    ExtAudioFileDispose(fileRef);
    
    samplePosition = 0;
    
    return YES;
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    // Input buffers
    AudioSignalType *freqMod = [self.freqMod getBuffer:numFrames];
    AudioSignalType *ampIn = [self.ampIn getBuffer:numFrames];
    
    // Output buffers
    AudioSignalType *leftOut = [self.outputL prepareBufferOfSize:numFrames];
    AudioSignalType *rightOut = [self.outputR prepareBufferOfSize:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
        if (sampleCount > 0 && samplePosition < sampleCount) {
            UInt64 sampleIndex = (UInt64)floor(samplePosition);
            AudioSignalType sampleLeft = 0;
            AudioSignalType sampleRight = 0;
            
            if (sampleIndex != samplePosition && sampleIndex < sampleCount) {
                
                // Interpolate between two samples
                float dec = samplePosition - sampleIndex;
                AudioSignalType sampleA = samplesL[sampleIndex];
                AudioSignalType sampleB = samplesL[sampleIndex + 1];
                sampleLeft = sampleA + ((sampleB - sampleA) * dec);
                
                if (stereo) {
                    AudioSignalType sampleA = samplesR[sampleIndex];
                    AudioSignalType sampleB = samplesR[sampleIndex + 1];
                    sampleRight = sampleA + ((sampleB - sampleA) * dec);
                } else {
                    sampleRight = sampleLeft;
                }
                
            } else {
                sampleLeft = samplesL[sampleIndex];
                if (stereo) {
                    sampleRight = samplesR[sampleIndex];
                } else {
                    sampleRight = sampleLeft;
                }
            }
            
            float amp;
            if ([self.ampIn isConnected]) {
                amp = ampIn[i];
            } else {
                amp = 1.0;
            }
            
            leftOut[i] = sampleLeft * amp;
            rightOut[i] = sampleRight * amp;
            
            // Iterate sample position
            float delta = i / (float)numFrames;
            float playbackSpeed = [self.speed outputAtDelta:delta];

            if ([self.freqMod isConnected]) {
                playbackSpeed *= (freqMod[i] * 1.5 + 0.5);
            }
            
            samplePosition += playbackSpeed;
            if (samplePosition >= sampleCount) {
                samplePosition -= sampleCount;
            }
        } else {
                leftOut[i] = 0;
                rightOut[i] = 0;
        }
    }
}

@end
