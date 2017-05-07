//
//  Nel.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/6/17.
//
//

import Foundation

/// Non-empty lists
indirect enum Nel<T>: Sequence {
    struct NelIterator: IteratorProtocol {
        var v: Nel<T>?
        mutating func next() -> T? {
            switch self.v {
            case .none: return nil
            case let .some(.one(x)):
                self.v = nil
                return x
            case let .some(.more(x, xs)):
                self.v = xs
                return x
            }
        }
    }
    func makeIterator() -> NelIterator {
        return NelIterator(v: self)
    }
    
    case one(T)
    case more(T, Nel<T>)
    
    static func + (lhs: Nel, rhs: Nel) -> Nel {
        switch lhs {
        case let .one(x): return .more(x, rhs)
        case let .more(x, xs): return .more(x, xs + rhs)
        }
    }
    
    static func pure<U>(u: U) -> Nel<U> {
        return .one(u)
    }
}
