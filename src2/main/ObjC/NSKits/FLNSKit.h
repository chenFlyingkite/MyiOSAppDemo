//
// Created by Eric Chen on 2020/12/30.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLLog.h"
#import "FLStringKit.h"

@interface FLNSKit : NSObject
@end

@interface NSURL (DeepCopy)
- (NSURL *) deepCopy;
@end


// In Java = public interface MyInterface<T extends SuperT & InterfaceT> extends MyIntSuper {}
// In ObjC = @interface MyInterface<__covariant T : SuperT<InterfaceT>*> : MyIntSuper
@interface NSArray<__covariant T> (Logging)
- (BOOL) isEmpty;
- (BOOL) isNotEmpty;
- (void) printAll;
- (NSString *) toString;
@end

// TODO erase the type T to let swift calls
//@interface NSArray (Logging)
//- (void) pa;
//@end

@interface NSArray<__covariant T> (Access)
- (NSArray<T>*) addsAll:(NSArray<T>*)end;
- (NSArray<T>*) adds:(T)item;
@end

// Using NSMutableArray<__covariant T> makes compile failed?
// We only omit type...
// Covariant type parameter 'T' conflicts with previous invariant type parameter 'ObjectType'
// Type parameter 'ObjectType' declared here (in NSArray.h)...
//   -> @interface NSMutableArray<ObjectType> : NSArray<ObjectType>
@interface NSMutableArray (Access2)
- (void) addAll:(NSArray*)end;
- (void) add:(id)item;
@end