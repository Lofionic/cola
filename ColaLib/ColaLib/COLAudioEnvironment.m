//
//  COLAudioEnvironment.m
//  ColaLib
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "COLAudioEnvironment.h"
#import "COLAudioEngine.h"
#import "COLComponent.h"
#import "SinWaveComponent.h"
#import "LFOComponent.h"

@interface COLAudioEnvironment()

@property (nonatomic, strong) COLAudioEngine* audioEngine;

@end

@implementation COLAudioEnvironment

+ (instancetype) sharedEnvironment {
    static COLAudioEnvironment *sharedEnvironment = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnvironment = [[self alloc] init];
    });
    return sharedEnvironment;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        if ([appDelegate conformsToProtocol:@protocol(COLAudioEnvironmentInfoDelegate) ]) {
            self.infoDelegate = appDelegate;
        }
        
        self.audioEngine = [[COLAudioEngine alloc] init];
        [self.audioEngine setDelegate:self];
        
        self.components = [[NSMutableArray alloc] initWithCapacity:10];
        
        [self prepareTest];
    }
    return self;
}

-(void)start {
    [self.audioEngine initializeAUGraph];
}


-(void)connectComponent:(COLComponent*)component1 outputIndex:(NSInteger)outputIndex toComponet:(COLComponent*)component2 inputIndex:(NSInteger)inputIndex {
    
    COLComponentOutput *theOutput = [component1 outputForIndex:outputIndex];
    COLComponentInput *theInput = [component2 inputForIndex:inputIndex];
    
    [self connectOutput:theOutput toInput:theInput];
}

-(void)connectOutput:(COLComponentOutput*)output toInput:(COLComponentInput*)input {
    
    [output.connectedTo setConnectedTo:nil];
    [input.connectedTo setConnectedTo:nil];
    
    [output setConnectedTo:input];
    [input setConnectedTo:output];
    
    NSLog(@"Connected : %@ to %@", output.description, input.description);
}



#pragma mark AudioEngine delegates

-(NSDictionary *)interAppInfoDictionaryForAudioEngine:(COLAudioEngine *)audioEngine {
    if ([self.infoDelegate respondsToSelector:@selector(interAppInfoDictionary)]) {
        return [self.infoDelegate interAppInfoDictionary];
    }
    else {
        return nil;
    }
}

#pragma mark Testing

-(void)prepareTest {
    NSLog(@"Setting up test environment");
    
    // Test environment
    {
        SinWaveComponent *sinWaveComponent = [[SinWaveComponent alloc] initWithEnvironment:self];
        [self.components addObject:sinWaveComponent];
        
        COLComponentOutput *out = [sinWaveComponent outputForIndex:0];
        COLComponentInput *in = [self.audioEngine masterInputL];
        
        [self connectOutput:out toInput:in];
        
        LFOComponent *lfoComponent = [[LFOComponent alloc] initWithEnvironment:self];
        [self.components addObject:lfoComponent];
        
        COLComponentOutput *lfoOut = [lfoComponent outputForIndex:0];
        COLComponentInput *oscFreqIn = [sinWaveComponent inputForIndex:0];
        //[self connectOutput:lfoOut toInput:oscFreqIn];

        LFOComponent *anotherLFOComponent = [[LFOComponent alloc] initWithEnvironment:self];
        [anotherLFOComponent setFrequency:2];
        [self.components addObject:anotherLFOComponent];
        
        COLComponentOutput *anotherLFOout = [anotherLFOComponent outputForIndex:0];
        COLComponentInput *oscAmpIn = [sinWaveComponent inputForIndex:1];
        [self connectOutput:anotherLFOout toInput:oscAmpIn];
        
    }
    
    {
        SinWaveComponent *sinWaveComponent = [[SinWaveComponent alloc] initWithEnvironment:self];
        [self.components addObject:sinWaveComponent];
        
        [sinWaveComponent setFrequency:220];

        COLComponentOutput *out = [sinWaveComponent outputForIndex:0];
        COLComponentInput *in = [self.audioEngine masterInputR];
        
        [self connectOutput:out toInput:in];
        
        LFOComponent *lfoComponent = [[LFOComponent alloc] initWithEnvironment:self];
        [lfoComponent setFrequency:1];
        [self.components addObject:lfoComponent];
        
        [self connectComponent:lfoComponent outputIndex:0 toComponet:sinWaveComponent inputIndex:1];
        
    }
}

-(Float64)sampleRate {
    return self.audioEngine.sampleRate;
}

@end
