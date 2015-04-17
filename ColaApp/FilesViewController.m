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

@property (nonatomic) NSMutableArray *selectedCellSet;
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
        self.cellSize = CGSizeMake(180, 180);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Files"];
    
    [self.collectionView registerClass:[FilesViewControllerCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
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
    [[PresetController sharedController] addNewPreset];
    
    NSArray *newIndexPath = @[[NSIndexPath indexPathForRow:[[PresetController sharedController] presetCount] - 1 inSection:0]];
    [self.collectionView insertItemsAtIndexPaths:newIndexPath];
}

-(void)editTapped {
    if (self.editing) {
        [self setEditing:NO animated:YES];
    } else {
        self.selectedCellSet = [[NSMutableArray alloc] initWithCapacity:[[PresetController sharedController] presetCount]];
        [self.trashBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self setEditing:YES animated:YES];
    }
}

-(void)trashTapped {

    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexPath in self.selectedCellSet) {
        [indexSet addIndex:indexPath.row];
    }
    
    [[PresetController sharedController] removePresetsAtIndexes:indexSet];
    [self.collectionView deleteItemsAtIndexPaths:self.selectedCellSet];
    
    [self.trashBarButtonItem setEnabled:NO];
    [self.exportBarButtonItem setEnabled:NO];
    [self.duplicateBarButtonItem setEnabled:NO];

}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.editBarButtonItem setTitle:@"Done"];
        [self.navigationItem setLeftBarButtonItems:self.editBarButtonItems animated:YES];
        
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell startJiggling];
        }        
    } else {
        [self.editBarButtonItem setTitle:@"Select"];
        [self.navigationItem setLeftBarButtonItems:@[self.addBarButtonItem] animated:YES];
        
        for (FilesViewControllerCell *thisCell in [self.collectionView visibleCells]) {
            [thisCell stopJiggling];
        }
    }
    
    [self.collectionView reloadData];
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
    
    if (!self.editing && [[PresetController sharedController] selectedPresetIndex] == indexPath.row) {
        [cell setHighlighted:YES];
    } else {
        [cell setHighlighted:NO];
    }
    
    if (self.editing) {
        [cell startJiggling];
    }
    
    [cell updateContents];
    
    return cell;
}

-(void)updateEditBarButtons {
    if ([self.selectedCellSet count] == 0) {
        [self.trashBarButtonItem setEnabled:NO];
        [self.duplicateBarButtonItem setEnabled:NO];
        [self.exportBarButtonItem setEnabled:NO];
    } else if ([self.selectedCellSet count] == 1) {
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
    if (self.editing) {
    FilesViewControllerCell *cell = (FilesViewControllerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedCellSet addObject:indexPath];
    [cell setSelected:YES];
    [self updateEditBarButtons];
    } else {
        [self loadPresetAtIndex:indexPath.row];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilesViewControllerCell *cell = (FilesViewControllerCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedCellSet removeObject:indexPath];
    [cell setSelected:NO];
    [self updateEditBarButtons];
}

-(void)loadPresetAtIndex:(NSUInteger)index {
    
    if (index == [[PresetController sharedController] selectedPresetIndex]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
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
}

@end
