//
//  Post_CommentApi.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/10/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
import FirebaseDatabase
class Post_CommentApi {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    
//        func observePostComments(withPostId id: String, completion: @escaping (Comment) -> Void) {
//            REF_POST_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
//                snapshot in
//                if let dict = snapshot.value as? [String: Any] {
//                    let newComment = Comment.transformComment(dict: dict)
//                    completion(newComment)
//                }
//            })
//        }
//
}

