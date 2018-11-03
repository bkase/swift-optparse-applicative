//
//  Chunk.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Swiftz
import Operadics
import DoctorPretty

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

extension AdjoinNil /*: Monad */ {
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
    
    static func from<C: Collection>(collection: C) -> AdjoinNil where C.Iterator.Element == A {
        if let head = collection.first {
            return AdjoinNil.pure(sconcat(head, Array(collection.dropFirst())))
        } else {
            return AdjoinNil.mempty
        }
    }
}

infix operator <<+>>: AdditionPrecedence
infix operator <<%>>: AdditionPrecedence

func <<+>>(lhs: AdjoinNil<Doc>, rhs: AdjoinNil<Doc>) -> AdjoinNil<Doc> {
    return AdjoinNil<Doc>.lift{ x, y in x <+> y }(lhs, rhs)
}

func <<%>>(lhs: AdjoinNil<Doc>, rhs: AdjoinNil<Doc>) -> AdjoinNil<Doc> {
    return AdjoinNil<Doc>.lift{ x, y in x <%> y }(lhs, rhs)
}

extension Collection where Self.Element == AdjoinNil<Doc>, Self.IndexDistance == Int {
    func sequence() -> AdjoinNil<[Doc]> {
        return mconcat(t: Array(self.map{ $0.fmap{ [$0] } }))
    }
    
    func vcat() -> AdjoinNil<Doc> {
        return sequence().fmap{ $0.fold{$0 <> Doc.hardline <> $1} }
    }
    
    func vsep() -> AdjoinNil<Doc> {
        return sequence().fmap{ $0.fold{$0 <> Doc.hardline <> Doc.hardline <> $1} }
    }
}

extension AdjoinNil where A == Doc {
    static func from(string: String) -> AdjoinNil<A> {
        switch string {
        case "": return AdjoinNil.mempty
        case let x: return AdjoinNil.pure(Doc.text(x))
        }
    }
    
    static func paragraph(_ s: String) -> AdjoinNil<A> {
        let words: [String] = s.split(separator: " ").fmap{ String($0) }
        return words.foldRight(AdjoinNil.mempty) { x, acc in
            AdjoinNil<Doc>.from(string: x) <<%>> acc
        }
    }
    
    static func tabulate(table: [(Doc, Doc)], size: Int = 24) -> AdjoinNil<A> {
        if table.count == 0 {
            return AdjoinNil<Doc>.mempty
        } else {
            let docs: [Doc] = table.map{
                let (k, v) = $0
                return Doc.nest(2, k.fillBreak(size) <+> v)
            }
            return AdjoinNil<Doc>.pure(
                docs.fold{ $0 <> Doc.hardline <> $1 }
            )
        }
    }
}

