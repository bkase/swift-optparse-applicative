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
struct Opt<A> {
    let main: OptReader<A>
    let metadata: OptProperties<A>
}

/* sealed */ protocol Parser {
    associatedtype A
}
// TODO: How do you make a FuncParser??
protocol FuncParser: Parser {
    associatedtype Input
    associatedtype Output
}
struct NilP<T>: Parser {
    typealias A = T
}
struct OptP<T>: Parser {
    typealias A = Opt<T>
    
    let opt: Opt<T>
}
struct AltP<P1: Parser, P2: Parser>: Parser
    where P1.A == P2.A {
    typealias A = P1.A
    
    let p1: P1
    let p2: P2
}
struct MultP<P1: FuncParser, P2: Parser>: Parser
    where P1.Input == P2.A {
    typealias A = P1.Output
    
    let p1: P1
    let p2: P2
}
struct BindP<P1: Parser, P2: Parser>: Parser {
    typealias A = P2.A
    
    let p1: P1
    let f: (P1.A) -> P2
}
