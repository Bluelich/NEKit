import Foundation

protocol IPAddress: CustomStringConvertible {
    init(fromString: String)
    init(fromBytesInNetworkOrder: [UInt8])
    init(fromBytesInNetworkOrder: UnsafePointer<Void>)

    var dataInNetworkOrder: NSData { get }
}

public class IPv4Address: IPAddress, Hashable {
    var inaddr: UInt32

    public init(fromInAddr: UInt32) {
        inaddr = fromInAddr
    }

    public init(fromUInt32InHostOrder: UInt32) {
        inaddr = NSSwapHostIntToBig(fromUInt32InHostOrder)
    }

    required public init(fromBytesInNetworkOrder: UnsafePointer<Void>) {
        inaddr = UnsafePointer<UInt32>(fromBytesInNetworkOrder).memory
    }

    required public init(fromString: String) {
        var addr: UInt32 = 0
        fromString.withCString {
            inet_pton(AF_INET, $0, &addr)
        }
        inaddr = addr
    }

    required public init(fromBytesInNetworkOrder: [UInt8]) {
        var addr: UInt32 = 0
        fromBytesInNetworkOrder.withUnsafeBufferPointer {
            addr = UnsafePointer<UInt32>($0.baseAddress).memory
        }
        inaddr = addr
    }

    var presentation: String {
        var buffer = [Int8](count: Int(INET_ADDRSTRLEN), repeatedValue: 0)
        let p = inet_ntop(AF_INET, &inaddr, &buffer, UInt32(INET_ADDRSTRLEN))
        return String.fromCString(p)!
    }

    public var description: String {
        return "IPv4 address: \(presentation)"
    }

    public var hashValue: Int {
        return Int(inaddr)
    }

    var UInt32InHostOrder: UInt32 {
        return NSSwapBigIntToHost(inaddr)
    }

    var bytesInNetworkOrder: UnsafePointer<Void> {
        var pointer: UnsafePointer<Void> = nil
        withUnsafePointer(&inaddr) {
            pointer = UnsafePointer<Void>($0)
        }
        return pointer
    }

    var dataInNetworkOrder: NSData {
        return NSData(bytes: bytesInNetworkOrder, length: sizeofValue(inaddr))
    }
}

public func == (left: IPv4Address, right: IPv4Address) -> Bool {
    return left.inaddr == right.inaddr
}
