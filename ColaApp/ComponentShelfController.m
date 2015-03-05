//
//  ComponentShelfController.m
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentShelfCollectionViewCell.h"
#import "ComponentShelfController.h"

@implementation ComponentShelfController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor blueColor]];
    
    [self.collectionView registerClass:[ComponentShelfCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    
    NSDictionary *viewsDictionary = @{
                                      @"collectionView" : self.collectionView
                                      };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:viewsDictionary]];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ComponentShelfCollectionViewCell *cell = (ComponentShelfCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSArray *colours = @[
                         [UIColor redColor],
                         [UIColor orangeColor],
                         [UIColor yellowColor],
                         [UIColor greenColor],
                         [UIColor grayColor],
                         [UIColor purpleColor]
                         ];
    
    [cell.thumbnailImageView setBackgroundColor:[colours objectAtIndex:indexPath.row]];
    
    return cell;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

@end
