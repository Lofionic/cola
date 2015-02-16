//
//  WavePlayerComponent.m
//  ColaLib
//
//  Created by Chris on 15/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLDefines.h"
#import "WavePlayerComponent.h"
#import "COLAudioEnvironment.h"
#import <AudioToolbox/AudioToolbox.h>

@interface WavePlayerComponent() {
    ExtAudioFileRef ref;
    AudioSignalType samples[882000];
    UInt64 sampleCount;
    UInt64 samplePositionL;
    UInt64 samplePositionR;
}

@property (nonatomic, strong) COLComponentOutput *outputL;
@property (nonatomic, strong) COLComponentOutput *outputR;

@end

@implementation WavePlayerComponent

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
    
    samplePositionL = 0;
    samplePositionR = 0;
}

-(void)initializeIO {
    
    self.outputL = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutL"];
    self.outputR = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"OutR"];

    [self setOutputs:@[self.outputL, self.outputR]];
    
}

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
    if (output == self.outputL) {
        for (int i = 0; i < numFrames; i++) {
            outA[i] = samples[samplePositionL];
            //printf("%.5f\n", outA[i]);
            samplePositionL ++;
            if (samplePositionL > sampleCount) {
                samplePositionL -= sampleCount;
            }
        }
    } else {
        for (int i = 0; i < numFrames; i++) {
            outA[i] = samples[samplePositionR];
            //printf("%.5f\n", outA[i]);
            samplePositionR ++;
            if (samplePositionR > sampleCount) {
                samplePositionR -= sampleCount;
            }
        }
    }
}


@end
