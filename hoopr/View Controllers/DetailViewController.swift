//
//  DetailViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/21/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var postId = ""
    var post = Post()
    var user = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Top Bar1"), for: .default)
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        loadPost()
    }
    
    func loadPost() {
        Api.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.user = user
            completed()
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Detail_CommentVC" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Detail_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}
extension DetailViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_ProfileSegue", sender: userId)
    }
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Detail_HashTagSegue", sender: tag)
    }
}
