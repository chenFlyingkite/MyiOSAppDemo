//
// Created by Eric Chen on 2021/1/7.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLUtil.h"
#import "FLUIKit.h"
#import "FLNSKit.h"
#import "FLResKit.h"

@protocol FLL
@end

@interface FLLibrary<Data, CellVH : UICollectionViewCell*> : UICollectionView<UICollectionViewDataSource
        , UICollectionViewDelegateFlowLayout
        //, FLL
        >
@property (nonatomic, strong) NSArray *myData;
//@property (nonatomic, strong) NSArray<Data> *myData; // failed when get count
//- (T*) gett;
//- (CellVH) onC;

- (void) setup;

#pragma mark - Encapsulated New methods for override
//- (int) getItemViewType:(NSIndexPath*)path;
- (int) getCellNibIndex:(NSIndexPath*)path;
- (NSArray<NSString*> *)getCellNibNames;
- (void) onBindCell:(__kindof UICollectionView*)cv cell:(__kindof UICollectionViewCell*)cell at:(NSIndexPath*)path;
//- (__kindof UICollectionViewCell *) onCreateCell:(__kindof UICollectionView*)cv type:(int)viewType;
@end
