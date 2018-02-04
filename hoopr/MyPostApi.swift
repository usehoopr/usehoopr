//
//  MyPostApi.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/15/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
import FirebaseDatabase
class MyPostsApi {
    var REF_MYPOSTS = Database.database().reference().child("myPosts")
    
    func fetchMyPost(userId: String, completion: @escaping (String) -> Void) {
        REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPOSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
