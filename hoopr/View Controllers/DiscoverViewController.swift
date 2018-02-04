//
//  DiscoverViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/18/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    var kPagination = 20
    let refreshControl = UIRefreshControl()
    
    @IBAction func refreshBtn_touchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        refreshControl.addTarget(self, action: #selector(self.refresh_TouchUpInside), for: UIControlEvents.valueChanged)
        collectionView.refreshControl = refreshControl
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Top Bar1"), for: .default)
        loadTopPosts()
        
    }
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    func loadTopPosts() {
        ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        kPagination = 20
        //  self.collectionView.reloadData()
        Api.Post.observeTopPosts(kPagination: kPagination, loadMore: false) { (post) in
            self.posts.insert(post, at: 0)
            for p in self.posts {
                print(p.likeCount)
            }
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            ProgressHUD.dismiss()
        }
    }
    
    
    func loadMore() {
        if kPagination <= posts.count {
            kPagination += 10
            let postCount = posts.count
            Api.Post.observeTopPosts(kPagination: kPagination, loadMore: true, postCount: postCount, completion: { (post) in
                self.posts.append(post)
                for p in self.posts {
                    print(p.likeCount)
                }
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
                
            })
            //            Api.Post.observeTopPosts { (post) in
            //                self.posts.append(post)
            //                self.collectionView.reloadData()
            //                self.refreshControl.endRefreshing()
            //            }
            //            Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid, kPagination: kPagination, loadMore: true, postCount: postCount) { (post, user) in
            //                self.posts.append(post)
            //                self.collectionView.reloadData()
            //            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}
extension DiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if !posts.isEmpty {
            
            let post = posts[indexPath.row]
            cell.post = post
            
        }
        
        cell.delegate = self
        
        return cell
    }
}


    extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 2
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
        }
    }
extension DiscoverViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
}
    

