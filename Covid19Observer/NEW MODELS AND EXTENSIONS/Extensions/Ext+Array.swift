//
//  Ext+Array.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

/// https://stackoverflow.com/questions/35160890/swift-running-sum
/// In functional programming terms, the prefix sum may be generalized to any binary operation (not just the addition operation); the higher order function resulting from this generalization is called a scan, and it is closely related to the fold operation. Both the scan and the fold operations apply the given binary operation to the same sequence of values, but differ in that the scan returns the whole sequence of results from the binary operation, whereas the fold returns only the final result.
extension Array {
    func scan<T>(_ initial: T, _ f: (T, Element) -> T) -> [T] {
        return self.reduce([initial], { (listSoFar: [T], next: Element) -> [T] in
            // because we seeded it with a non-empty
            // list, it's easy to prove inductively
            // that this unwrapping can't fail
            let lastElement = listSoFar.last!
            return listSoFar + [f(lastElement, next)]
        })
            .dropLast()
    }
}
