
//
//  PostApi.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/10/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.


import Foundation
import FirebaseDatabase
class PostApi {
    var REF_POST = Database.database().reference().child("post")
    
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POST.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
            let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
            completion(newPost)
            }
        }
    }
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POST.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    func observeLikeCount(withPostId id: String, completion: @escaping (Int, UInt) -> Void) {
        var likeHandler: UInt!
        likeHandler = REF_POST.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
                //  FIRDatabase.database().reference().removeObserver(withHandle: ref)
                completion(value, likeHandler)
            }
        })
        
    }
    
    func observeTopPosts(kPagination: Int, loadMore: Bool, postCount: Int? = 0, completion: @escaping (Post) -> Void) {
        REF_POST.queryOrdered(byChild: "likeCount").queryLimited(toLast: UInt(kPagination)).observeSingleEvent(of: .value, with: {
            snapshot in
            var arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            if loadMore {
                if arraySnapshot.count <= postCount! {
                    return
                }
                arraySnapshot.removeLast(postCount!)
            }
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post.transformPostPhoto(dict: dict, key: child.key)
                    completion(post)
                }
            })
        })
    }
    
    func removeObserveLikeCount(id: String, likeHandler: UInt) {
        Api.Post.REF_POST.child(id).removeObserver(withHandle: likeHandler)
    }
    
    func incrementLikes(postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POST.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
    
    
    
}






