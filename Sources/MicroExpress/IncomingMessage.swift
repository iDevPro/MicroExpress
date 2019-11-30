// File: IncomingMessage.swift - create this in Sources/MicroExpress

import NIOHTTP1

open class IncomingMessage {

    // MARK: - Properties

    public let header: HTTPRequestHead
    public var userInfo = [String: Any ]()

    // MARK: - Initialization

    init(header: HTTPRequestHead) {
        self.header = header
    }
}

