//
//  Post.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    // Required ParseObject properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Custom fields
    var imageFile: ParseFile?
    var caption: String?
    var user: Pointer<User>?
    var username: String?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var likeCount: Int?
    var likedBy: [String]?  // Array of user objectIds who liked
}
