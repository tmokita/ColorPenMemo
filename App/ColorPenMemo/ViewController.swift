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
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    
    var targetCanvasStack: [CanvasView] = []
    var targetCanvasIndex: Int = -1
    
    var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    var selectedPen: CanvasPen!
    var selectedCanvas: CanvasView!
    var drawingStroke: CanvasStroke!
    
    var pens: [CanvasPen] = []
    var canvases: [CanvasView] = []
    
    var toolbar:CanvasToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        toolbar = CanvasToolbar(colors: [UIColor.gray, UIColor.red, UIColor.blue, UIColor.green, UIColor.brown, UIColor.cyan])
        let middle = Int(UIScreen.main.bounds.height - toolbar.frame.height) / 2
        toolbar.frame = CGRect(origin: CGPoint(x:0, y:middle), size: toolbar.frame.size)
        self.view.addSubview(toolbar)
        // toolbar.redoIsEnabled = false
        // toolbar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func pushTargetCanvas(canvas: CanvasView) {
        targetCanvasStack.append(canvas)
        targetCanvasIndex += 1
    }
    
    private func shrinkTargetCanvas() {
        let diffCount = targetCanvasStack.count - (targetCanvasIndex+1)
        
        if diffCount == 0 {
            return
        }
        
        targetCanvasStack.removeLast(diffCount)
    }
    
    private func currentCanvas() -> CanvasView? {
        if targetCanvasIndex >= 0 {
            return targetCanvasStack[targetCanvasIndex]
        } else {
            return nil
        }
    }
    
    private func prevCanvas() -> CanvasView? {
        if targetCanvasIndex >= 0 {
            targetCanvasIndex -= 1
            if targetCanvasIndex >= 0 {
                return targetCanvasStack[targetCanvasIndex]
            }
        }
        return nil
    }

    private func nextCanvas() -> CanvasView? {
        if targetCanvasIndex < targetCanvasStack.count-1 {
            targetCanvasIndex += 1
            return targetCanvasStack[targetCanvasIndex]
        }
        return nil
    }
    
    private func canUndo() -> Bool {
        return targetCanvasIndex >= 0
    }
    
    private func canRedo() -> Bool {
        let diffCount = targetCanvasStack.count - (targetCanvasIndex+1)
        return diffCount > 0
    }
    
    private func updateUndoRedoButton() {
        undoButton.isEnabled = canUndo()
        redoButton.isEnabled = canRedo()
    }
    
    private func setup() {
        view.backgroundColor = UIColor.white
        redView.isUserInteractionEnabled = false
        greenView.isUserInteractionEnabled = false
        blueView.isUserInteractionEnabled = false
        
        setupCanvases()
        setupPens()
        
        selectedPen = pens[0]
        selectedCanvas = canvases[0]
        
        updateUndoRedoButton()
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
        selectedPen = pens[sender.selectedSegmentIndex]
        selectedCanvas = canvases[sender.selectedSegmentIndex]
    }
    
    @IBAction func onUndo(_ sender: Any) {
        if let canvas = currentCanvas() {
            canvas.undo()
        }
        let _ = prevCanvas()
        updateUndoRedoButton()
    }
    
    @IBAction func onRedo(_ sender: Any) {
        if let canvas = nextCanvas() {
            canvas.redo()
        }
        updateUndoRedoButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        shrinkTargetCanvas()
        
        pushTargetCanvas(canvas: selectedCanvas)
        view.sendSubview(toBack: selectedCanvas)
        lastPoint = touch.location(in: selectedCanvas)
        drawingStroke = CanvasStroke(pen: selectedPen, points: [lastPoint])
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let point = touch.location(in: targetCanvasStack.last)
        drawingStroke.points.append(point)

        selectedCanvas.drawLayer(stroke: drawingStroke)
        
        lastPoint = point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        selectedCanvas.drawObjects.append(drawingStroke)
        selectedCanvas.clearLayer()
        selectedCanvas.setNeedsDisplay()
        
        updateUndoRedoButton()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

}

