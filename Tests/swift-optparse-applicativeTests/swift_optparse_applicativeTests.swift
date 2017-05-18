import XCTest
@testable import swift_optparse_applicative

class swift_optparse_applicativeTests: XCTestCase {
    func testParserCombinatorCompiles() {
        let p: Parser<[String]> = Parser.point(5).many().map{ $0.map{ x in "\(x)" } }
        _ = p
    }


    static var allTests = [
        ("testParserCombinatorCompiles", testParserCombinatorCompiles),
    ]
}
