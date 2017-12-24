//
//  CanvasView.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    var drawObjects: [CanvasDrawProtocol] = []
    
    override func draw(_ rect: CGRect) {
        if let contextRef = UIGraphicsGetCurrentContext() {
            for obj in drawObjects {
                obj.draw(contextRef: contextRef)
            }
        }
    }
    
    func drawLayer(stroke: CanvasStroke) {
        
        clearLayer()
        
        // 差分更新だけしたいが交差点が濃くなってしまうので全部描画する
        let uiPath = UIBezierPath()
        for (index, point) in  stroke.points.enumerated() {
            if index == 0 {
                uiPath.move(to: point)
            } else {
                uiPath.addLine(to: point)
            }
        }
        
        let shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer.strokeColor = stroke.pen.color
        shapeLayer.lineWidth = stroke.pen.width
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = uiPath.cgPath
        
        layer.addSublayer(shapeLayer)
    }
    
    func clearLayer() {
        layer.sublayers = nil
    }

}
