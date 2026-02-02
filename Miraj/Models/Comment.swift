//
//  Comment.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import Foundation
import ParseSwift

struct Comment: ParseObject {
    // Required ParseObject properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Custom fields
    var text: String?
    var post: Pointer<Post>?
    var user: Pointer<User>?
    var username: String?
}
