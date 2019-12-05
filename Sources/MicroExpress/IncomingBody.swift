//
//  IncomingBody.swift
//  
//
//  Created by Pavel Subach on 30.11.2019.
//

import Foundation
import NIOHTTP1

open class IncomingBody {

    // MARK: - Properties

    public let body: Data?
    public var userInfo: [String: Any ] = [:]

    // MARK: - Initialization

    init(body: Data?) {
        self.body = body
    }
}
