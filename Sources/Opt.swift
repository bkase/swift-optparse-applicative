//
//  Opt.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/18/17.
//
//

import Foundation

typealias OptName = String
enum OptReader<Value> {
    case OptionReader(ns: [OptName], cr: CReader<Value>, e: ParseError)
}

extension OptReader /*: Functor */ {
    public typealias A = Value
    public typealias B = Any
    public typealias FB = OptReader<B>
    
    func fmap<B>(_ f: @escaping (A) -> B) -> OptReader<B> {
        switch self {
        case let .OptionReader(ns: ns, cr: cr, e: e):
            return .OptionReader(ns: ns, cr: cr.fmap(f), e: e)
        }
    }
}

struct OptProperties {
    let help: String
    let metaVar: String
    let showDefault: String?
}

struct Opt<Value> {
    let main: OptReader<Value>
    let metadata: OptProperties
}

extension Opt /*: Functor*/ {
    public typealias A = Value
    public typealias B = Any
    public typealias FB = Opt<B>

    func fmap<B>(_ f: @escaping (A) -> B) -> Opt<B> {
        return Opt<B>(main: main.fmap(f), metadata: metadata)
    }
}
