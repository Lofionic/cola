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
    
    self.buildView = [[BuildView alloc] initWithColumns:3];
    [self.buildView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.buildView];
    
    self.componentTray = [[ComponentTrayView alloc] init];
    [self.componentTray setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentTray setDelegate:self];
    [self.view addSubview:self.componentTray];
    
    NSDictionary *viewsDictionary = @{
                                      @"buildView"      :   self.buildView,
                                      @"componentShelf" :   self.componentTray
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[componentShelf(100)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buildView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[buildView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

-(void)componentTray:(ComponentTrayView *)componentTray didBeginDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint dragPoint = [panGesture locationInView:self.view];
    
    self.dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.dragView setBackgroundColor:[UIColor whiteColor]];
    [self.dragView setCenter:dragPoint];
    [self.dragView setUserInteractionEnabled:NO];
    
    [self.view addSubview:self.dragView];
}

-(void)componentTray:(ComponentTrayView *)componentTray didContinueDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint dragPoint = [panGesture locationInView:self.view];
    [self.dragView setCenter:dragPoint];
    
    BuildViewCellPath *hoverCellPath = [self.buildView cellPathForPoint:[self.buildView convertPoint:dragPoint fromView:self.view]];
    
    if (hoverCellPath && [self.view hitTest:dragPoint withEvent:nil] == self.buildView) {
        [self.buildView setHighlightedCellSet:[NSSet setWithObject:hoverCellPath]];
    } else {
        [self.buildView setHighlightedCellSet:nil];
    }
}

-(void)componentTray:(ComponentTrayView *)componentTray didEndDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer *)panGesture {
    [self.dragView removeFromSuperview];
    [self.buildView setHighlightedCellSet:nil];
}

@end
