//
// Created by Almas Adilbek on 12/1/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor
import RealmSwift

struct DesignPostViewModel {

    // UI
    let padding:CGFloat = 20
    let noPhotoBackgroundColor = UIColor(hexString: "F1F1F3")
    let withPhotoBackgroundColor = UIColor(hexString: "FFF")


    func createPost(postId:String?, title:String, price:Int, currency:String, photos:[UIImage], isUrgent:Bool, isGiveFree:Bool, result:@escaping (Error?)->()) {
        DispatchQueue.global().async {

            let realm = try! Realm()
            do {
                try realm.write {
                    let post = Post()
                    let id = postId ?? Post.nextUniqueId()
                    post.postId = id
                    post.title = title
                    post.price = price
                    post.currencySymbol = currency
                    post.isUrgent = isUrgent
                    post.isGiveFree = isGiveFree

                    if postId == nil {
                        post.createdDate = Date()
                    } else {
                        post.modifiedDate = Date()
                    }

                    // Add photos
                    post.photos.append(objectsIn:photos.map { image -> PostPhoto in
                        let photo = PostPhoto()
                        photo.postId = id
                        photo.photoData = UIImageJPEGRepresentation(image, 1.0)
                        return photo
                    })

                    realm.add(post, update: true)
                }

                DispatchQueue.main.async(execute: {
                    result(nil)
                })

            } catch {
                DispatchQueue.main.async(execute: {
                    result(self.error(description: "Can not create & save realm object."))
                })
            }
        }
    }

    private func error(description:String) -> NSError {
        let userInfo: [AnyHashable : Any] = [
                    NSLocalizedDescriptionKey : description ,
                    NSLocalizedFailureReasonErrorKey : description
                ]
        return NSError(domain: "", code: 0, userInfo: userInfo)
    }

}