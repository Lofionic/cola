//
//  COLIAAController.h
//  ColaLib
//
//  Created by Chris Rivers on 16/03/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCOLAudioEngine.hpp"

@interface CCOLIAAController : NSObject

@property (nonatomic, readonly) BOOL              isHostConnected;
@property (nonatomic, readonly) BOOL              isHostPlaying;
@property (nonatomic, readonly) BOOL              isHostRecording;

@property (nonatomic, readonly) float             hostPlayTime;
@property (nonatomic, readonly) float             hostBeat;
@property (nonatomic, readonly) float             hostTempo;

@property (nonatomic, readonly) UIImage           *hostImage;

-(void)initializeIAAwithComponentName:(CFStringRef)componentName manufactureCode:(OSType)componentManufacturer engine:(CCOLAudioEngine*)engine;
-(void)gotoHost;
-(void)togglePlay;
-(void)toggleRecord;
-(void)rewind;

@end
