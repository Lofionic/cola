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
#import "WheelControl.h"
#import "BuildView.h"
#import "ModuleView.h"
#import "ModuleCatalog.h"
#import "FilesViewController.h"
#import "PresetController.h"
#import "UIView+Snapshot.h"
#import "UIImage+Resize.h"
#import "BuildViewScrollView.h"
#import "IAAView.h"

#import <ColaLib/CCOLTypes.h>
#import <ColaLib/COLAudioEnvironment.h>

static BuildView *buildView = nil;

@class ControlView;
@interface BuildViewController()

@property (nonatomic, weak) COLAudioEnvironment     *cae;

@property (nonatomic, strong) BuildViewScrollView   *buildViewScrollView;
@property (nonatomic, strong) BuildView             *buildView;

@property (nonatomic, strong) ComponentShelfView    *componentShelf;
@property (nonatomic, strong) UIImageView           *bottomPanel;

@property (nonatomic, strong) UIView                *keyboardContainerView;
@property (nonatomic, strong) KeyboardView          *keyboardView;
@property (nonatomic, strong) WheelControl          *pitchbendWheelControl;
@property (nonatomic, strong) WheelControl          *modWheelControl;

@property (nonatomic, strong) IAAView               *iaaView;

@property (nonatomic, strong) UIView                *dragView;
@property (nonatomic, strong) ModuleView            *dragModule;

@property (nonatomic, strong) UIBarButtonItem       *buildBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *keyboardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *sequencerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *playStopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *saveBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem       *filesBarButtonItem;

@property (nonatomic, strong) NSLayoutConstraint    *bottomPanelPositionConstraint;
@property (nonatomic, strong) NSLayoutConstraint    *iaaPositionConstraint;

@property (nonatomic) BOOL buildMode;
@property (nonatomic) BOOL bottomPanelHidden;

@property (nonatomic, strong) NSLayoutConstraint    *shiftBuildViewConstraint; // Constraint to shift the build view down when the build view appears

@property (nonatomic, strong) Preset *preset;

@end

@implementation BuildViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];

    self.cae = [COLAudioEnvironment sharedEnvironment];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wallpaper"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile]];
    [backgroundView setFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [self.view addSubview:backgroundView];
    
    self.buildViewScrollView = [[BuildViewScrollView alloc] init];
    [self.buildViewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.buildViewScrollView];
    
    self.buildView = [[BuildView alloc] initWithScrollView:self.buildViewScrollView];
    [self.buildView setBuildViewController:self];
    [self.buildViewScrollView addSubview:self.buildView];
    [self.buildViewScrollView setDelegate:self.buildView];
    buildView = self.buildView;
    
    self.componentShelf = [[ComponentShelfView alloc] init];
    [self.componentShelf setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.componentShelf setDelegate:self];
    [self.view addSubview:self.componentShelf];
    
    UIImage *keyboard_bg = [[UIImage imageNamed:@"keyboard_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(48, 24, 0, 24) resizingMode:UIImageResizingModeTile];
    self.bottomPanel = [[UIImageView alloc] initWithImage:keyboard_bg];
    [self.bottomPanel setBackgroundColor:[UIColor darkGrayColor]];
    [self.bottomPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomPanel setUserInteractionEnabled:YES];
    [self.view addSubview:self.bottomPanel];
    
    // Setup keyboard container in bottom shelf
    self.keyboardContainerView = [[UIView alloc] init];
    [self.keyboardContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomPanel addSubview:self.keyboardContainerView];
    
    self.keyboardView = [[KeyboardView alloc] init];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardContainerView addSubview:self.keyboardView];
    
    // Setup modulation wheel in bottom shelf
    self.modWheelControl =  [[WheelControl alloc] init];
    self.modWheelControl.wheelControlType = WheelControlTypeModulation;
    [self.modWheelControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardContainerView addSubview:self.modWheelControl];
    
    // Setup pitchbend wheel in bottom shelf
    self.pitchbendWheelControl =  [[WheelControl alloc] init];
    self.pitchbendWheelControl.wheelControlType = WheelControlTypePitchbend;
    [self.pitchbendWheelControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.keyboardContainerView addSubview:self.pitchbendWheelControl];
    
    self.iaaView = [[IAAView alloc] init];
    [self.iaaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.iaaView setHidden:YES];
    [self.view addSubview:self.iaaView];

    NSDictionary *viewsDictionary = @{
                                      @"buildView"              :   self.buildViewScrollView,
                                      @"componentShelf"         :   self.componentShelf,
                                      @"bottomPanel"            :   self.bottomPanel,
                                      @"keyboardContainerView"  :   self.keyboardContainerView,
                                      @"keyboardView"           :   self.keyboardView,
                                      @"modWheelControl"        :   self.modWheelControl,
                                      @"pitchWheelControl"      :   self.pitchbendWheelControl,
                                      @"iaaView"                :   self.iaaView,
                                      @"topGuide"               :   self.topLayoutGuide,
                                      @"bottomGuide"            :   self.bottomLayoutGuide
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentShelf]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomPanel]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iaaView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    NSDictionary *metricsDictionary = @{
                                        @"buildViewWidth"       : [NSNumber numberWithFloat:kBuildViewWidth],
                                        @"componentShelfHeight" : [NSNumber numberWithFloat:kComponentShelfHeight],
                                        @"keyboardHeight"       : [NSNumber numberWithFloat:kKeyboardHeight]
                                        };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][componentShelf(componentShelfHeight)]"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kBuildViewWidth + (kBuildViewPadding * 2.0)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    // Constraints used to show / hide keyboard & iaaview
    self.iaaPositionConstraint = [NSLayoutConstraint constraintWithItem:self.iaaView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.bottomPanel
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0];
    
    self.bottomPanelPositionConstraint = [NSLayoutConstraint constraintWithItem:self.bottomPanel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomLayoutGuide
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    
    [self.bottomPanel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardContainerView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.bottomPanel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[keyboardContainerView]|" options:0 metrics:nil views:viewsDictionary]];
    
    [self.keyboardContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[modWheelControl(40)][pitchWheelControl(40)][keyboardView]-20-|"
                                                                                       options:0 metrics:nil views:viewsDictionary]];
    [self.keyboardContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[modWheelControl]|" options:0 metrics:nil views:viewsDictionary]];
    [self.keyboardContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pitchWheelControl]|" options:0 metrics:nil views:viewsDictionary]];
    [self.keyboardContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[keyboardView]|" options:0 metrics:nil views:viewsDictionary]];
    
    [self.view addConstraint:self.iaaPositionConstraint];
    [self.view addConstraint:self.bottomPanelPositionConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomPanel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kKeyboardHeight]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0@750-[buildView][iaaView]"
                                                                      options:0
                                                                      metrics:metricsDictionary
                                                                        views:viewsDictionary]];
    
    self.shiftBuildViewConstraint = [NSLayoutConstraint constraintWithItem:self.buildViewScrollView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:self.componentShelf
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:0];
    
    [self.shiftBuildViewConstraint setPriority:UILayoutPriorityRequired];
    [self.view addConstraint:self.shiftBuildViewConstraint];
    
    UIImage *wrenchIcon = [UIImage imageNamed:TOOLBAR_BUILD_ICON];
    self.buildBarButtonItem = [[UIBarButtonItem alloc] initWithImage:wrenchIcon style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self setBuildMode:NO animated:NO];
    
    UIImage *keyboardIcon = [UIImage imageNamed:TOOLBAR_PIANO_ICON];
    self.keyboardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:keyboardIcon style:UIBarButtonItemStylePlain target:self action:@selector(keyboardTapped)];
    
//    self.sequencerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:keyboardIcon style:UIBarButtonItemStylePlain target:self action:@selector(sequencerTapped)];
//    
//    UIImage *playIcon = [UIImage imageNamed:TOOLBAR_PLAY_ICON];
//    self.playStopBarButtonItem = [[UIBarButtonItem alloc] initWithImage:playIcon style:UIBarButtonItemStylePlain target:self action:@selector(playStopTapped)];

    [self.navigationItem setLeftBarButtonItems:@[self.buildBarButtonItem, self.keyboardBarButtonItem]];
    
    UIImage *filesIcon = [UIImage imageNamed:TOOLBAR_FILES_ICON];
    self.filesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:filesIcon style:UIBarButtonItemStylePlain target:self action:@selector(filesTapped)];
    
//    UIImage *saveIcon = [UIImage imageNamed:TOOLBAR_SAVE_ICON];
//    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:saveIcon style:UIBarButtonItemStylePlain target:self action:@selector(saveTapped)];
    
    [self.navigationItem setRightBarButtonItems:@[self.filesBarButtonItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appWillEnterForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    // Setup initial view
    [self setBottomPanelHidden:NO animated:NO onCompletion:nil];
    [self setIaaViewHidden:YES];
    
    // Load initial preset
    self.preset = [[PresetController sharedController] recallPresetAtIndex:0];
    [self.buildView buildFromDictionary:[self.preset dictionary]];
    
//    // Register for updates from the transport controller
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedOfTransportUpdate:) name:kCOLEventTransportStateUpdated object:nil];
//
    // We need to know when the engine has forced a disconnect
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(engineDidForceDisconnect:) name:kCCOLEventEngineDidForceDisconnect object:nil];

    // Set up test
//    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
//    CCOLComponentAddress vco = [cae createCComponentOfType:(char*)kCCOLComponentTypeVCO];
//    CCOLOutputAddress vcoMainOut = [cae getOutputNamed:(char*)"MainOut" onComponent:vco];
//    CCOLInputAddress mainL = [cae getMasterInputAtIndex:0];
//    
//    [cae connectOutput:vcoMainOut toInput:mainL];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cae unmute];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[[COLAudioEnvironment sharedEnvironment] transportController] stop];
//    [[[COLAudioEnvironment sharedEnvironment] transportController] stopAndReset];
    [self.cae mute];
}

-(void)appWillEnterForeground {
    if ([self.cae isInterAppAudioConnected]) {
        [self setIaaViewHidden:NO];
        [self.playStopBarButtonItem setEnabled:NO];
    } else {
        [self setIaaViewHidden:YES];
        [self.playStopBarButtonItem setEnabled:YES];
    }
}

#pragma mark Toolbar

-(void)editTapped {
    if (!self.buildMode) {
        [self setBuildMode:YES animated:YES];
    } else {
        [self setBuildMode:NO animated:YES];
    }
}

-(void)keyboardTapped {
    [self showOrHideKeyboard];
}

-(void)showOrHideKeyboard {
    if (self.bottomPanelHidden) {
        // Show bottom panel
        [self setBottomPanelHidden:NO animated:YES onCompletion:nil];
    } else {
        // Hide bottom panel
        [self setBottomPanelHidden:YES animated:YES onCompletion:nil];
    }
}

-(void)filesTapped {
    if (self.buildMode) {
        [self setBuildMode:NO animated:YES];
    }
    
    [self.cae allNotesOff];
    
    //[[[COLAudioEnvironment sharedEnvironment] keyboardComponent] allNotesOff];
    
    [self savePresetCompletion:^(BOOL success) {
        FilesViewController *filesViewController = [[FilesViewController alloc] initWithBuildViewController:self];
        [self.navigationController pushViewController:filesViewController animated:YES];
    }];
}

-(void)saveTapped {
    [self.cae exportEnvironment];
    
    if (self.buildMode) {
        [self setBuildMode:NO animated:YES];
    }
    
    [self savePresetCompletion:nil];
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
        [self.buildBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON_SELECTED]];
    } else {
        // Hide shelf
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
        [self.buildBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_BUILD_ICON]];
    }
}


-(void)setIaaViewHidden:(BOOL)hidden {
    [self.iaaView setHidden:hidden];
    if (hidden) {
        [self.iaaPositionConstraint setConstant:58];
    } else {
        [self.iaaView updateContents];
        [self.iaaPositionConstraint setConstant:0];
    }
}

-(void)setBottomPanelHidden:(BOOL)keyboardHidden animated:(BOOL)animated onCompletion:(void (^)())onCompletion {
    self.bottomPanelHidden = keyboardHidden;
    if (keyboardHidden) {
        // Hide keyboard
        if (animated) {
            [UIView animateWithDuration:0.12f animations:^ {
                [self.bottomPanelPositionConstraint setConstant:kKeyboardHeight - 44];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    if (onCompletion) {
                        onCompletion();
                    }
                });
            }];
        } else {
            [self.bottomPanelPositionConstraint setConstant:kKeyboardHeight - 44];
            if (onCompletion) {
                onCompletion();
            }
        }
//        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON]];
    } else {
        // Show keyboard
        if (animated) {
            [UIView animateWithDuration:0.12f animations:^ {
                [self.bottomPanelPositionConstraint setConstant:0];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    if (onCompletion) {
                        onCompletion();
                    }
                });
            }];
        } else {
            [self.bottomPanelPositionConstraint setConstant:0];
            if (onCompletion) {
                onCompletion();
            }
        }
//        [self.keyboardBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PIANO_ICON_SELECTED]];
    }
}

#pragma mark Transport

-(void)playStopTapped {
    
    if ([self.cae isTransportPlaying]) {
        [self.cae transportStop];
    } else {
        [self.cae transportPlay];
    }
}

-(void)notifiedOfTransportUpdate:(NSNotification*)note {
    
//    __weak BuildViewController *weakSelf = self;
//    
//    dispatch_async(dispatch_get_main_queue(), ^ {
//        [weakSelf.iaaView updateContents];
//        
//        if ([[[COLAudioEnvironment sharedEnvironment] transportController] isPlaying]) {
//            [weakSelf.playStopBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_STOP_ICON]];
//        } else {
//            [weakSelf.playStopBarButtonItem setImage:[UIImage imageNamed:TOOLBAR_PLAY_ICON]];
//        }
//    });
}

-(void)engineDidForceDisconnect:(NSNotification*)note {
    [self.buildView forceDisconnect:note.userInfo];
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
                [self.buildView addViewForModule:module atPoint:[gesture locationInView:self.buildView] identifier:nil];
            }
        }
    }
}

#pragma LoadSave

-(void)savePresetCompletion:(void (^)(BOOL success))completion {
    
    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    [self.navigationController.view addSubview:blockingView];
    
    UILabel *blockingViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                           (blockingView.bounds.size.height / 2.0) - 64.0,
                                                                           blockingView.bounds.size.width,
                                                                           64)];
    
    [blockingViewLabel setTextAlignment:NSTextAlignmentCenter];
    [blockingViewLabel setTextColor:[UIColor whiteColor]];
    [blockingViewLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [blockingViewLabel setText:@"Saving..."];
    [blockingView addSubview:blockingViewLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(blockingView.bounds.size.width / 2.0 - 100,
                                                                                    blockingView.bounds.size.height / 2.0,
                                                                                    200,
                                                                                    64)];
    [progressView setProgress:0.0];
    [blockingView addSubview:progressView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
        NSLog(@"BuildViewController: Creating thumbnail...");
        
        CGFloat aspect = self.buildViewScrollView.contentSize.height / self.buildViewScrollView.contentSize.width;
        CGFloat thumbnailHeight = 300;
        UIImage *thumbnail = [[self.buildViewScrollView snapshot] resizeTo:CGSizeMake((int)(thumbnailHeight / aspect), thumbnailHeight)];
        NSLog(@"BuildViewController: Thumbnail created.");
        NSLog(@"BuildViewController: Creating preset dicionary...");
        NSDictionary *dictionary = [self.buildView getPresetDictionary];
        NSLog(@"BuildViewController: Preset dicionary created.");
        
        NSLog(@"BuildViewController: Sending to preset controller...");
        [[PresetController sharedController] updateSelectedPresetWithDictionary:dictionary
                                                                           name:self.preset.name
                                                                      thumbnail:thumbnail
                                                                       progress:^ (float progress){
                                                                           [progressView setProgress:progress animated:YES];;
                                                                       }];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (completion) {
                completion(YES);
            }
            [blockingView removeFromSuperview];
        });
    });
}

-(void)recallPreset:(Preset*)preset completion:(void (^)(BOOL success))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL success = [self.buildView buildFromDictionary:preset.dictionary];
        if (completion) {
            completion(success);
        }
    });
}

#pragma mark Convenience Methods

+(BuildView*)buildView {
    return buildView;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
