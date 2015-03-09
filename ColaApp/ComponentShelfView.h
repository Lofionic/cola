//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComponentShelfView;
@protocol ComponentTrayDelegate <NSObject>

@optional
-(void)componentTray:(ComponentShelfView*)componentTray didBeginDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentTray:(ComponentShelfView*)componentTray didContinueDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentTray:(ComponentShelfView*)componentTray didEndDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;

@end

@interface ComponentShelfView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak)     id<ComponentTrayDelegate> delegate;
@property (nonatomic, strong)   UICollectionView *collectionView;
@property (nonatomic, strong)   UICollectionViewFlowLayout *flowLayout;

@end
