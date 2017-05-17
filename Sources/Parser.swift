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
    
    func map<B>(_ f: @escaping (A) -> B) -> CReader<B> {
        return CReader<B> { s in self.run(s).map(f) }
    }
}

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

/*protocol ParserM {
    associatedtype R
    func run<X>(_ f: (R) -> AnyParserM<X>) -> AnyParserM<X>
}
extension ParserM {
    func flatMap<B>(f: @escaping (R) -> AnyParserM<B>) -> AnyParserM<B> {
        let g = f
        return AnyParserM<B>{ self.run{ x in g(x).run(f) } }
    }
}
struct AnyParserM<T>: ParserM {
    func run<X>(_ f: (R) -> AnyParserM<X>) -> AnyParserM<X> {
        return _run(f) as! AnyParserM<X>
    }

    typealias R = T
    let _run: ((R) -> AnyParserM<Any>) -> AnyParserM<Any>
    
    init<PM: ParserM>(_ parser: PM) where PM.R == R {
        _run = parser.run
    }
    
    init<T>(_ run: @escaping ((T) -> AnyParserM<Any>) -> AnyParserM<Any>) {
        _run = run
    }
}*/

// ----

infix operator <|>: AdditionPrecedence
/* sealed */ protocol Parser {
    associatedtype A
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B>
}
extension Parser {
    func ap<O>(f: AnyParser<(A) -> O>) -> MultP<A, O> {
        return MultP<A, O>(p1: f, p2: AnyParser(self))
    }
    static func point(_ a: A) -> AnyParser<A> {
        return AnyParser<A>(NilP(v: .some(a)))
    }
    static func empty() -> AnyParser<A> {
        return AnyParser<A>(NilP(v: nil))
    }
    static func <|><P2: Parser>(lhs: Self, rhs: P2) -> AltP<Self.A> where P2.A == Self.A {
        return lhs.plus(rhs)
    }
    func plus<P2: Parser>(_ b: P2) -> AltP<Self.A> where Self.A == P2.A {
        return AltP(p1: AnyParser(self), p2: AnyParser(b))
    }
    func many() -> AnyParser<[A]> {
        let f: (A?) -> AnyParser<[A]> = { (x: A?) -> AnyParser<[A]> in
            switch x {
            case .none:
                let p: AnyParser<[A]> = AnyParser<[A]>.point([])
                return p
            case let .some(x):
                let p: AnyParser<[A]> = self.many().map{ [x] + $0 }
                return p
            }
        }
        return AnyParser(BindP<A?, [A]>(
            p1: self.optional(),
            f: f
        ))
    }
    func optional() -> AnyParser<A?> {
        return AnyParser(map{ .some($0) } <|> AnyParser.point(nil))
    }
}
struct AnyParser<T>: Parser {
    typealias A = T
    
    let _map: ((T) -> Any) -> AnyParser<Any>
    
    init<P: Parser>(_ parser: P) where P.A == T {
        _map = parser.map
    }
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        // TODO: How to do this?
        return _map(f) as! AnyParser<B>
    }
}
struct NilP<T>: Parser {
    typealias A = T
    
    let v: A?
    func map<B>(_ f: @escaping (T) -> B) -> AnyParser<B> {
        return AnyParser<B>(NilP<B>(v: v.map(f)))
    }
}
struct OptP<T>: Parser {
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(
            OptP<B>(opt: self.opt.map(f))
        )
    }

    typealias A = T
    
    let opt: Opt<T>
}
struct AltP<T>: Parser {
    typealias A = T
    
    let p1: AnyParser<A>
    let p2: AnyParser<A>
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(AltP<B>(p1: p1.map(f), p2: p2.map(f)))
    }
}
struct MultP<I, O>: Parser {
    typealias A = O
    
    let p1: AnyParser<(I) -> O>
    let p2: AnyParser<I>
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(MultP<I,B>(
            p1: p1.map{ iToO in { i in f(iToO(i)) } },
            p2: p2
        ))
    }
}
struct BindP<I, O>: Parser {
    typealias A = O
    
    let p1: AnyParser<I>
    let f: (I) -> AnyParser<O>
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(BindP<I, B>(
            p1: p1,
            f: { p1a in self.f(p1a).map(f) }
        ))
    }
}
