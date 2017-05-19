//
//  Opt.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/18/17.
//
//

import Foundation

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
