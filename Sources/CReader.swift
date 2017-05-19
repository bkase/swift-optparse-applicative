//
//  CReader.swift
//  swift-optparse-applicative
//
//  Created by Brandon Kase on 5/18/17.
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
