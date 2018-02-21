//
//  ViewController.swift
//  CanvasToolbar
//
//  Created by Yuichiro MASUI on 01/01/2018.
//  Copyright (c) 2018 Yuichiro MASUI. All rights reserved.
//

import UIKit
import CanvasToolbar
import PKHUD

class ViewController: UIViewController, CanvasToolbarDelegate {
    var toolbar:CanvasToolbar!
    @IBOutlet var HUDswitch:UISwitch?
    @IBOutlet var undoswitch:UISwitch?
    @IBOutlet var redoswitch:UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar = CanvasToolbar(colors: [.gray, .red, .blue, .green, .brown, .cyan])
        toolbar.delegate = self
        
        toolbar.frame = CGRect(origin: CGPoint(x:0, y: toolbar.middleOf(height: Double(self.view.frame.size.height))), size: toolbar.frame.size)
        self.view.addSubview(toolbar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didChangeSwitch(_ sender:AnyObject) {
        toolbar.undoIsEnabled = undoswitch?.isOn ?? true
        toolbar.redoIsEnabled = redoswitch?.isOn ?? true
    }
    
    func log(_ message:String) {
        if HUDswitch?.isOn ?? true {
            HUD.flash(.label(message), delay: 0.5)
        }
    }

    func didChangePenState(penState: CanvasToolbar.PenState) {
        log("Pen: \(penState)")
    }
    
    func didChangeColor(colorIndex: Int) {
        log("Color: \(colorIndex)")
    }
    
    func didChangeActiveColors(activeColors: [Bool]) {
        log("Changed: ActiveColors")
    }
    
    func didChangeDrawWeight(weight: CanvasToolbar.DrawWeight) {
        log("Weight: \(weight)")
    }
    
    func didPressUndo() {
        log("Undo")
    }
    
    func didPressRedo() {
        log("Redo")
    }
    
    func didPressCamera() {
        log("Camera")
    }
    
    func didPressImageLibrary() {
        log("Image Library")
    }
    
    func didPressClearImage() {
        log("ClearImage")
    }
    
    func didPressSetting() {
        log("Setting")
    }
    
    func didPressExport() {
        log("Export")
    }
    
    func didPressExit() {
        log("Exit")
    }
    
    func didShowToolbar() {
        log("Show toolbar")
    }
    
    func didHideToolbar() {
        log("Hide toolbar")
    }
}

