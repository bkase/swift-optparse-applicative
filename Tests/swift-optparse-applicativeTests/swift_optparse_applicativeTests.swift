import XCTest
@testable import swift_optparse_applicative
import Operadics

struct Sample {
    let hello: String
    let quiet: Bool
}

class swift_optparse_applicativeTests: XCTestCase {
    func testParserCombinatorCompiles() {
        let p: Parser<[String]> = Parser.point(5).many().map{ $0.map{ x in "\(x)" } }
        _ = p
    }
    
    func testDefaultSampleParse() {
        let sampleP: Parser<Sample> =
            curry(Sample.init) <^> .nilP("world") <*> .nilP(true)
        let expected = Sample(hello: "world", quiet: true)
        XCTAssertEqual(sampleP.defaultValue!.hello, expected.hello)
        XCTAssertEqual(sampleP.defaultValue!.quiet, expected.quiet)
    }


    static var allTests = [
        ("testParserCombinatorCompiles", testParserCombinatorCompiles),
    ]
}
