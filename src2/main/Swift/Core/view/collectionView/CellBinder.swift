//
// Created by Eric Chen on 2021/2/2.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

protocol CellBinder : AnyObject, UICollectionViewDataSource, UICollectionViewDelegate {
    // UICollectionViewDataSourcePrefetching
    func onBindCell(_ cv:UICollectionView, cell:UICollectionViewCell, at:IndexPath);
}
