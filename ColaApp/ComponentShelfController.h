//
//  ComponentShelfController.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComponentShelfController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end
