//
//  Parser.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/6/17.
//
//

import Foundation
import Result

enum ParseError: Error {
    case errorMsg(msg: String)
    case infoMsg(msg: String)
    case showHelpText
    case unknownError
}

// TODO: Make sure this is a good enough representation
struct CReader<A> {
    let run: (String) -> Result<A, ParseError>
    
    func map<B>(_ f: @escaping (A) -> B) -> CReader<B> {
        return CReader<B> { s in self.run(s).map(f) }
    }
}

typealias OptName = String
enum OptReader<A> {
    case OptionReader(ns: [OptName], cr: CReader<A>, e: ParseError)
    
    func map<B>(_ f: @escaping (A) -> B) -> OptReader<B> {
        switch self {
        case let .OptionReader(ns: ns, cr: cr, e: e):
            return .OptionReader(ns: ns, cr: cr.map(f), e: e)
        }
    }
}
struct OptProperties {
    let help: String
    let metaVar: String
    let showDefault: String?
}
struct Opt<A> {
    let main: OptReader<A>
    let metadata: OptProperties
    
    func map<B>(_ f: @escaping (A) -> B) -> Opt<B> {
        return Opt<B>(main: main.map(f), metadata: metadata)
    }
}

infix operator <|>: AdditionPrecedence

indirect enum Parser<A> {
    case nilP(A?)
    case optP(Opt<A>)
    case altP(attempt: Parser<A>, fallback: Parser<A>)
    case _multP(pf: Parser<(Any) -> A>, input: Parser<Any>)
    case _bindP(pIn: Parser<Any>, inToPa: (Any) -> Parser<A>)
    
    static func multP<In>(pf: Parser<(In) -> A>, input: Parser<In>) -> Parser<A> {
        return ._multP(
            pf: pf.map{ inToA in
                { any in inToA(any as! In) }
            },
            input: input.map{ $0 as Any }
        )
    }
    
    static func bindP<In>(pIn: Parser<In>, inToPa: @escaping (In) -> Parser<A>) -> Parser<A> {
        return ._bindP(
            pIn: pIn.map{ $0 as Any },
            inToPa: { any in inToPa(any as! In) }
        )
    }
    
    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        switch self {
        case let .nilP(v):
            return .nilP(v.map(f))
        case let .optP(opt):
            return .optP(opt.map(f))
        case let .altP(attempt, fallback):
            return .altP(
                attempt: attempt.map(f),
                fallback: fallback.map(f)
            )
        case let ._multP(pf, input):
            return ._multP(
                pf: pf.map{ inToA in { i in f(inToA(i)) } },
                input: input
            )
        case let ._bindP(pIn, inToPa):
            return ._bindP(
                pIn: pIn,
                inToPa: { i in inToPa(i).map(f) }
            )
        }
    }
}

extension Parser {
    func ap<T>(f: Parser<(A) -> T>) -> Parser<T> {
        return .multP(
            pf: f,
            input: self
        )
    }
    static func point(_ a: A) -> Parser<A> {
        return .nilP(.some(a))
    }
    static func empty() -> Parser<A> {
        return .nilP(nil)
    }
    static func <|>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
        return lhs.plus(rhs)
    }
    func plus(_ b: Parser<A>) -> Parser<A> {
        return .altP(attempt: self, fallback: b)
    }
    func many() -> Parser<[A]> {
        return .bindP(
            pIn: optional(),
            inToPa: {
                $0.map{ x in
                    self.many().map{ [x] + $0 }
                } ?? Parser<[A]>.point([])
            }
        )
    }
    func optional() -> Parser<A?> {
        return map{ .some($0) } <|> Parser<A?>.point(nil)
    }
}

