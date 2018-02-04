//
//  HelperService.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/15/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, caption: caption, ratio: ratio, onSuccess: onSuccess)
                })
            })
            //self.senddatatodatabase
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, caption: caption, ratio: ratio, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("post").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(videoUrl)
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("post").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(photoUrl)
            }
        }
    }
    
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, caption: String, ratio: CGFloat, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POST.childByAutoId().key
        let newPostReference = Api.Post.REF_POST.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId: true])
            }
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        print(timestamp)
        
        var dict = ["uid": currentUserId ,"photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(["timestamp": timestamp])
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    print(child.key)
                    Api.Feed.REF_FEED.child(child.key).child("\(newPostId)").setValue(["timestamp": timestamp])
                    let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId)
                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
                })
            })
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
}
