//
//  CanvasShape.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

// 画面に描画されるものはすべてこのプロトコルを使う
protocol CanvasDrawProtocol {
    
    func draw(contextRef: CGContext)
    
}

