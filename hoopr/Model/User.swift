//
//  User.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/7/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import Foundation
class UserModel {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        return user
    }
}
