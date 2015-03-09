//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComponentShelfView.h"

@interface ComponentShelfCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) ComponentShelfView *componentTrayView;
@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end
