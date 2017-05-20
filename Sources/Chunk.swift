//
//  Chunk.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Swiftz

extension AdjoinNil /*: Pointed */ {
    static func pure(_ x: A) -> AdjoinNil<A> {
        return AdjoinNil(.some(x))
    }
}

extension AdjoinNil /*: Functor*/ {
    public func fmap<B>(_ f: @escaping (A) -> B) -> AdjoinNil<B> {
        return AdjoinNil<B>(self.value().fmap(f))
    }
}

extension AdjoinNil /*: MonadPlus*/ {
    static var mzero: AdjoinNil<A> { return AdjoinNil<A>.mempty }
    
    public func bind<B>(_ f: @escaping (A) -> AdjoinNil<B>) -> AdjoinNil<B> {
        return AdjoinNil<B>(self.value().bind{ f($0).value() })
    }
}

extension AdjoinNil {
    static func lift(f: @escaping (A, A) -> A) -> (AdjoinNil, AdjoinNil) -> AdjoinNil {
        return { adj1, adj2 in
            switch (adj1.value(), adj2.value()) {
            case (.none, _): return adj2
            case (_, .none): return adj1
            case let (.some(x), .some(y)):
                return AdjoinNil(.some(f(x, y)))
            default: fatalError("Bad exhaustivity check")
            }
        }
    }
    
    static func fromSequence<C: Collection>(coll: C) -> AdjoinNil where C.Iterator.Element == A, C.SubSequence.Iterator.Element == A {
        if let head = coll.first {
            return AdjoinNil.pure(sconcat(head, Array(coll.dropFirst())))
        } else {
            return AdjoinNil.mzero
        }
    }
}
