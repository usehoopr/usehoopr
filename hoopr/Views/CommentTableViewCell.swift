//
//  CommentTableViewCell.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/8/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
import KILabel

protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentLabel: KILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?
    
    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        commentLabel.text = comment?.commentText
        commentLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        commentLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
    }
    
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "profile pic"))
        }
}
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        commentLabel.text = ""
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
    
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
override func prepareForReuse() {
    super.prepareForReuse()
    profileImageView.image = UIImage(named: "profile pic")
}
override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
}
}
