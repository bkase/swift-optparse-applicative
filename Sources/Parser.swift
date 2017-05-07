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
}

typealias OptName = String
enum OptReader<A> {
    case OptionReader(ns: [OptName], cr: CReader<A>, e: ParseError)
}
struct OptProperties<A> {
    let help: String
    let metaVar: String
    let showDefault: String?
}


/* A shitty approximation of a GADT */
protocol Parser {
    associatedtype Value
}
extension Parser {
    func map<B, PB: Parser>(_ f: (Value) -> B) -> PB
        where PB.Value == B {
            fatalError("This may not be possible?")
        /*if let n = self as? Nil<Value> {
            return Nil<B>(a: n.a.map(f))
        }*/
    }
}
struct Nil<A>: Parser/*<A>*/ {
    typealias Value = A
    let a: A?
}
struct Opt<A>: Parser/*<A>*/ {
    typealias Value = A
    let main: OptReader<A>
    let metadata: OptProperties<A>
}
struct Alt<A, P: Parser>: Parser/*<A>*/ where P.Value == A {
    typealias Value = A
    let p1: P
    let p2: P
}
struct Mult<A, B, PAB: Parser, PA: Parser>: Parser/*<B>*/
    where PAB.Value == (A) -> B, PA.Value == A {
    typealias Value = B
    let p1: PAB
    let p2: PA
}
struct Bind<A, B, PA: Parser, PB: Parser>: Parser/*<B>*/
    where PA.Value == A, PB.Value == B {
    typealias Value = B
    let p: PA
    let f: (A) -> PB
}
