import Operadics

struct Sample {
    let hello: String
    let quiet: Bool
}

struct swift_optparse_applicative {

    var text = "Hello, World!"
    
    func foo() {
        let p: Parser<Sample> =
            curry(Sample.init) <^> .nilP("world") <*> .nilP(true)
    }
}
