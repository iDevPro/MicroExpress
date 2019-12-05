// File: Express.swift - create this in Sources/MicroExpress

import Foundation
import NIO
import NIOHTTP1

public enum BindableHost {
    case localhost
    case any
    case ipv4(String)
}

extension BindableHost {
    var host: String {
        switch self {
        case .localhost:
            return "localhost"
        case .any:
            // https://en.wikipedia.org/wiki/0.0.0.0
            return "0.0.0.0"
        case let .ipv4(ip):
            return ip
        }
    }
}

open class Express: Router {

    override public init() {}

    let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

    open func listen(host: BindableHost = .localhost,  port: Int) {

        let reuseAddrOpt = ChannelOptions.socket(
            SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR
        )

        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(
                    withPipeliningAssistance: true,
                    withErrorHandling: true
                ).flatMap {
                    channel.pipeline.addHandler(HTTPHandler(router: self))
                }
        }

        do {
            let serverChannel = try bootstrap
                .bind(host: host.host, port: port)
                .wait()

            print("Server running on:", serverChannel.localAddress!)

            try serverChannel.closeFuture.wait() // runs forever
        }
        catch {
            fatalError("failed to start server: \(error)")
        }
    }

    final class HTTPHandler : ChannelInboundHandler {

        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart

        let router : Router

        init(router: Router) {
            self.router = router
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let reqPart = self.unwrapInboundIn(data)

            switch reqPart {
            case .head(let header):
                let req = IncomingMessage(header: header)
                let res = ServerResponse(channel: context.channel)

                // trigger Router
                router.handle(request: req, response: res) { (items: Any...) in
                    // the final handler
                    res.status = .notFound
                    res.send("No middleware handled the request!")
                }

            // ignore incoming content to keep it micro :-)
            case .body:
                //            case .body(let body):
                break
                //                guard let uint8bytes = body.getBytes(at: 0, length: body.readableBytes) else {
                //                    break
                //                }
                //                let req = IncomingBody(body: Data(bytes: uint8bytes))
                //                let res = ServerResponse(channel: context.channel)
                //
                //                // trigger Router
                //                router.handleBody(request: req, response: res) { (items: Any...) in
                //                    // the final handler
                //                    res.status = .notFound
                //                    res.send("No middleware handled the request!")
                //                }

            case .end:
                break
                //                var buffer = context.channel.allocator.buffer(capacity: 128)
                //                buffer.writeStaticString("received request; waiting 30s then finishing up request\n")
                //                buffer.writeStaticString("press Ctrl+C in the server's terminal or run the following command to initiate server shutdown\n")
                //                buffer.writeString("    kill -INT \(getpid())\n")
                //                context.write(self.wrapOutboundOut(.head(HTTPResponseHead(version: HTTPVersion(major: 1, minor: 1),
                //                                                                          status: .ok))), promise: nil)
                //                context.writeAndFlush(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
                //                buffer.clear()
                //                buffer.writeStaticString("done with the request now\n")
                //                _ = context.eventLoop.scheduleTask(in: .seconds(30)) { [buffer] in
                //                    context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
                //                    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                //                }
            }
        }
    }
}
