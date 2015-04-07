//
//  COLComponentMultiplesKB.m
//  ColaLib
//
//  Created by Chris on 07/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentMultiplesKB.h"

@interface COLComponentMultiplesKB ()

@property (nonatomic, strong) COLComponentInput *inputA;
@property (nonatomic, strong) NSArray *outAs;

@property (nonatomic, strong) COLComponentInput *inputB;
@property (nonatomic, strong) NSArray *outBs;

@end

@implementation COLComponentMultiplesKB

-(void)initializeIO {
    
    self.inputA = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"In A"];
    self.inputB = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeGate withName:@"In B"];
    
    NSMutableArray *outputs = [[NSMutableArray alloc] initWithCapacity:8];
    for (NSInteger i = 0; i < 4; i++) {
        COLComponentOutput *newOutputA = [[COLComponentOutput alloc] initWithComponent:self
                                                                                ofType:kComponentIOType1VOct
                                                                              withName:[NSString stringWithFormat:@"Out A%ld", (long)i + 1]];
        [outputs addObject:newOutputA];
    }
    
    for (NSInteger i = 0; i < 4; i++) {
        COLComponentOutput *newOutputB = [[COLComponentOutput alloc] initWithComponent:self
                                                                                ofType:kComponentIOTypeGate
                                                                              withName:[NSString stringWithFormat:@"Out B%ld", (long)i + 1]];
        
        [outputs addObject:newOutputB];
    }
    
    [self setOutputs:[NSArray arrayWithArray:outputs]];
    [self setInputs:@[self.inputA, self.inputB]];
}

@end
