import Foundation
import CocoaAsyncSocket
import CocoaLumberjackSwift

/**
 The base proxy server class.

 This proxy does not listen on any port.
 */
public class ProxyServer: NSObject, TunnelDelegate {
    typealias TunnelArray = Atomic<[Tunnel]>

    /// The main proxy.
    ///
    /// There can be arbitrary number of proxies running at the same time. However, it is assumed that there is a main proxy server that handles connections that do not target any proxies but still should be proxied.
    ///
    /// - warning: This must be set before any connection is created.
    public static var mainProxy: ProxyServer!

    /// The port of proxy server.
    public let port: Port

    /// The address of proxy server.
    public let address: IPv4Address

    private var tunnels: TunnelArray = Atomic([])

    /**
     Create an instance of proxy server.

     - parameter address: The address of proxy server.
     - parameter port:    The port of proxy server.
     */
    public init(address: IPv4Address, port: Port) {
        self.address = address
        self.port = port
    }

    /**
     Start the proxy server.

     - throws: The error occured when starting the proxy server.
     */
    public func start() throws {
    }

    /**
     Stop the proxy server.
     */
    public func stop() {
        tunnels.value.removeAll(keepCapacity: true)
    }

    /**
     Delegate method when the proxy server accepts a new ProxySocket from local.

     When implementing a concrete proxy server, e.g., HTTP proxy server, the server should listen on some port and then wrap the raw socket in a corresponding ProxySocket subclass, then call this method.

     - parameter socket: The accepted proxy socket.
     */
    func didAcceptNewSocket(socket: ProxySocket) {
        let tunnel = Tunnel(proxySocket: socket)
        tunnel.delegate = self
        tunnels.value.append(tunnel)
        tunnel.openTunnel()
    }

    // MARK: TunnelDelegate implemention

    /**
     Delegate method when a tunnel closed. The server will remote it internally.

     - parameter tunnel: The closed tunnel.
     */
    func tunnelDidClose(tunnel: Tunnel) {
        tunnels.withBox { tunnels in
            guard let index = tunnels.value.indexOf(tunnel) else {
                // things went strange
                DDLogError("Encountered an unknown tunnel \(tunnel) when tries to remove it.")
                return
            }
            tunnels.value.removeAtIndex(index)
            DDLogVerbose("Removed a closed tunnel, now there are \(tunnels.value.count) tunnels active.")
            DDLogDebug("Current active tunnels: \(tunnels.value)")
        }
    }
}
