import Foundation
import CocoaLumberjackSwift

public class RuleManager {
    public static var currentManager: RuleManager = RuleManager(fromRules: [], appendDirect: true)

    var rules: [Rule] = []

    init(fromRules rules: [Rule], appendDirect: Bool = false) {
        self.rules = rules

        if appendDirect || self.rules.count == 0 {
            self.rules.append(DirectRule())
        }
    }

    func matchDNS(session: DNSSession, type: DNSSessionMatchType) {
        for (i, rule) in rules[session.indexToMatch..<rules.count].enumerate() {
            let result = rule.matchDNS(session, type: type)
            switch result {
            case .Fake, .Real, .Unknown:
                session.matchedRule = rule
                session.matchResult = result
                session.indexToMatch = i + session.indexToMatch // add the offset
                return
            case .Pass:
                break
            }
        }
    }

    func match(request: ConnectRequest) -> AdapterFactoryProtocol! {
        if request.matchedRule != nil {
            return request.matchedRule!.match(request)
        }

        for rule in rules {
            if let adapterFactory = rule.match(request) {
                DDLogVerbose("Rule \(rule) matches request: \(request)")
                return adapterFactory
            } else {
                DDLogVerbose("Rule \(rule) does not match request: \(request)")
            }
        }
        return nil // this should never happens
    }
}
