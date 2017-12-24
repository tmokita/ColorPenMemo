//
//  CanvasPen.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

struct CanvasPen {
    
    enum PenType {
        case pen
        case eraser
    }
    
    var type: PenType
    var color: CGColor
    var width: CGFloat
    
    var cgBlendMode: CGBlendMode {
        switch type {
        case .eraser:
            return .clear
        case .pen:
            return .normal
        }
    }

}


