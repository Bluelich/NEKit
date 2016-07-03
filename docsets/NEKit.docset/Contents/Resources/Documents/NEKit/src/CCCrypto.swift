import Foundation
import CommonCrypto

class CCCrypto: StreamCryptoProtocol {
    enum Algorithm {
        case AES, CAST, RC4

        func toCCAlgorithm() -> CCAlgorithm {
            switch self {
            case .AES:
                return CCAlgorithm(kCCAlgorithmAES)
            case .RC4:
                return CCAlgorithm(kCCAlgorithmRC4)
            case .CAST:
                return CCAlgorithm(kCCAlgorithmCAST)
            }
        }
    }

    enum Mode {
        case CFB, RC4

        func toCCMode() -> CCMode {
            switch self {
            case .CFB:
                return CCMode(kCCModeCFB)
            case .RC4:
                return CCMode(kCCModeRC4)
            }
        }
    }

    let cryptor: CCCryptorRef

    init(operation: CryptoOperation, mode: Mode, algorithm: Algorithm, initialVector: NSData?, key: NSData) {
        let cryptor = UnsafeMutablePointer<CCCryptorRef>.alloc(1)
        CCCryptorCreateWithMode(operation.toCCOperation(), mode.toCCMode(), algorithm.toCCAlgorithm(), CCPadding(ccNoPadding), initialVector?.bytes ?? nil, key.bytes, key.length, nil, 0, 0, 0, cryptor)
        self.cryptor = cryptor.memory
    }

    func update(data: NSData) -> NSData {
        let outData = NSMutableData(length: data.length)!
        CCCryptorUpdate(cryptor, data.bytes, data.length, outData.mutableBytes, outData.length, nil)
        return NSData(data: outData)
    }

    deinit {
        CCCryptorRelease(cryptor)
    }

}
