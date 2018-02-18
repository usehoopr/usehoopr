//
//  HomeTableViewCell.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/6/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
import AVFoundation
import KILabel

protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var seperatorCardView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoContainer: UIImageView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var delegate: HomeTableViewCellDelegate?
    var player: AVPlayer?
    var playLayer: AVPlayerLayer?

    var post: Post? {
        didSet {
            updateView()
        }
    }
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    
    
    
    var isMuted = true
    
   
    
    func updateView() {
        captionLabel.text = post?.caption
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
            self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
       
        if let ratio = post?.ratio {
            heightConstraint.constant = UIScreen.main.bounds.width / ratio
            layoutIfNeeded()
        }
        if let photoUrlString = post?.photoUrl{
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
            
        }
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
            
            print("videoUrlString: \(videoUrlString)")
            self.volumeView.isHidden = false
            player = AVPlayer(url: videoUrl)
            playLayer = AVPlayerLayer(player: player)
            playLayer?.frame = postImageView.frame
            playLayer?.frame.size.width = UIScreen.main.bounds.width
            playLayer?.frame.size.height = UIScreen.main.bounds.width / post!.ratio!
            self.contentView.layer.addSublayer(playLayer!)
            self.volumeView.layer.zPosition = 1
            player?.play()
            player?.isMuted = isMuted
            player?.play()
            
        }
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch {
            print("AVAudioSession cannot be set")
        }
        if let timestamp = post?.timestamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            timeLabel.text = timeText
        }
        

            self.updateLike(post: self.post!)
        
       
    }
    

    @IBAction func volumeBtn_TouchUpInside(_ sender: UIButton) {
        if isMuted {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Volume"), for: UIControlState.normal)
        } else {
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Mute"), for: UIControlState.normal)
            
        }
        player?.isMuted = isMuted
        
    }
    
  
    var isLiked = false
    
    
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        isLiked = (imageName == "like") ? false : true
        likeImageView.image = UIImage(named: imageName)
        guard let count = post.likeCount else {
            return
        }
        if count == 1 {
            likeCountButton.setTitle("\(count) like", for: UIControlState.normal)
        } else if  count != 0 {
            likeCountButton.setTitle("\(count) likes", for: UIControlState.normal)
        }  else {
            likeCountButton.setTitle("Be the first like this", for: UIControlState.normal)
        }
       
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "profile pic"))
        }

    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        _ = backgroundCardView.backgroundColor
        _ = seperatorCardView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            self.backgroundCardView.backgroundColor = UIColor.white
            self.seperatorCardView.backgroundColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 232/255, alpha: 1)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCardView.isUserInteractionEnabled = false
        backgroundCardView.layer.cornerRadius = 3
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOpacity = 0.3
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        seperatorCardView.backgroundColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 232/255, alpha: 1)
        nameLabel.text = ""
        captionLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForlikeImageView = UITapGestureRecognizer(target: self, action:  #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForlikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action:#selector(self.onDoubleTap))
        gesture.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(gesture)
        
        
        
        
//        let tapGestureForVolume = UITapGestureRecognizer(target: self, action:#selector(self.onTapp))
//        tapGestureForVolume.numberOfTapsRequired = 1
//        contentView.addGestureRecognizer(tapGestureForVolume)
        
        
    }
    
    @objc func onTapp() {
        volumeBtn_TouchUpInside(volumeButton)

    }
    
    @objc func onDoubleTap() {
        let likeImg = UIImageView(image: UIImage(named: "likeSelected"))
        likeImg.backgroundColor = .clear
        likeImg.tintColor = .white
        likeImg.frame.size = CGSize(width: 59, height: 81)
        likeImg.center = self.postImageView.center
        likeImg.isHidden = true
        self.addSubview(likeImg)
        
        likeImg.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            likeImg.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (value) in
            likeImg.isHidden = true
        }
        
        
        if !isLiked {
            likeImageView_TouchUpInside()
        }
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    @objc func likeImageView_TouchUpInside() {
        Api.Post.incrementLikes(postId: post!.id!, onSucess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
            
            if post.uid != Api.User.CURRENT_USER?.uid {
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                if post.isLiked! {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child("\(post.id!)-\(Api.User.CURRENT_USER!.uid)")
                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": post.id!, "type": "like", "timestamp": timestamp])
                } else {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child("\(post.id!)-\(Api.User.CURRENT_USER!.uid)")
                    newNotificationReference.removeValue()
                }
                
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
//        incrementLikes(forRef: postRef)
    }
    
    @objc func commentImageView_TouchUpInside() {
         print("commentImageView_TouchUpInside")
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = ""
        volumeView.isHidden = true
        profileImageView.image = UIImage(named: "placeholderImg")
        self.playLayer?.removeFromSuperlayer()
        player?.pause()
        self.volumeView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        _ = backgroundCardView.backgroundColor
        _ = seperatorCardView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            self.backgroundCardView.backgroundColor = UIColor.white
            self.seperatorCardView.backgroundColor = UIColor(displayP3Red: 226/255, green: 228/255, blue: 232/255, alpha: 1)
        }
    }
}

    


