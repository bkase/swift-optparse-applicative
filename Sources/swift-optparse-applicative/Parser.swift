//
//  Parser.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/6/17.
//
//

import Foundation
import Operadics
import Swiftx

indirect enum Parser<Value> {
    case nilP(Value?)
    case optP(Opt<Value>)
    case altP(attempt: Parser<Value>, fallback: Parser<Value>)
    case _multP(pf: Parser<(Any) -> Value>, input: Parser<Any>)
    case _bindP(pIn: Parser<Any>, inToPa: (Any) -> Parser<Value>)
    
    static func multP<In>(pf: Parser<(In) -> Value>, input: Parser<In>) -> Parser<Value> {
        return ._multP(
            pf: pf.fmap{ inToA in
                { any in inToA(any as! In) }
            },
            input: input.fmap{ $0 as Any }
        )
    }
    
    static func bindP<In>(pIn: Parser<In>, inToPa: @escaping (In) -> Parser<Value>) -> Parser<Value> {
        return ._bindP(
            pIn: pIn.fmap{ $0 as Any },
            inToPa: { any in inToPa(any as! In) }
        )
    }
    
    var defaultValue: A? {
        switch self {
        case let .nilP(r): return r
        case     .optP(_): return .none
        case let .altP(attempt, fallback):
            return attempt.defaultValue ?? fallback.defaultValue
        case let ._multP(pf, input):
            return pf.defaultValue <*> input.defaultValue
        case let ._bindP(pIn, inToPa):
            return pIn.defaultValue.flatMap{ i in inToPa(i).defaultValue }
        }
    }
}

extension Parser /*: Functor */ {
    public typealias A = Value
    public typealias B = Any
    public typealias FB = Parser<B>
    
    public func fmap<B>(_ f : @escaping (A) -> B) -> Parser<B> {
        switch self {
        case let .nilP(v):
            return .nilP(v.fmap(f))
        case let .optP(opt):
            return .optP(opt.fmap(f))
        case let .altP(attempt, fallback):
            return .altP(
                attempt: attempt.fmap(f),
                fallback: fallback.fmap(f)
            )
        case let ._multP(pf, input):
            return ._multP(
                pf: pf.fmap{ inToA in { i in f(inToA(i)) } },
                input: input
            )
        case let ._bindP(pIn, inToPa):
            return ._bindP(
                pIn: pIn,
                inToPa: { i in inToPa(i).fmap(f) }
            )
        }
    }
    
    static func <^> <B>(_ f : @escaping (A) -> B, p : Parser<A>) -> Parser<B> {
        return p.fmap(f)
    }
}

extension Parser /*: Pointed */ {
    static func pure(_ x: A) -> Parser<Value> {
        return .nilP(.some(x))
    }
}

extension Parser /*: Applicative*/ {
    public typealias FA = Parser<Value>
    public typealias FAB = Parser<(A) -> B>
    
    public func ap<B>(_ f : Parser<(A) -> B>) -> Parser<B> {
        return .multP(
            pf: f,
            input: self
        )
        
    }
    
    static func <*><B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
        return rhs.ap(lhs)
    }
}

extension Parser /*: Alternative*/ {
	static func empty() -> Parser<A> {
        return .nilP(nil)
    }

    func plus(_ b: Parser<A>) -> Parser<A> {
        return .altP(attempt: self, fallback: b)
    }
    
    func many() -> Parser<[A]> {
        return .bindP(
            pIn: optional(),
            inToPa: {
                $0.fmap{ (x: A) -> Parser<[A]> in
                    self.many().fmap{ [x] + $0 }
                } ?? Parser<[A]>.pure([])
            }
        )
    }
 
	static func <|>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
	    return lhs.plus(rhs)
	}
}

// MARK -- Methods

extension Parser {
    func optional() -> Parser<Value?> {
        return self.fmap{ .some($0) } <|> Parser<Value?>.pure(nil)
    }
}
