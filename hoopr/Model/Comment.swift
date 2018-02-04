//
//  Comment.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/8/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
