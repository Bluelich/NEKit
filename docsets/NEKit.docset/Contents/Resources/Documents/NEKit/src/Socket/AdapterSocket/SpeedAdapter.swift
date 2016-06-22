import Foundation

/// This adpater selects the fastest proxy automatically from a set of proxies.
class SpeedAdapter: AdapterSocket, SocketDelegate {
    var adapters: [AdapterSocket]!
    var connectingCount = 0

    override var queue: dispatch_queue_t! {
        didSet {
            for adapter in adapters {
                adapter.queue = queue
            }
        }
    }

    override func openSocketWithRequest(request: ConnectRequest) {
        connectingCount = adapters.count
        for adapter in adapters {
            adapter.delegate = self
            adapter.openSocketWithRequest(request)
        }
    }

    func disconnect() {
        for adapter in adapters {
            adapter.delegate = nil
            adapter.disconnect()
        }
        // no need to wait for anything since this is only called when the other side is closed before we make any successful connection.
        delegate?.didDisconnect(self)
    }

    func forceDisconnect() {
        for adapter in adapters {
            adapter.delegate = nil
            adapter.forceDisconnect()
        }
        delegate?.didDisconnect(self)
    }

    func didConnect(adapterSocket: AdapterSocket, withResponse response: ConnectResponse) {}

    func readyToForward(socket: SocketProtocol) {
        guard let adapterSocket = socket as? AdapterSocket else {
            return
        }
        // first we disconnect all other adapter now, and set delegate to nil
        for adapter in adapters {
            if adapter != adapterSocket {
                adapter.delegate = nil
                adapter.forceDisconnect()
            }
        }

        delegate?.updateAdapter(adapterSocket)
        delegate?.didConnect(adapterSocket, withResponse: adapterSocket.response)
        delegate?.readyToForward(adapterSocket)
    }

    func didDisconnect(socket: SocketProtocol) {
        connectingCount -= 1
        if connectingCount == 0 {
            // failed to connect
            delegate?.didDisconnect(self)
        }
    }


    func didWriteData(data: NSData?, withTag: Int, from: SocketProtocol) {}
    func didReadData(data: NSData, withTag: Int, from: SocketProtocol) {}
    func updateAdapter(newAdapter: AdapterSocket) {}
}
