//
//  Message.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/31/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
import FirebaseDatabase
class MessageApi {
    var REF_MESSAGES = Database.database().reference().child("messages")
    
    func observeMessages(withPostId id: String, completion: @escaping (Message) -> Void) {
        REF_MESSAGES.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newMessage = Message.transformMessage(dict: dict)
                completion(newMessage)
            }
        })
    }
    
}

