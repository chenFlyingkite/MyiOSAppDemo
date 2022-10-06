//
// Created by Eric Chen on 2019-09-01.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import "FLCoreDataKit.h"
#import "FLStringKit.h"
#import "FLNSKit.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
@implementation NSPersistentContainer (FLCoreDataKit)
/// How to add/define new property for class by a extension ?
//@dynamic errorFL; // failed by *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[WebStorePersistentContainer errorFL]: unrecognized selector sent to instance

#pragma mark - Public methods
- (void) printAllRecordsOf:(__kindof NSFetchRequest *)request {
#ifdef DEBUG
    [[self selectAllFrom:request] printAll];
#endif
}

- (void) insertRecordsOnComplete:(__kindof NSFetchRequest *)request size:(int)size fill:(__kindof NSManagedObject *(^)(__kindof NSManagedObject *, int))fill complete:(void(^)(BOOL succ))complete {
    NSManagedObjectContext *ctx = self.viewContext;
    NSFetchRequest *r = request;

    __kindof NSManagedObject *fi;
    for (int i = 0; i < size; i++) {
        fi = [NSEntityDescription insertNewObjectForEntityForName:r.entityName inManagedObjectContext:ctx];
        fi = fill(fi, i);
    }
    NSError *e;
    bool b = [ctx save:&e];
    qw("insert %d records = %s, %s", size, ox(b), ssString(e));
    complete(b);
}

- (void) insertRecords:(__kindof NSFetchRequest *)request size:(int)size fill:(__kindof NSManagedObject * (^ __nonnull)(__kindof NSManagedObject * newRecord, int index))fill {
    NSManagedObjectModel *mdl = self.managedObjectModel;
    NSManagedObjectContext *ctx = self.viewContext;
    NSFetchRequest *r = request;

    __kindof NSManagedObject *fi;
    for (int i = 0; i < size; i++) {
        fi = [NSEntityDescription insertNewObjectForEntityForName:r.entityName inManagedObjectContext:ctx];
        fi = fill(fi, i);
    }
    NSError *e;
    bool b = [ctx save:&e];
    qw("insert %d records = %s, %s", size, ox(b), ssString(e));
}

- (bool) existsRecords:(__kindof NSFetchRequest *)request {
    NSArray *a = [self selectAllFrom:request];
    return a.count > 0;
}

- (bool) existsRecords:(__kindof NSFetchRequest *)request where:(NSPredicate *)clause {
    NSArray *a = [self selectAllFrom:request where:clause];
    return a.count > 0;
}

- (NSArray*)selectAllFrom:(__kindof NSFetchRequest *)request where:(NSPredicate *)clause {
    request.predicate = clause;
    return [self selectAllFrom:request];
}

/// Core read
- (NSArray*) selectAllFrom:(__kindof NSFetchRequest *)request {
    NSManagedObjectModel *mdl = self.managedObjectModel;
    NSManagedObjectContext *ctx = self.viewContext;
    NSFetchRequest *r = request;
    NSError *e;

    NSArray *a = [ctx executeFetchRequest:r error:&e];
    printError(e);
    qw("select All from %s", ssString(request));
#ifdef DEBUG
    [a printAll];
#endif
    return a;
}

- (void) deleteRecords:(__kindof NSFetchRequest *)request {
    NSManagedObjectContext *ctx = self.viewContext;
    NSArray *a = [self selectAllFrom:request];
    qw("delete of %s", ssString(a));
    int n = a.count;
    for (int i = n - 1; i >= 0; i--) {
        [ctx deleteObject:a[i]];
    }
    NSError* e;
    [ctx save:&e];
}

- (void) updateRecords:(__kindof NSFetchRequest *)request update:(void (^ __nonnull)(__kindof NSManagedObject * record, int index, int size))update {
    NSManagedObjectContext *ctx = self.viewContext;
    NSArray *a = [self selectAllFrom:request];
    int n = a.count;
    for (int i = 0; i < n; ++i) {
        update(a[i], i, n);
    }
    NSError *e;
    [ctx save:&e];
}

/// Core drop
// TODO : Drop db after load and then any db access will failed
- (NSArray<FLError*> *) dropPersistentStore:(NSPersistentStore*)store {
    NSMutableArray<FLError*> *ans = [NSMutableArray new];
    NSPersistentStoreCoordinator *p = self.persistentStoreCoordinator;
    NSArray<NSPersistentStore*> *ps = p.persistentStores;
    NSFileManager *f = NSFileManager.defaultManager;

    if ([ps containsObject:store]) {
        NSError *e;
        FLError *fe;
        NSString *s = store.URL.path;
        NSString *t = [@"" addF:@" for %@", s];
        NSString *v;
        NSString *se;
        qw("Dropping %s\n   url = %s", s.UTF8String, ssString(store.URL));

        // Drop database
        [p removePersistentStore:store error:&e];
        if (e) {
            v = @"NSPersistentStoreCoordinator.removePersistentStore:error;";
            se = [v add:t];
            fe = [FLError ofError:e from:se];
            [ans addObject:fe];
        }

        // Remove database file
        [f removeItemAtPath:s error:&e];
        if (e) {
            v = @"NSFileManager.removeItemAtPath:error;";
            se = [v add:t];
            fe = [FLError ofError:e from:se];
            [ans addObject:fe];
        }
    } else {
        qw("NSPersistentStore not found in %s", ssString(ps));
    }
    return ans;
}

- (NSArray<FLError*> *) dropAllDatabase {
    NSMutableArray<FLError*> *ans = [NSMutableArray new];
    NSArray<NSPersistentStore*> *p = self.persistentStoreCoordinator.persistentStores;

    NSArray<FLError*> *es;
    int n = p.count;
    for (int i = n - 1; i >= 0; i--) {
        NSPersistentStore *pi = p[i];
        es = [self dropPersistentStore:pi];
        if (es)
        [ans addObjectsFromArray:es];
    }
    return ans;
}

#pragma mark - basic
@end

@implementation FLCoreDataKit
@end

#pragma clang diagnostic pop