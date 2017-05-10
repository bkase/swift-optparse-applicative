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
    func ap<I, O, PF: Parser>(f: PF) -> MultP<I, O, PF, Self>
            where PF.A == (I) -> O, I == A {
        return MultP<I, O, PF, Self>(p1: f, p2: self)
    }
    static func point(_ a: A) -> AnyParser<A> {
        return AnyParser<A>(NilP(v: .some(a)))
    }
    static func empty() -> AnyParser<A> {
        return AnyParser<A>(NilP(v: nil))
    }
    static func <|><P2: Parser>(lhs: Self, rhs: P2) -> AltP<Self, P2> where Self.A == P2.A {
        return lhs.plus(rhs)
    }
    func plus<P2: Parser>(_ b: P2) -> AltP<Self, P2> where Self.A == P2.A {
        return AltP(p1: self, p2: b)
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
        return BindP<AnyParser<A?>, AnyParser<[A]>>(
            p1: optional(),
            f: f
        )
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
struct AltP<P1: Parser, P2: Parser>: Parser
    where P1.A == P2.A {
    typealias A = P1.A
    
    let p1: P1
    let p2: P2
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(AltP<AnyParser<B>, AnyParser<B>>(p1: p1.map(f), p2: p2.map(f)))
    }
}
struct MultP<I, O, P1: Parser, P2: Parser>: Parser
    where P1.A == (I) -> O, P2.A == I {
    typealias A = O
    
    let p1: P1
    let p2: P2
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(MultP<I,B,AnyParser<(I)->B>,P2>(
            p1: p1.map{ iToO in { i in f(iToO(i)) } },
            p2: p2
        ))
    }
}
struct BindP<P1: Parser, P2: Parser>: Parser {
    typealias A = P2.A
    
    let p1: P1
    let f: (P1.A) -> P2
    
    func map<B>(_ f: @escaping (A) -> B) -> AnyParser<B> {
        return AnyParser<B>(BindP<P1, AnyParser<B>>(
            p1: p1,
            f: { p1a in self.f(p1a).map(f) }
        ))
    }
}
