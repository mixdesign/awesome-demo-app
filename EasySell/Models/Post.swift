//
// Created by Almas Adilbek on 12/3/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import RealmSwift

class Post : Object {

    dynamic var postId = ""
    dynamic var title = ""
    dynamic var price:Int = 0
    dynamic var currencySymbol:String = ""
    dynamic var isUrgent:Bool = false
    dynamic var isGiveFree:Bool = false
    dynamic var modifiedDate:Date?
    dynamic var createdDate:Date?
    let photos = List<PostPhoto>()

    override static func primaryKey() -> String? {
        return "postId"
    }

    func formattedPrice() -> String {
        return "\(price.formattedWithSeparator) \(currencySymbol)"
    }

}

extension Post {

    class func nextUniqueId() -> String {
        return UUID().uuidString
    }

    class func deletePost(_ postId:String) {
        let realm = try! Realm()
        if let object = realm.object(ofType: Post.self, forPrimaryKey: postId) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }

}