import Foundation
import CocoaLumberjackSwift

public class DNSSession {
    let requestMessage: DNSMessage
    var requestIPPacket: IPPacket?
    var realIP: IPv4Address?
    var fakeIP: IPv4Address?
    var realResponseMessage: DNSMessage?
    var realResponseIPPacket: IPPacket?
    var matchedRule: Rule?
    var matchResult: DNSSessionMatchResult?
    var indexToMatch = 0
    var expireAt: NSDate?
    lazy var countryCode: String? = {
        [unowned self] in
        guard self.realIP != nil else {
            return nil
        }
        return Utils.GeoIPLookup.Lookup(self.realIP!.presentation)
    }()

    init?(message: DNSMessage) {
        guard message.messageType == .Query else {
            DDLogError("DNSSession can only be initailized by a DNS query.")
            return nil
        }

        guard message.queries.count == 1 else {
            DDLogError("Expecting the DNS query has exact one query entry.")
            return nil
        }

        self.requestMessage = message
    }

    convenience init?(packet: IPPacket) {
        guard let message = DNSMessage(payload: packet.transportSegment.payload) else {
            return nil
        }
        self.init(message: message)
        requestIPPacket = packet
    }
}
