//
//  HomeViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 12/30/17.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
import SDWebImage
class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var posts = [Post]()
    var postIdsIndex = [String: Int]()
    var users = [UserModel]()
    var kPagination = 3
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Top Bar1"), for: .default)
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .white
        loadPosts()
    }
    
    @objc func refresh() {
        self.posts.removeAll()
        self.users.removeAll()
        self.kPagination = 3
        loadPosts()
    }
    
    func loadPosts() {
        
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid, kPagination: kPagination, loadMore: false, completion: { (post, user) in
            self.posts.insert(post, at: 0)
            self.users.insert(user, at: 0)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }) { (bool) in
            
        }
        
        //        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid, kPagination: kPagination, loadMore: false) { (post, user) in
        //            self.posts.insert(post, at: 0)
        //            self.users.insert(user, at: 0)
        //            self.tableView.reloadData()
        //            //self.tableView.beginUpdates()
        //
        ////            let index = IndexPath(row: 0, section: 0)
        ////            self.tableView.insertRows(at: [index], with: UITableViewRowAnimation.none)
        ////            self.tableView.endUpdates()
        //            self.refreshControl.endRefreshing()
        //        }) { (bool) in
        //
        //        }
        
        //        Api.Feed.observeNewPost(withId: Api.User.CURRENT_USER!.uid) { (post) in
        //            guard let postUid = post.uid else {
        //                return
        //            }
        //            self.posts.insert(post, at: 0)
        //            self.postIdsIndex["\(post.id!)"] = self.posts.count - 1
        //            self.fetchUser(uid: postUid, postId: post.id!, completed: {
        //                self.tableView.reloadData()
        //            })
        //        }
        
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id! != post.uid }
            self.tableView.reloadData()
        }
    }
    
    func loadMore() {
        if kPagination <= posts.count {
            indicator.startAnimating()
            kPagination += 2
            let postCount = posts.count
            Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid, kPagination: kPagination, loadMore: true, postCount: postCount, completion: { (post, user) in
                self.posts.append(post)
                self.users.append(user)
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }, isHiddenIndicator: { (bool) in
                if let bool = bool {
                    if bool == true {
                        self.indicator.stopAnimating()
                        
                    }
                }
            })
        }
        
    }
    
    //    func fetchUser(uid: String, postId: String, completed:  @escaping () -> Void ) {
    //        var id = postId
    //        Api.User.observeUser(withId: uid, completion: {
    //            user in
    //            for value in self.postIdsIndex {
    //                print("value: \(value)")
    //                print("post\(postId)")
    //                if value.key == id {
    //                    self.users[value.value] = user
    //                }
    //            }
    //
    //            completed()
    //        })
    //
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender  as! String
            hashTagVC.tag = tag
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        if !posts.isEmpty && !users.isEmpty {
            let post = posts[indexPath.row]
            let user = users[indexPath.row]
            cell.user = user
            cell.post = post
            cell.delegate = self
        }
        return cell
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        loadMore()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //  if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
        //      if lastIndex.row >= self.posts.count - 2 {
        //                print(kPagination)
        //                loadMore()
        //      }
        //  }
    }
    
}


extension HomeViewController: HomeTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}

