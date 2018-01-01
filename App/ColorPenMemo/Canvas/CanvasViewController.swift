//
//  CanvasViewController.swift
//  ColorPenMemo
//
//  Created by TOMOHIKO OKITA on 2017/12/30.
//  Copyright © 2017年 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

struct CanvasSet {
    var canvas: CanvasView
    var pen: CanvasPen
    var eraserPen: CanvasPen
}

class CanvasViewController: UIViewController {
    
    var canvases: [CanvasSet] = []
    var currentSet: CanvasSet! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvasSet()
    }

    private func setupCanvasSet() {
        addNewCanvas(pen: CanvasPen(type: .pen, color: UIColor.red.withAlphaComponent(0.33).cgColor, width: 5),
                     eraserPen: CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
        
        addNewCanvas(pen: CanvasPen(type: .pen, color: UIColor.green.withAlphaComponent(0.33).cgColor, width: 5),
                     eraserPen: CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
        
        addNewCanvas(pen: CanvasPen(type: .pen, color: UIColor.blue.withAlphaComponent(0.33).cgColor, width: 5),
                     eraserPen: CanvasPen(type: .eraser, color: view.backgroundColor!.cgColor, width: 15))
    }
    
    private func addNewCanvas(pen: CanvasPen, eraserPen: CanvasPen) {
        let canvas = CanvasView()
        view.addSubview(canvas)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        canvas.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        canvases.append(CanvasSet(canvas: canvas, pen: pen, eraserPen: eraserPen))
    }
    
    private func selectCanvas(index: Int) -> CanvasSet {
        return canvases[index]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        
        
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
        
        if let image = selectedCanvas.rasterizeImage(),
            let data = UIImagePNGRepresentation(image) {
            let documentsPath = NSHomeDirectory() + "/Documents"
            let imagePath = documentsPath + "/\(Date().timeIntervalSince1970).png"
            let url = URL(fileURLWithPath: imagePath)
            print("imagePath = \(imagePath)")
            try! data.write(to: url)
        }
        
        updateUndoRedoButton()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
