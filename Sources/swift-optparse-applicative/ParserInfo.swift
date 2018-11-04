//
//  ParserInfo.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/18/17.
//
//

import Foundation
import DoctorPretty
import Operadics
import struct Swiftz.AdjoinNil
import protocol Swiftz.Semigroup

// HACK: Until Swiftz is unified with Algebra, we need to glue it here
extension Doc: Semigroup {
    public func op(_ other: Doc) -> Doc {
        return self <> other
    }
}

struct ParserInfo<A> {
    let parser: Parser<A>
	let fullDesc: Bool
    let progDesc: AdjoinNil<Doc>
    let header: AdjoinNil<Doc>
    let footer: AdjoinNil<Doc>
	let failureCode: Int
    let intersperse: Bool
}

extension ParserInfo /*: Functor */ {
    public func fmap<B>(_ f : @escaping (A) -> B) -> ParserInfo<B> {
        return ParserInfo<B>(parser: parser.fmap(f), fullDesc: fullDesc, progDesc: progDesc, header: header, footer: footer, failureCode: failureCode, intersperse: intersperse)
    }
    
    static func <^> <B>(_ f : @escaping (A) -> B, p : ParserInfo<A>) -> ParserInfo<B> {
        return p.fmap(f)
    }
}

