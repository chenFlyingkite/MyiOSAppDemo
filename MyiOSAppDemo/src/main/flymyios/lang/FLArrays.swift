//
// Created by Eric Chen on 2021/2/26.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation

public class FLArrays {
    // Collections
    public class func binarySearch<T : Comparable>(_ a:[T], _ key:T) -> Int {
        return binarySearch(a, key, 0, a.count)
    }

    public class func binarySearch<T : Comparable>(_ a:[T], _ key:T, _ fromIndex:Int, _ toIndex:Int) -> Int {
        var low = fromIndex, high = toIndex - 1
        while (low <= high) {
            let mid = (low + high) >> 1
            let midVal = a[mid]
            if (midVal < key) {
                low = mid + 1
            } else if (midVal > key) {
                high = mid - 1
            } else {
                return mid // key found
            }
        }
        return -(low + 1) // key not found
    }

    /*
    public class func compare<T : Comparable>(_ a:[T], _ aFromIndex:Int, _ aToIndex:T, _ b:[T], _ bFromIndex:Int, _ bToIndex:T) -> Int {
        let aLength = aToIndex - aFromIndex;
        let bLength = bToIndex - bFromIndex;
        let length = minl(aLength, bLength);
        for i in 0..<length {
            let oa = a[aFromIndex];
            let ob = b[bFromIndex];
            aFromIndex++;
            bFromIndex++
            if (oa != ob) {
                if (oa == null || ob == null)
                    return oa == null ? -1 : 1;

                    int v = oa.compareTo(ob);
                if (v != 0) {
                    return v;
                }
            }
        }

        return aLength - bLength;
//        if (a == b) {
//            return 0;
//        }
        if (a == null || b == null) {
            return a == null ? -1 : 1;
        }

        int i = ArraysSupport.mismatch(a, b,
                Math.min(a.length, b.length));
        if (i >= 0) {
            return Float.compare(a[i], b[i]);
        }

        return a.length - b.length;

    }
    */
}
