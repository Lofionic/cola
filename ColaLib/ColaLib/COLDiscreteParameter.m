//
//  COLDiscreteParameter.m
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLDiscreteParameter.h"
#import "COLComponent.h"

@interface COLDiscreteParameter ()

@property (nonatomic) NSInteger maxIndex;

@end

@implementation COLDiscreteParameter

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name max:(NSInteger)max {
    if (self = [super initWithComponent:component withName:name]) {
        self.maxIndex = max;
    }
    
    return self;
}

@synthesize selectedIndex = _selectedIndex;

-(NSInteger)selectedIndex {
    return _selectedIndex;
}

-(void)setSelectedIndex:(NSInteger)value {
    _selectedIndex = value;
    [self.component parameterDidChange:self];
}

@end