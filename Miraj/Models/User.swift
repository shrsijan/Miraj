//
//  User.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    // Required ParseUser properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Required ParseUser fields
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    
    // Custom fields
    var lastPostedAt: Date?
}
