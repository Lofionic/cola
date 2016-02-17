//
//  StateButton.m
//  ColaApp
//
//  Created by Chris Rivers on 11/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "StateButton.h"
#import <ColaLib/COLAudioEnvironment.h>

@interface StateButton ()

@property (nonatomic) NSInteger stateCount;

@end

@implementation StateButton

-(instancetype)initWithParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)controlDescription {
    if (self = [super initWithParameter:parameter Description:controlDescription]) {

        [self setFrame:CGRectMake(0, 0, 44, 44)];
        [self setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGestureRecognize];
        
        NSDictionary *userInfo = controlDescription.userInfo;
        self.stateCount = [[userInfo objectForKey:@"states"] integerValue];
        
        [self updateFromParameter];
    }
    return self;
}

-(void)onTap:(UIGestureRecognizer*)uigr {
    NSLog(@"Button Tapped");
    
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    if (self.parameter) {
        double currentValue = [cae getParameterValue:self.parameter];
        double delta = (1.0 / (self.stateCount - 1));
        currentValue += delta;
        if (currentValue > 1.0) {
            currentValue = 0;
        }
        
        [cae setParameter:self.parameter value:currentValue];
        [self updateFromParameter];
    }
}

-(void)updateFromParameter {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    if (self.parameter) {
        double value = [cae getParameterValue:self.parameter];
        int state = value * (self.stateCount - 1);
        
        if (state == 0) {
            self.backgroundColor = [UIColor blackColor];
        } else if (state == 1) {
            self.backgroundColor = [UIColor redColor];
        } else if (state == 2) {
            self.backgroundColor = [UIColor orangeColor];
        } else if (state == 3) {
            self.backgroundColor = [UIColor greenColor];
        }
    }
}

-(NSObject *)getDictionaryObject {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    double value = [cae getParameterValue:self.parameter];
    return [NSNumber numberWithDouble:value];
}

-(void)setFromDictionaryObject:(NSObject *)object {
    NSNumber *number = (NSNumber*)object;
    double value = [number doubleValue];
    
    [[COLAudioEnvironment sharedEnvironment] setParameter:self.parameter value:value];
    [self updateFromParameter];
}

@end
