//
// Created by Eric Chen on 2021/1/7.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

#import "FLLibrary.h"
#import "FLLibCell.h"


@implementation FLLibrary {

}

- (instancetype)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout* f = [self flow];
    self = [super initWithFrame:frame collectionViewLayout:f];
    qwe("self + frame = %s, %s", ssCGRect(frame), ssString(self));
    [self setup];
    return self;
}

- (UICollectionViewFlowLayout*) flow {

    UICollectionViewFlowLayout* flow = [UICollectionViewFlowLayout new];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    return flow;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    qwe("self + coder = %s, %s", ssCGRect(self.frame), ssString(self));
    [self setup];
    return self;
}

- (void) setup {
    qwe("%s", "");
    self.backgroundColor = [UIColor colorWithHex:@"#4FFF"];
    //self.dataSource = self;
//    <UICollectionViewDelegate> d
//            <UICollectionViewDataSource>
    [self setD];
}

- (void) setD {
    qw("setup %s", "data source");
    NSMutableArray<NSString*> * a = [NSMutableArray new];
    for (int i = 0; i < 24; i++) {
        NSString *s = [@"#" addF:@"%02d = %d", i, i];
        [a add:s];
    }
    self.myData = a;
    self.dataSource = self;
    self.delegate = self;

    UICollectionViewFlowLayout *l = (UICollectionViewFlowLayout *) self.collectionViewLayout;
    l.itemSize = CGSizeMake(80, 80);
}

#pragma mark - Encapsulated New methods for override

- (int) getCellNibIndex:(NSIndexPath*)path {
    return 0;
}

- (NSArray<NSString*> *)getCellNibNames {
    return @[@"LibCell"];
}

#pragma mark - Encapsulate

int mul = 1000 - 999;

// #sections
// this method will called 0 ~ itemCount in section
//- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)path {
//    int sec = path.section;
//    int pos = path.item;
//    CGSize s = cv.frame.size;
//    CGSize ans = CGSizeMake(s.height, s.height * 3 / 2);
//    qwe("size #%d#%d = %s", sec, pos, ssCGSize(ans));
//    return ans;
//}

#pragma mark - Sample implement
// No need to create, since we take it in cellId
//- (__kindof UICollectionViewCell *) onCreateCell:(__kindof UICollectionView*)cv type:(int)viewType {
//    //int t = [self getItemViewType:path];
//    int t = viewType;
//    NSString* id = [self getCellNibNames][t];
//    return [self dequeueReusableCellWithReuseIdentifier:id forIndexPath:path];
//}

- (void) onBindCell:(__kindof UICollectionView*)cv cell:(__kindof UICollectionViewCell*)cell at:(NSIndexPath*)path {
    FLLibCell* c = cell;
    int p = path.item % self.myData.count;
    qwe("bind #%ld, %ld", p, path.item);
    c.myText.text = self.myData[p];
//    NSArray<NSString*> * cs = @[@"#A00", @"#0A0", @"#00A", @"#aa0", @"#0aa", @"#a0a"];
//    NSString *x = cs[p % cs.count];
//    c.backgroundColor = [UIColor colorWithHex:x];
    c.backgroundColor = FLUIKit.color12[p % 12];
}

#pragma mark - UICollectionViewDataSource Override methods
/*
run order
1. get Sections by
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
2. get item count for section s :
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
3. For each item, ask cell size for 0 ~ itemCount // Severe for performance... since section*itemCount
- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)path;
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    qwe("num sec %s", ssString([self.myData toString]));
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    qwe("num it in Sec %ld, %s", section, ssString([self.myData toString]));
    qwe("%ld items", self.myData.count);
    return self.myData.count * mul;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)path {
    //qwe("%s", "");
    int t = [self getCellNibIndex:path];
    NSString* id = [self getCellNibNames][t];
    //[self registerNib:id forCellWithReuseIdentifier:id];
    [self useNib:id cellId:id]; // duplication?

    qwe("id = %s", ssString(id));
    __kindof UICollectionViewCell *c = [self dequeueReusableCellWithReuseIdentifier:id forIndexPath:path];
    [self onBindCell:self cell:c at:path];
    return c;
    //return [self dequeueReusableCellWithReuseIdentifier:id forIndexPath:path];
}

//-----------

//TODO
//-- UICollectionViewDelegate
// should / did high
- (BOOL)collectionView:(UICollectionView *)cv
shouldHighlightItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
    return true;
}

- (void)collectionView:(UICollectionView *)cv
didHighlightItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
}

// should/did sel
- (BOOL)collectionView:(UICollectionView *)cv
shouldSelectItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
    return true;
}

- (void)collectionView:(UICollectionView *)cv
didSelectItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
    [self selectItemAtIndexPath:path animated:false scrollPosition:UICollectionViewScrollPositionNone];
}

// should / did desel
- (BOOL)collectionView:(UICollectionView *)cv
shouldDeselectItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
    return true;
}

- (void)collectionView:(UICollectionView *)cv
didDeselectItemAtIndexPath:(NSIndexPath *)path {
    [self lgCV:cv];
    qwe("path = %s", ssString(path));
}

- (void) lgCV:(UICollectionView *)cv {
    qq("----");
    NSString* s;
    s = [cv.indexPathsForSelectedItems toString];
    qw("sel = %s", ssString(s));
    s = [cv.indexPathsForVisibleItems toString];
    qw("vis = %s", ssString(s));
}

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

//@optional
/*
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(9.0));
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath API_AVAILABLE(ios(9.0));

/// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
- (nullable NSArray<NSString *> *)indexTitlesForCollectionView:(UICollectionView *)collectionView API_AVAILABLE(tvos(10.2));

/// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
/// Return an index path with a single index to indicate an entire section, instead of a specific item.
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView indexPathForIndexTitle:(NSString *)title atIndex:(NSInteger)index API_AVAILABLE(tvos(10.2));

*/
@end