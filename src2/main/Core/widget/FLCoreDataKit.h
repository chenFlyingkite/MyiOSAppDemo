//
// Created by Eric Chen on 2019-09-01.
// Copyright (c) 2019 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FLError.h"

@interface NSPersistentContainer (FLCoreDataKit)
/// How to add/define new property for class by a extension ?
//@property (nonatomic, copy) FLError *errorFL; // failed

- (void) printAllRecordsOf:(__kindof NSFetchRequest *)request;

/// Methods of CRUD = Create, Read, Update, Delete
/// Create
- (void) insertRecords:(__kindof NSFetchRequest *)request size:(int)size fill:(__kindof NSManagedObject * (^ __nonnull)(__kindof NSManagedObject * newRecord, int index))fill;
- (void) insertRecordsOnComplete:(__kindof NSFetchRequest *)request size:(int)size fill:(__kindof NSManagedObject *(^)(__kindof NSManagedObject *, int))fill complete:(void(^)(BOOL succ))complete;
/// Read
- (bool) existsRecords:(__kindof NSFetchRequest *)request;
- (bool) existsRecords:(__kindof NSFetchRequest *)request where:(NSPredicate *)clause;
/// Read
- (NSArray*) selectAllFrom:(__kindof NSFetchRequest *)request;
/// Read
- (NSArray*) selectAllFrom:(__kindof NSFetchRequest *)request where:(NSPredicate *)clause;
/// Update

/// Delete
- (void) deleteRecords:(__kindof NSFetchRequest *)request;
- (NSArray<FLError*> *) dropPersistentStore:(NSPersistentStore*)store;
- (NSArray<FLError*> *) dropAllDatabase;
- (void) updateRecords:(__kindof NSFetchRequest *)request update:(void (^ __nonnull)(__kindof NSManagedObject * record, int index, int size))update;
@end

@interface FLCoreDataKit : NSObject
@end
