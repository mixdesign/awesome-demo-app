//
//  RealmHelper.swift
//  Easy Sell
//
//  Created by Almas Adilbek on 11/29/16.
//  Copyright © 2017 Good App. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {

    static let version:UInt64 = 1

    class func setup() {
        performMigration()

        var configuration = Realm.Configuration()
        configuration.schemaVersion = version

        if Constants.kDEBUG, let path = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString {
            print("\((path as String).replacingOccurrences(of: "file://", with: ""))")
        }

    }

    private class func performMigration() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration( schemaVersion: version, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < version) {
            }
        })
    }

    class func refresh() {
        let realm = try! Realm()
        realm.refresh()
    }
}
