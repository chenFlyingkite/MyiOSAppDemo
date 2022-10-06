//
// Created by Eric Chen on 2021/1/22.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation
import Firebase

class CellBinderDefault<T : UICollectionViewCell> {
    private weak var ownByClass: CellFromClass?
    private weak var ownByNib: CellFromNib?
    let sorted = CellHolder<T>.init()

    public func hasOwner() -> Bool {
        return getOwner() != nil
    }

    public func getOwner() -> CellBinder? {
        return ownByClass ?? ownByNib ?? nil
    }

    /// For  UICollectionViewDataSource
    /// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    public func performWhen(binder bind:CellBinder, collectionView cv: UICollectionView, cellForItemAt path: IndexPath) -> UICollectionViewCell {
        self.setup(bind, cv)
        return self.collectionView(cv, cellForItemAt: path)
    }

    // TODO+ : Do we have action?
    func collectionView(_ cv: UICollectionView, didSelectItemAt path: IndexPath) {

    }

    private func setup(_ bind:CellBinder, _ cv:UICollectionView) -> Self {
        if (self.setOwner(bind)) {
            sorted.setLibrary(cv)
            self.register(cv)
        }
        return self
    }

    // return true if owner is from no owner to one,
    // if already has owner, returns false
    private func setOwner(_ own:Any?) -> Bool {
        if (hasOwner() == false) {
            if let own = (own as? CellFromClass) {
                ownByClass = own
            } else if let own = (own as? CellFromNib) {
                ownByNib = own
            }
            return hasOwner()
        }
        return false
    }

    private func idOf(_ c:AnyClass) -> String {
        return String(describing: c)
    }

    private func register(_ cv: UICollectionView) {
        if let owner = ownByClass {
            let cls = owner.cellClasses()
            let n = cls.count;
            for i in 0..<n {
                let ci:AnyClass = cls[i]
                let si = idOf(ci)
                cv.use(ci, cellId: si)
            }
        } else if let owner = ownByNib {
            let ns = owner.cellNibNames()
            let n = ns.count
            for i in 0..<n {
                cv.useNibCellId(ns[i])
            }
        }
    }

    private func collectionView(_ cv: UICollectionView, cellForItemAt path: IndexPath) -> UICollectionViewCell {
        // Used to register cell
        var sid : String? = nil
        var owner : CellBinder? = nil
        // For class, id = class name
        // For nib, id = nib name
        if (ownByClass != nil) {
            let ow = ownByClass!
            sid = idOf(ow.cellClasses()[ow.cellClassAt(path)])
            owner = ow
        } else if (ownByNib != nil) {
            let ow = ownByNib!
            let at = ow.cellNibIndex(for: path)
            sid = ow.cellNibNames()[at]
            owner = ow
        }
        if (sid != nil && owner != nil) {
            let id = sid!
            let own = owner!
            let cell = cv.dequeueReusableCell(withReuseIdentifier: id, for: path)
            own.onBindCell(cv, cell:cell, at: path)
            return cell
        } else {
            
            Crashlytics.crashlytics().log("CellBinderDefault else: return UICollectionViewCell()")
            return UICollectionViewCell()
        }
    }

}


