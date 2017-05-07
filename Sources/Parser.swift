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

indirect enum Parser<A> {
    case Nil
    case Opt(fa: Opt<A>)
    case Alt(p1: Parser<A>, p2: Parser<A>)
    // TODO: How to represent this?
    /* case Mult<A, U>(p1: Parser<(U) -> A>, p2: Parser<U>)
    case Bind(p: Parser<U>, f: (U) -> Parser<A>) */
}
