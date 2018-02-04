//
//  Message.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/31/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
class Message {
    var messageText: String?
    var uid: String?
    var timestamp: Int?
    var id: String?
}

extension Message {
    static func transformMessage(dict: [String: Any]) -> Message {
        let message = Message()
        message.messageText = dict["messageText"] as? String
        message.uid = dict["uid"] as? String
        message.timestamp = dict["timestamp"] as? Int
        return message
    }
}

