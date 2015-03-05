//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComponentTrayView;
@protocol ComponentTrayDelegate <NSObject>

@optional
-(void)componentTray:(ComponentTrayView*)componentTray didBeginDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentTray:(ComponentTrayView*)componentTray didContinueDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;
-(void)componentTray:(ComponentTrayView*)componentTray didEndDraggingComponent:(id)component withGesture:(UIPanGestureRecognizer*)panGesture;

@end

@interface ComponentTrayView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)handleCellPanGesture:(UIGestureRecognizer*)uigr;

@property (nonatomic, weak)     id<ComponentTrayDelegate> delegate;
@property (nonatomic, strong)   UICollectionView *collectionView;
@property (nonatomic, strong)   UICollectionViewFlowLayout *flowLayout;

@end
