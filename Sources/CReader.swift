//
//  CReader.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/18/17.
//
//

import Foundation
import enum Swiftx.Either
import Swiftz

enum ParseError: Error {
    case errorMsg(msg: String)
    case infoMsg(msg: String)
    case showHelpText
    case unknownError
}

// TODO: Make sure this is a good enough representation
struct CReader<Value> {
    let run: (String) -> Either<ParseError, A>
}

extension CReader {
    public typealias A = Value
    public typealias B = Any
    public typealias FB = OptReader<B>
    
    func fmap<B>(_ f: @escaping (A) -> B) -> CReader<B> {
        return CReader<B> { s in self.run(s).fmap(f) }
    }
}
