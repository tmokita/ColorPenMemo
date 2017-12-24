//
//  CanvasStroke.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

struct CanvasStroke: CanvasDrawProtocol {
    
    var pen: CanvasPen
    var points: [CGPoint]

    func draw(contextRef: CGContext) {
        
        contextRef.setBlendMode(pen.cgBlendMode)
        contextRef.setLineWidth(pen.width)
        contextRef.setStrokeColor(pen.color)

        for (index, point) in points.enumerated() {
            if index == 0 {
                contextRef.move(to: point)
            } else {
                contextRef.addLine(to: point)
            }
        }
        
        contextRef.strokePath()
    }
    
}

