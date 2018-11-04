//
//  ParserHelp.swift
//  Operadics
//
//  Created by Brandon Kase on 6/7/17.
//

import Foundation
import DoctorPretty
import Operadics
import struct Swiftz.AdjoinNil
import protocol Swiftz.Monoid
import Swiftz

struct ParserHelp {
    let error: AdjoinNil<Doc>
    let header: AdjoinNil<Doc>
    let usage: AdjoinNil<Doc>
    let body: AdjoinNil<Doc>
    let footer: AdjoinNil<Doc>
    
    func helpText() -> Doc {
        return [error, header, usage, body, footer].vsep().value() ?? Doc.empty
    }
}

extension ParserHelp: Monoid {
    static var mempty: ParserHelp {
        return ParserHelp(
            error: AdjoinNil.mempty,
            header: AdjoinNil.mempty,
            usage: AdjoinNil.mempty,
            body: AdjoinNil.mempty,
            footer: AdjoinNil.mempty
        )
    }
    
    func op(_ other: ParserHelp) -> ParserHelp {
        return ParserHelp(
            error: self.error <> other.error,
            header: self.header <> other.header,
            usage: self.usage <> other.usage,
            body: self.body <> other.body,
            footer: self.footer <> other.footer
        )
    }
}
