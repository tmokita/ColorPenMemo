//
//  ViewController.swift
//  CanvasToolbar
//
//  Created by Yuichiro MASUI on 01/01/2018.
//  Copyright (c) 2018 Yuichiro MASUI. All rights reserved.
//

import UIKit
import CanvasToolbar

class ViewController: UIViewController {
    var toolbar:CanvasToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar = CanvasToolbar(colors: [.gray, .red, .blue, .green, .brown, .cyan])
        let middle = Int(UIScreen.main.bounds.height - toolbar.frame.height) / 2
        toolbar.frame = CGRect(origin: CGPoint(x:0, y:middle), size: toolbar.frame.size)
        self.view.addSubview(toolbar)
        // toolbar.redoIsEnabled = false
        // toolbar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

