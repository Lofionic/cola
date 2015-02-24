//
//  WavePlayerComponent.h
//  ColaLib
//
//  Created by Chris on 15/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponent.h"


@interface COLComponentWavePlayer : COLComponent

-(BOOL)loadWAVFile:(NSURL*)fileURL;

@end
