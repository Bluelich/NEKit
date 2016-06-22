import Foundation

class AdapterSocket: NSObject, SocketProtocol, RawTCPSocketDelegate {
    var request: ConnectRequest!
    var response: ConnectResponse = ConnectResponse()

    /**
     Connect to remote according to the `ConnectRequest`.

     - parameter request: The connect request.
     */
    func openSocketWithRequest(request: ConnectRequest) {
        self.request = request
        socket.delegate = self
        socket.queue = queue
        state = .Connecting
    }

    // MARK: SocketProtocol Implemention

    /// The underlying TCP socket transmitting data.
    var socket: RawTCPSocketProtocol!

    /// The delegate instance.
    weak var delegate: SocketDelegate?

    /// Every delegate method should be called on this dispatch queue. And every method call and variable access will be called on this queue.
    var queue: dispatch_queue_t! {
        didSet {
            socket?.queue = queue
        }
    }

    /// The current connection status of the socket.
    var state: SocketStatus = .Invalid

    // MARK: RawTCPSocketDelegate Protocol Implemention

    /**
     The socket did disconnect.

     - parameter socket: The socket which did disconnect.
     */
    func didDisconnect(socket: RawTCPSocketProtocol) {
        state = .Closed
        delegate?.didDisconnect(self)
    }

    /**
     The socket did read some data.

     - parameter data:    The data read from the socket.
     - parameter withTag: The tag given when calling the `readData` method.
     - parameter from:    The socket where the data is read from.
     */
    func didReadData(data: NSData, withTag tag: Int, from: RawTCPSocketProtocol) {}

    /**
     The socket did send some data.

     - parameter data:    The data which have been sent to remote (acknowledged). Note this may not be available since the data may be released to save memory.
     - parameter withTag: The tag given when calling the `writeData` method.
     - parameter from:    The socket where the data is sent out.
     */
    func didWriteData(data: NSData?, withTag tag: Int, from: RawTCPSocketProtocol) {}

    /**
     The socket did connect to remote.

     - parameter socket: The connected socket.
     */
    func didConnect(socket: RawTCPSocketProtocol) {
        state = .Established
        delegate?.didConnect(self, withResponse: response)
    }
}
