//
//  BuildViewController.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "ComponentDescription.h"
#import "BuildViewController.h"
#import "KeyboardView.h"

static BuildView *buildView = nil;

@interface BuildViewController()

@property (nonatomic, strong) BuildView             *buildView;

@property (nonatomic, strong) ComponentShelfView    *componentTray;
@property (nonatomic, strong) KeyboardView          *keyboardView;

@property (nonatomic, strong) UIView                *dragView;

@end

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];

    self.buildView = [[BuildView alloc] init];
    [self.buildView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buildView setContentInset:UIEdgeInsetsMake(kToolbarHeight, 0, kComponentShelfHeight, 0)];
    [self.buildView setScrollIndicatorInsets:UIEdgeInsetsMake(kToolbarHeight, 0, kComponentShelfHeight, 0)];
    [self.view addSubview:self.buildView];
    
    buildView = self.buildView;
    
    self.componentTray = [[ComponentShelfView alloc] init];
    [self.componentTray setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentTray setDelegate:self];
    [self.view addSubview:self.componentTray];
    
    self.keyboardView = [[KeyboardView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardView setKbComponent:[[COLAudioEnvironment sharedEnvironment] keyboardComponent]];
    [self.view addSubview:self.keyboardView];
    
    NSDictionary *viewsDictionary = @{
                                      @"buildView"      :   self.buildView,
                                      @"componentShelf" :   self.componentTray,
                                      @"keyboardView"   :   self.keyboardView
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    NSDictionary *metricsDictionary = @{
                                        @"buildViewWidth"       : [NSNumber numberWithFloat:kBuildViewWidth],
                                        @"componentShelfHeight" : [NSNumber numberWithFloat:kComponentShelfHeight],
                                        @"toolbarHeight"        : [NSNumber numberWithFloat:kToolbarHeight]
                                        };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[keyboardView(componentShelfHeight)][componentShelf(componentShelfHeight)]|"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kBuildViewWidth]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buildView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

-(void)componentTray:(ComponentShelfView *)componentTray didBeginDraggingComponent:(ComponentDescription*)component withGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint dragPoint = [panGesture locationInView:self.view];
    
    self.dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.dragView setBackgroundColor:[UIColor whiteColor]];
    [self.dragView setCenter:dragPoint];
    [self.dragView setUserInteractionEnabled:NO];
    
    [self.view addSubview:self.dragView];
}

-(void)componentTray:(ComponentShelfView *)componentTray didContinueDraggingComponent:(ComponentDescription*)component withGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint dragPoint = [panGesture locationInView:self.view];
    [self.dragView setCenter:dragPoint];
    
    NSSet *hoverSet = [self.buildView cellPathsForComponentOfWidth:component.width center:[panGesture locationInView:self.buildView]];
    
    if (hoverSet && [self.view hitTest:dragPoint withEvent:nil] == self.buildView) {
        [self.buildView setHighlightedCellSet:hoverSet];
    } else {
        [self.buildView setHighlightedCellSet:nil];
    }
}

-(void)componentTray:(ComponentShelfView *)componentTray didEndDraggingComponent:(ComponentDescription*)component withGesture:(UIPanGestureRecognizer *)panGesture {
    [self.dragView removeFromSuperview];
    [self.buildView setHighlightedCellSet:nil];
    
    if (panGesture.state != UIGestureRecognizerStateCancelled ){
        CGPoint pointInWindow = [panGesture locationInView:self.view];
        // Don't drop if drag is likely to have gone off-screen
        if (pointInWindow.x > 8 &&
            pointInWindow.x < self.view.frame.size.width - 8 &&
            pointInWindow.y > 8 &&
            pointInWindow.y < self.view.frame.size.height - 8) {
            if ([self.view hitTest:pointInWindow withEvent:nil] == self.buildView) {
                // Add a component
                [self.buildView addViewForComponent:component atPoint:[panGesture locationInView:self.buildView]];
            }
        }
    }
}

+(BuildView*)buildView {
    return buildView;
}

@end
