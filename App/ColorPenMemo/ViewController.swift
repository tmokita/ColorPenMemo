//
//  ViewController.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum PenMode: Int {
        case redPen = 0
        case greenPen
        case bluePen
        case redEraser
        case greenEraser
        case blueEraser
        
        var isEraser: Bool {
            switch self {
            case .redPen:       return false
            case .greenPen:     return false
            case .bluePen:      return false
            case .redEraser:    return true
            case .greenEraser:  return true
            case .blueEraser:   return true
            }
        }
        
        var color: UIColor {
            switch self {
            case .redPen:       return UIColor.red.withAlphaComponent(0.3)
            case .greenPen:     return UIColor.green.withAlphaComponent(0.3)
            case .bluePen:      return UIColor.blue.withAlphaComponent(0.3)
            case .redEraser:    return UIColor.white
            case .greenEraser:  return UIColor.white
            case .blueEraser:   return UIColor.white
            }
        }
        
        var width: CGFloat {
            switch self {
            case .redPen:       return 5
            case .greenPen:     return 5
            case .bluePen:      return 5
            case .redEraser:    return 15
            case .greenEraser:  return 15
            case .blueEraser:   return 15
            }
        }
        
    }

    @IBOutlet weak var penSelectSegment: UISegmentedControl!
    @IBOutlet weak var redView: CanvasView!
    @IBOutlet weak var greenView: CanvasView!
    @IBOutlet weak var blueView: CanvasView!
    
    var selectedView: CanvasView! = nil
    var startPoint: CGPoint = CGPoint(x: 0, y: 0)
    var endPoint: CGPoint = CGPoint(x: 0, y: 0)
    var selectedPen: PenMode = .redPen

    override func viewDidLoad() {
        super.viewDidLoad()
        redView.isUserInteractionEnabled = false
        greenView.isUserInteractionEnabled = false
        blueView.isUserInteractionEnabled = false
        
        selectedPen = .redPen
        selectedView = redView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onColorSelected(_ sender: UISegmentedControl) {
        selectedPen = PenMode(rawValue: sender.selectedSegmentIndex)!
        switch selectedPen {
        case .redPen:       selectedView = redView
        case .greenPen:     selectedView = greenView
        case .bluePen:      selectedView = blueView
        case .redEraser:    selectedView = redView
        case .greenEraser:  selectedView = greenView
        case .blueEraser:   selectedView = blueView
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        startPoint = touch.location(in: selectedView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        endPoint = touch.location(in: selectedView)
        
        let color = selectedPen.isEraser ? view.backgroundColor! : selectedPen.color
        let line = CanvasLine(start: startPoint,
                              end: endPoint,
                              isErase: selectedPen.isEraser,
                              width: selectedPen.width,
                              color: color)
        
        selectedView.lines.append(line)
        
        view.sendSubview(toBack: selectedView)
        
        let uiPath = UIBezierPath()
        uiPath.move(to: startPoint)
        uiPath.addLine(to: endPoint)

        let shapeLayer = CAShapeLayer(layer: selectedView.layer)
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = selectedPen.width
        shapeLayer.path = uiPath.cgPath
        selectedView.layer.addSublayer(shapeLayer)

        startPoint = endPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        selectedView.layer.sublayers = nil
        selectedView.setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

}

