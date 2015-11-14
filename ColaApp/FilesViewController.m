//
//  PatchesViewController.m
//  ColaApp
//
//  Created by Chris on 13/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "FilesViewController.h"
#import "PresetController.h"
#import "BuildViewController.h"
#import "FilesViewControllerCell.h"

@interface FilesViewController ()

@property (nonatomic, weak) BuildViewController *buildViewController;

@property CGSize cellSize;

//@property (nonatomic) NSMutableArray *selectedCellSet;
@property (nonatomic, strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *addBarButtonItem;

@property (nonatomic, strong) UIBarButtonItem *exportBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *trashBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *duplicateBarButtonItem;

@property (nonatomic, strong) NSArray *editBarButtonItems;

@end

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@implementation FilesViewController


-(instancetype)initWithBuildViewController:(BuildViewController*)buildViewController {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        self.buildViewController = buildViewController;
        self.cellSize = CGSizeMake(200, 300);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Files"];
    
    [self.collectionView registerClass:[FilesViewControllerCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];

    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [backgroundView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [self.collectionView setBackgroundView:backgroundView];
    
    self.addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
    [self.navigationItem setLeftBarButtonItem:self.addBarButtonItem];
    
    self.editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)];
    [self.navigationItem setRightBarButtonItem:self.editBarButtonItem];
    
    self.exportBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    self.trashBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashTapped)];
    
    UIImage* copyImage = [UIImage imageNamed:TOOLBAR_COPY_ICON];
    self.duplicateBarButtonItem = [[UIBarButtonItem alloc] initWithImage:copyImage style:UIBarButtonItemStylePlain target:self action:nil];
    self.editBarButtonItems = @[self.exportBarButtonItem, self.duplicateBarButtonItem, self.trashBarButtonItem];
    
    [self.collectionView setAllowsMultipleSelection:YES];
}

-(void)addTapped {
    
    NSUInteger newIndex = [[PresetController sharedController] addNewPreset];

    NSArray *newIndexPath = @[[NSIndexPath indexPathForRow:newIndex inSection:0]];
    
    [self.collectionView performBatchUpdates:^ {
        [self.collectionView insertItemsAtIndexPaths:newIndexPath];
    } completion:^ (BOOL finished) {
        if (finished) {
            [self loadPresetAtIndex:newIndex];
        }
    }];
}

-(void)editTapped {
    if (self.editing) {
        [self setEditing:NO animated:YES];
    } else {
        [self.trashBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self setEditing:YES animated:YES];
    }
}

-(void)trashTapped {
    [[PresetController sharedController] removeFilesAtIndexes:[self.collectionView indexPathsForSelectedItems]];
    [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    
    [self.trashBarButtonItem setEnabled:NO];
    [self.exportBarButtonItem setEnabled:NO];
    [self.duplicateBarButtonItem setEnabled:NO];
    
    [self setEditing:NO animated:YES];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.editBarButtonItem setTitle:@"Done"];
        [self.navigationItem setLeftBarButtonItems:self.editBarButtonItems animated:YES];
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell startJiggling];
            [thisCell setSelected:NO];
        }        
    } else {
        [self.editBarButtonItem setTitle:@"Select"];
        [self.navigationItem setLeftBarButtonItems:@[self.addBarButtonItem] animated:YES];
        [self deselectAll];
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell stopJiggling];
            [thisCell setSelected:NO];
        }
    }
}

-(void)deselectAll {
    
    for (NSIndexPath *thisIndexPath in [self.collectionView indexPathsForSelectedItems]) {
        [self.collectionView deselectItemAtIndexPath:thisIndexPath animated:NO];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[PresetController sharedController] presetCount];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16, 16, 16, 16);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilesViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    Preset *preset = [[PresetController sharedController] presetAtIndex:indexPath.row];
    [cell setPreset:preset];
    [cell setHighlighted:NO];
    [cell setSelected:NO];
    
    if (self.editing) {
        [cell startJiggling];
    } else {
        [cell stopJiggling];
    }
    
    [cell updateContents];
    
    return cell;
}

-(void)updateEditBarButtons {
    if ([[self.collectionView indexPathsForSelectedItems] count] == 0) {
        [self.trashBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
    } else if ([[self.collectionView indexPathsForSelectedItems] count] == 1) {
        [self.trashBarButtonItem setEnabled:YES];
        [self.duplicateBarButtonItem setEnabled:YES];
        [self.exportBarButtonItem setEnabled:YES];
    } else {
        [self.trashBarButtonItem setEnabled:YES];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.editing) {
        [self loadPresetAtIndex:indexPath.row];
    } else {
        [self updateEditBarButtons];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        [self updateEditBarButtons];
    }
}

-(void)loadPresetAtIndex:(NSUInteger)index {
    
    Preset *selectedPreset = [[PresetController sharedController] recallPresetAtIndex:index];
    [self.collectionView reloadData];
    
    UIView *blockingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [blockingView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.navigationController.view addSubview:blockingView];
    
    [self.buildViewController recallPreset:selectedPreset completion:^(BOOL success) {
        [blockingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

@end
