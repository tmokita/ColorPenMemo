//
//  CanvasView.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit


struct CanvasLine {
    var start: CGPoint
    var end: CGPoint
    var isErase: Bool
    var width: CGFloat
    var color: UIColor
    
    var blendMode: CGBlendMode {
        return isErase ? .clear : .normal
    }
    
}

class CanvasView: UIView {
    
    var lines: [CanvasLine] = []
    
    override func draw(_ rect: CGRect) {
        
        if let contextRef = UIGraphicsGetCurrentContext() {

            for (index, line) in lines.enumerated() {
                if index == 0 {
                    continue
                }
                
                contextRef.setBlendMode(line.blendMode)
                contextRef.setLineWidth(line.width)
                contextRef.setStrokeColor(line.color.cgColor)
                contextRef.move(to: line.start)
                contextRef.addLine(to: line.end)
                contextRef.strokePath()
            }
        }
        
    }

}
