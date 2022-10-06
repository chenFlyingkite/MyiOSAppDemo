//
// Created by Eric Chen on 2021/2/6.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation
import CoreData

// https://developer.apple.com/documentation/coredata/nspersistentstore/persistent_store_types

public class FLDatabase : NSObject {
    public weak var container : NSPersistentContainer?
    public var log = false
    public var logTime = false
    private var clk = FLTicTac.init()

    public init(_ pc:NSPersistentContainer?) {
        super.init()
        container = pc
    }

    public func existsRecords<T : NSManagedObject>(_ request:NSFetchRequest<T>, _ clause:NSPredicate?) -> Bool {
        let r = request
        r.predicate = clause
        return existsRecords(r)
    }

    public func existsRecords<T : NSManagedObject>(_ request:NSFetchRequest<T>) -> Bool {
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return false
        }

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        let r = request
        do {
            if (logTime) {
                clk.tic()
            }
            let n = try ctx.count(for: r)
            if (logTime) {
                clk.tacS("exists \(n) records, existsRecords")
            }
            return n > 0
        } catch {
            print("error = \(error)")
        }
        return false
    }

    // Read
    public func printAllRecordsOf<T : NSManagedObject>(_ request:NSFetchRequest<T>) -> Void {
        let r = request
        let a = selectAllFrom(r)
        printAll(a)
    }

    /// Core read
    /// https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext
    public func selectAllFrom<T : NSManagedObject>(_ request:NSFetchRequest<T>, _ clause:NSPredicate? = nil) -> [T] {
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return []
        }
        let r = request
        r.predicate = clause

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        var a:[T] = []
        do {
            if (logTime) {
                clk.tic()
            }
            a = try ctx.fetch(r)
            if (logTime) {
                clk.tacS("all \(a.count) items in selectAllFrom")
            }
        } catch {
            wqe("error = \(error)")
        }
        return a
    }

    // insert
    public func insertRecords<T : NSManagedObject>(_ request:NSFetchRequest<T>, _ clear:Bool, _ size:Int, _ fill: (_ item:T?, _ at:Int, _ n:Int) -> T? ) -> Bool {
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return false
        }

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        let r = request
        guard let name = r.entityName else {
            print("Entity name is empty")
            return false
        }

        // clear
        if (clear) {
            self.deleteRecords(r, false)
        }

        if (logTime) {
            clk.tic()
        }
        // insert each
        var x : T?
        let n = size
        for i in 0..<n {
            x = NSEntityDescription.insertNewObject(forEntityName: name, into: ctx) as? T
            x = fill(x, i, n)
        }
        if (logTime) {
            clk.tacS("fori in insertRecords")
            clk.tic()
        }

        // check result
        let e = saveContext(ctx)
        let ok = e == nil
        let sk = ok ? "OK" : "NG \(e)"
        if (log) {
            wqe("insert \(n) records \(sk)");
        }
        if (logTime) {
            clk.tacS("insertRecords, clear = \(clear), saved")
        }
        return ok
    }

    public func updateRecords<T : NSManagedObject>(_ request:NSFetchRequest<T>, _ update:(_ item: T, _ index:Int, _ count:Int) -> ()) -> Bool {
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return false
        }

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        let r = request

        if (logTime) {
            clk.tic()
        }
        // update
        let a = selectAllFrom(r)
        let n = a.count
        for i in 0..<n {
            let x = a[i]
            update(x, i, n)
        }

        // check result
        let e = saveContext(ctx)
        let ok = e == nil
        let sk = ok ? "OK" : "NG \(e)"
        if (log) {
            wqe("update \(n) records \(sk)");
        }
        if (logTime) {
            clk.tacS("update")
        }
        return ok
    }

    // clear database by no predicate
    // let c : NSFetchRequest<LHCDF> = LightHitCoreDataFile.fetchRequest()
    // dlcDB = FLDatabase.init(dlcDBSrc)
    // dlcDB?.deleteRecords(c)
    public func deleteRecords<T : NSManagedObject>(_ request:NSFetchRequest<T>, _ save:Bool = true) -> Bool {
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return false
        }

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        let r = request

        if (logTime) {
            clk.tic()
        }
        // update
        let a = selectAllFrom(r)
        let n = a.count
        for i in 0..<n {
            let x = a[i]
            ctx.delete(x)
        }
        if (logTime) {
            clk.tacS("deleteRecords.fori on ctx.delete")
        }

        // check result
        if (save) {
            if (logTime) {
                clk.tic()
            }
            let e = saveContext(ctx)
            let ok = e == nil
            let sk = ok ? "OK" : "NG \(e)"
            if (log) {
                wqe("delete \(n) records \(sk)");
            }
            if (logTime) {
                clk.tacS("saveContext in ctx.delete")
            }
            return ok
        } else {
            return true
        }
    }

    private func saveContext(_ ctx:NSManagedObjectContext)-> Error? {
        var e : Error? = nil
        do {
            try ctx.save()
        } catch {
            e = error
        }
        return e
    }

    /// Core drop
    // TODO : Drop db after load and then any db access will failed
    public func dropDB(_ store:NSPersistentStore) -> [FLError]? {
        var ans:[FLError] = []
        guard let db = container else {
            print("Omit since NSPersistentContainer = \(container)")
            return nil
        }

        let mdl = db.managedObjectModel
        let ctx = db.viewContext
        let psc = db.persistentStoreCoordinator
        let pss = psc.persistentStores
        if (false == pss.contains(store)) {
            print("NSPersistentStore not found \(store)\n in \(pss.toString())");
        } else {
            let u = store.url
            if let u = u {
                let s = u.path
                let t = " for " + s
                var v = ""
                var fe:FLError? = nil

                // Drop database
                print("Dropping \(s)\n  url = \(u)")
                do {
                    try psc.remove(store)
                } catch {
                    v = "NSPersistentStoreCoordinator.removePersistentStore:error;"
                    fe = FLError.ofError(error, from: v + t)
                    ans.append(fe!)
                }

                // Remove database file
                let f = FileManager.default
                do {
                    try f.removeItem(atPath: s)
                } catch {
                    v = "NSFileManager.removeItemAtPath:error;"
                    fe = FLError.ofError(error, from: v + t)
                    ans.append(fe!)
                }
            } else {
                print("store url is empty")
            }
        }
        return ans
    }


    // MARK: Logging
    private func printAll(_ a:[Any]) {
        if (!log) { return }

        let n = a.count
        wqe("\(n) items")
        for i in 0..<n {
            // TODO printf, %2d
            let x = a[i]
            wqe("#\(i) : \(x)")
        }
    }
}
