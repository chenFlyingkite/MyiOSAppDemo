//
// Created by Eric Chen on 2021/2/26.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation



// Since iOS gives us random indices and unsorted visible cells, and it maybe have gap between them...
// like gives indices = [{0, 3}, {0, 0}, {0, 1}] and cell = [#3, #0, #1]...
// Even if it seems that iOS is cell[i].index = indices[i], but we still sort by left-top...
class CellHolder<T : UICollectionViewCell> : NSObject {
    private var indices = [IndexPath]()
    private var cells = [T]()
    private var useUpToDate = true

    private weak var library : UICollectionView? = nil

    func setLibrary(_ cv : UICollectionView?) {
        self.library = cv
    }

//
// This assume the count range same... but did not check its inters
//    private func isSame() -> Bool {
//        guard let cv = library else { return false }
//        let n = indices.count
//        if (n == 0) {
//            return false
//        }
//
//        var v = cv.indexPathsForVisibleItems
//        var min = indexPathOf(0)!;
//        var max = indexPathOf(0)!;
//        for x in v {
//            let  s = x.section,    r = x.row
//            let ms = min.section, mr = min.row
//            let xs = max.section, xr = max.row
//            if (s < ms || (s == ms && r < mr)) {
//                min = x
//            }
//            if (s > xs || (s == xs && r > xr)) {
//                max = x
//            }
//        }
//        return min == self.indices[0] && max == self.indices[n-1]
//    }

    func cellVis(_ p:Int) -> T? {
        if (useUpToDate) {
            refresh()
        }
        if (inBound3(p, 0, cells.count)) {
            return cells[p]
        }
        return nil
    }

    func cellViewAt(_ p:IndexPath) -> T? {
        if (useUpToDate) {
            refresh()
        }
        let pAt = FLArrays.binarySearch(indices, p)
        if (pAt < 0) {
            return nil
        } else {
            return cells[pAt]
        }
    }

    private func refresh() -> Void {
        guard let cv = library else { return }
        //let t = FLTicTac.init()
        //t.tic()
        refresh(cv)
        //t.tacS("refresh")
    }

    private func refresh(_ cv: UICollectionView) -> Void {
        var x = cv.indexPathsForVisibleItems
        var y = cv.visibleCells

        x.sort(by: { p1, p2 in
            return p1 < p2
        })
        y.sort(by: { c1, c2 in
            return CGRect.sortTopLeft(c1.frame, c2.frame)
        })
        self.indices = x
        self.cells = (y as? [T]) ?? []
    }
}
