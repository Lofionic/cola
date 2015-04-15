//
//  PatchesViewController.h
//  ColaApp
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuildViewController;
@interface FilesViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

-(instancetype)initWithBuildViewController:(BuildViewController*)buildViewController;

@end
