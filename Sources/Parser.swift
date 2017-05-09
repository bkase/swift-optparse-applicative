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

protocol Parser {
    associatedtype A
}
enum UnusedParser<T>: Parser { typealias A = T }
protocol FuncParser: Parser {
    associatedtype Input
    associatedtype Output
}
enum UnusedFuncParser<T>: FuncParser {
    typealias A = (T) -> T

    typealias Input = T
    typealias Output = T
}
indirect enum ConcParser<T, P: Parser, F: FuncParser, U: Parser>: Parser
        where P.A == T, F.Output == T, F.Input == U.A {
    typealias A = T
    
    case nilP
    case OptP(Opt<A>)
    case AltP(primary: P, fallback: P)
    case MultP(f: F, u: U)
    // TODO: How to represent this?
    /* case Bind(p: Parser<U>, f: (U) -> Parser<A>) */
    
    static func Nil<A>() -> ConcParser<A, UnusedParser<A>, UnusedFuncParser<A>, UnusedParser<A>> {
        return .nilP
    }
}
