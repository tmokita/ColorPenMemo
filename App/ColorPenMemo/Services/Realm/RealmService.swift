//
//  RealmService.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2018/01/02.
//  Copyright © 2018年 TOMOHIKO OKITA. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    static var realm: Realm!
    
    static func initialize() {
        RealmService.realm = try! Realm()
    }
    
    static func finalize() {
        RealmService.realm = nil
    }
    
    static func write(obj: Object) {
        try! realm.write {
            realm.add(obj)
        }
    }
    
    static func addHistory(history: DrawingHistory) {
        history.index = RealmService.realm.objects(DrawingHistory.self).count + 1
        RealmService.write(obj: history)
    }
    
    
}
