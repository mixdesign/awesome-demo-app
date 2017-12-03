//
// Created by Almas Adilbek on 12/3/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import RealmSwift

class Post : Object {

    dynamic var postId = ""
    dynamic var title = ""
    dynamic var price:Int = 0
    dynamic var isUrgent:Bool = false
    dynamic var isGiveFree:Bool = false
    dynamic var modifiedDate:Date?
    dynamic var createdDate:Date?
    let photos = List<PostPhoto>()

    override static func primaryKey() -> String? {
        return "postId"
    }

}