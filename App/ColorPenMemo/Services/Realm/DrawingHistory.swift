//
//  DrawingHistory.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2018/01/02.
//  Copyright © 2018年 TOMOHIKO OKITA. All rights reserved.
//

import Foundation
import RealmSwift

class DrawingHistory: Object {
    @objc dynamic var index: Int = 0
    @objc dynamic var image: Data? = nil
    @objc dynamic var canvasName: String = ""
}
