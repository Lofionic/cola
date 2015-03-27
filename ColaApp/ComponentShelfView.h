//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>

@class ComponentShelfView;
@class ModuleDescription;
@protocol ComponentShelfDelegate <NSObject>

@optional
-(void)componentShelf:(ComponentShelfView*)componentTray didBeginDraggingModule:(ModuleDescription*)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentShelf:(ComponentShelfView*)componentTray didContinueDraggingModule:(ModuleDescription*)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentShelf:(ComponentShelfView*)componentTray didEndDraggingModule:(ModuleDescription*)component withGesture:(UIPanGestureRecognizer*)panGesture;

@end

@interface ComponentShelfView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak)     id<ComponentShelfDelegate> delegate;
@property (nonatomic, strong)   UICollectionView *collectionView;
@property (nonatomic, strong)   UICollectionViewFlowLayout *flowLayout;

@end
