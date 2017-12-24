//
//  ViewController.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/24.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var penSelectSegment: UISegmentedControl!
    @IBOutlet weak var redView: CanvasView!
    @IBOutlet weak var greenView: CanvasView!
    @IBOutlet weak var blueView: CanvasView!
    
    var targetCanvas: CanvasView! = nil
    var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
    var currentPen: CanvasPen!
    var currentStroke: CanvasStroke!
    
    var pens: [CanvasPen] = []
    var canvases: [CanvasView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setup() {
        view.backgroundColor = UIColor.white
        redView.isUserInteractionEnabled = false
        greenView.isUserInteractionEnabled = false
        blueView.isUserInteractionEnabled = false
        
        setupCanvases()
        setupPens()
        
        currentPen = pens[0]
        targetCanvas = redView
    }
    
    private func setupCanvases() {
        canvases.append(redView)
        canvases.append(greenView)
        canvases.append(blueView)
        canvases.append(redView)
        canvases.append(greenView)
        canvases.append(blueView)
    }
    
    private func setupPens() {
        pens.append(CanvasPen(type: .pen, color: UIColor.red.withAlphaComponent(0.33).cgColor, width: 5))
        pens.append(CanvasPen(type: .pen, color: UIColor.green.withAlphaComponent(0.33).cgColor, width: 5))
        pens.append(CanvasPen(type: .pen, color: UIColor.blue.withAlphaComponent(0.33).cgColor, width: 5))
        pens.append(CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
        pens.append(CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
        pens.append(CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
    }
    
    @IBAction func onColorSelected(_ sender: UISegmentedControl) {
        currentPen = pens[sender.selectedSegmentIndex]
        targetCanvas = canvases[sender.selectedSegmentIndex]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        view.sendSubview(toBack: targetCanvas)
        lastPoint = touch.location(in: targetCanvas)
        currentStroke = CanvasStroke(pen: currentPen, points: [lastPoint])
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let point = touch.location(in: targetCanvas)
        currentStroke.points.append(point)
        targetCanvas.drawLayer(stroke: currentStroke)
        
        lastPoint = point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        targetCanvas.drawObjects.append(currentStroke)
        targetCanvas.clearLayer()
        targetCanvas.setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

}

