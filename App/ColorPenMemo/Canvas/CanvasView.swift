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
    var undoObjects: [CanvasDrawProtocol] = []
    
    override func draw(_ rect: CGRect) {
        if let contextRef = UIGraphicsGetCurrentContext() {
            for obj in drawObjects {
                obj.draw(contextRef: contextRef)
            }
        }
    }
    
    func undo() {
        if let obj = drawObjects.last {
            undoObjects.append(obj)
            drawObjects.removeLast()
            setNeedsDisplay()
        }
    }
    
    func redo() {
        if let obj = undoObjects.last {
            drawObjects.append(obj)
            undoObjects.removeLast()
            setNeedsDisplay()
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
    
    func rasterizeImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }

}
