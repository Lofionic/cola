//
//  SequencerView.m
//  ColaApp
//
//  Created by Chris on 13/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerView.h"
#import <ColaLib/COLAudioEnvironment.h>

@interface SequencerView()

@property (nonatomic) CCOLComponentAddress component;

@end

@implementation SequencerView

-(instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor blueColor]];
        [self createSequencerComponent];
    }
    return self;
}

-(void)createSequencerComponent {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    self.component = [cae createComponentOfType:"CCOLComponentTypeSequencer"];
}

@end
