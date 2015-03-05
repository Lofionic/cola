//
//  BuildViewController.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewController.h"

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.componentShelfController = [[ComponentShelfController alloc] init];
    [self addChildViewController:self.componentShelfController];
    
    [self.componentShelfController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:[self.componentShelfController view]];
    
    NSDictionary *viewsDictionary = @{
                                      @"componentShelf" : [self.componentShelfController view]
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[componentShelf(100)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

@end
