//
//  BuildViewController.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "ModuleDescription.h"
#import "BuildViewController.h"
#import "KeyboardView.h"
#import "BuildView.h"
#import "ModuleView.h"

static BuildView *buildView = nil;

@interface BuildViewController()

@property (nonatomic, strong) BuildView             *buildView;

@property (nonatomic, strong) ComponentShelfView    *componentShelf;
@property (nonatomic, strong) KeyboardView          *keyboardView;

@property (nonatomic, strong) UIView                *dragView;
@property (nonatomic, strong) ModuleView            *dragModule;

@property (nonatomic, strong) UIBarButtonItem       *buildModeButton;
@property (nonatomic, strong) UIImage               *buildIcon;
@property (nonatomic ,strong) UIImage               *keyboardIcon;

@property (nonatomic) BOOL buildMode;

@property (nonatomic, strong) NSLayoutConstraint    *shiftBuildViewConstraint; // Constraint to shift the build view down when the build view appears

@end

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    self.buildView = [[BuildView alloc] init];
    [self.buildView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buildView setContentInset:UIEdgeInsetsMake(0, 0, kKeyboardHeight, 0)];
    [self.buildView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, kKeyboardHeight, 0)];
    [self.buildView setClipsToBounds:NO];
    [self.buildView setBuildViewController:self];
    [self.view addSubview:self.buildView];
    
    buildView = self.buildView;
    
    self.componentShelf = [[ComponentShelfView alloc] init];
    [self.componentShelf setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentShelf setDelegate:self];
    [self.view addSubview:self.componentShelf];
    
    self.keyboardView = [[KeyboardView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardView setKbComponent:[[COLAudioEnvironment sharedEnvironment] keyboardComponent]];
    [self.view addSubview:self.keyboardView];
    
    NSDictionary *viewsDictionary = @{
                                      @"buildView"      :   self.buildView,
                                      @"componentShelf" :   self.componentShelf,
                                      @"keyboardView"   :   self.keyboardView,
                                      @"topGuide"       :   self.topLayoutGuide
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
                                        @"componentShelfHeight" : [NSNumber numberWithFloat:kComponentShelfHeight]
                                        };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][componentShelf(componentShelfHeight)]"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[keyboardView(componentShelfHeight)]|"
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
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0@750-[buildView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    self.shiftBuildViewConstraint = [NSLayoutConstraint constraintWithItem:self.buildView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.topLayoutGuide
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:kComponentShelfHeight];
    
    [self.shiftBuildViewConstraint setPriority:UILayoutPriorityRequired];
    [self.view addConstraint:self.shiftBuildViewConstraint];
    
    UIImage *wrenchIcon = [UIImage imageNamed:TOOLBAR_BUILD_ICON];
    self.buildModeButton = [[UIBarButtonItem alloc] initWithImage:wrenchIcon style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self.navigationItem setLeftBarButtonItem:self.buildModeButton];
    [self setBuildMode:NO animated:NO];
}

#pragma mark Toolbar

-(void)editTapped {
    if (!self.buildMode) {
        [self setBuildMode:YES animated:YES];
        
    } else {
        [self setBuildMode:NO animated:YES];
        
    }
}

-(void)setBuildMode:(BOOL)buildMode animated:(BOOL)animated {
    self.buildMode = buildMode;
    if (buildMode) {
        // show shelf
        if (animated) {
            [self.shiftBuildViewConstraint setActive:YES];
            [UIView animateWithDuration:0.2 animations:^ {
                [self.componentShelf setTransform:CGAffineTransformIdentity];
                [self.view layoutIfNeeded];

            }];

        } else {
            [self.componentShelf setTransform:CGAffineTransformIdentity];
            [self.shiftBuildViewConstraint setActive:YES];
        }
        [self.buildModeButton setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON_SELECTED]];
    } else {
        // Hide shelf, show keyboard
        if (animated) {
            [self.shiftBuildViewConstraint setActive:NO];
            [UIView animateWithDuration:0.2 animations:^ {
                [self.componentShelf setTransform:CGAffineTransformMakeTranslation(0, -kComponentShelfHeight - 40.0)];
                [self.view layoutIfNeeded];
            }];
        } else {
            [self.componentShelf setTransform:CGAffineTransformMakeTranslation(0, -kComponentShelfHeight - 40.0)];
            [self.shiftBuildViewConstraint setActive:NO];
        }
        [self.buildModeButton setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON]];
    }
}

#pragma mark ComponentShelf

-(void)componentShelf:(ComponentShelfView *)componentTray didBeginDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    
    CGPoint dragPoint = [gesture locationInView:self.view];

    self.dragView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, module.thumbnail.size.width, module.thumbnail.size.height)];
    [self.dragView setCenter:dragPoint];
    [self.dragView setUserInteractionEnabled:NO];
    [self.dragView.layer setOpacity:0.5];
    [self.dragView.layer setContents:(id)[module.thumbnail CGImage]];
    
    [self.view addSubview:self.dragView];
}

-(void)componentShelf:(ComponentShelfView *)componentTray didContinueDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    
    CGPoint dragPoint = [gesture locationInView:self.view];
    [self.dragView setCenter:dragPoint];
    
    BOOL occupied;
    NSSet *hoverSet = [self.buildView cellPathsForModuleOfWidth:module.width center:[gesture locationInView:self.buildView] occupied:&occupied];
    
    if (hoverSet && !occupied && [self.view hitTest:dragPoint withEvent:nil] == self.buildView) {
        [self.buildView setHighlightedCellSet:hoverSet];
    } else {
        [self.buildView setHighlightedCellSet:nil];
    }
}

-(void)componentShelf:(ComponentShelfView *)componentTray didEndDraggingModule:(ModuleDescription*)module withGesture:(UIGestureRecognizer *)gesture {
    [self.dragView removeFromSuperview];
    [self.buildView setHighlightedCellSet:nil];
    
    if (gesture.state != UIGestureRecognizerStateCancelled ){
        CGPoint pointInWindow = [gesture locationInView:self.view];
        // Don't drop if drag is likely to have gone off-screen
        if (pointInWindow.x > 8 &&
            pointInWindow.x < self.view.frame.size.width - 8 &&
            pointInWindow.y > 8 &&
            pointInWindow.y < self.view.frame.size.height - 8) {
            if ([self.view hitTest:pointInWindow withEvent:nil] == self.buildView) {
                // Add a component
                [self.buildView addViewForModule:module atPoint:[gesture locationInView:self.buildView]];
            }
        }
    }
}

#pragma Convenience Methods

+(BuildView*)buildView {
    return buildView;
}

@end
