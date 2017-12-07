//
// Created by Almas Adilbek on 12/3/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import RealmSwift

struct PostsViewModel {

    var posts:Results<Post>!

    init() {
        let realm = try! Realm()
        posts = realm.objects(Post.self).sorted(byKeyPath: "modifiedDate", ascending: false)
    }

}


