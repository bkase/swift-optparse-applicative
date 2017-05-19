//
//  Prelude.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/19/17.
//
//

// Stuff that shouldn't have to be written. Replace with a library.

import Foundation
import Operadics

func <^><A, B>(lhs: (A) -> B?, rhs: A?) -> B? {
    return rhs.flatMap(lhs)
}

extension Optional {
    func ap<B>(_ fOpt: ((Wrapped) -> B)?) -> B? {
		 return flatMap{ x in fOpt.map{ f in f(x) }}
    }
}
func <*><A, B>(lhs: ((A) -> B)?, rhs: A?) -> B? {
    return rhs.ap(lhs)
}
