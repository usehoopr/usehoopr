//
//  FeedApi.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/17/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedApi {
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeNewPost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).queryLimited(toLast: 1).observe(.childAdded, with: {
            snapshot in
            Api.Post.observePost(withId: snapshot.key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func observeFeed(withId id: String, kPagination: Int, loadMore: Bool, postCount: Int? = 0, completion: @escaping (Post, UserModel) -> Void, isHiddenIndicator:  @escaping (_ isHiddenIndicator: Bool?) -> Void) {
        
        let query = REF_FEED.child(id).queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(kPagination))
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            var items = snapshot.children.allObjects
            print(items)
            if loadMore {
                print("cont Post \(String(describing: postCount)) and \(items.count)")
                if items.count <= postCount! {
                    isHiddenIndicator(true)
                    return
                }
                items.removeLast(postCount!)
            }
            let myGroup = DispatchGroup()
            var results = Array(repeating: (Post(), UserModel()), count: items.count)
            for (index, item) in (items as! [DataSnapshot]).enumerated() {
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.uid!, completion: { (user) in
                        print("Finished request \(item)")
                        print("\(String(describing: user.id))")
                        results[index] = (post, user)
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: .main) {
                for result in results {
                    completion(result.0, result.1)
                }
                print("Finished all requests.")
            }
            //            for result in results {
            //                completion(result.0, result.1)
            //            }
        })
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
