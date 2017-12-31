//
//  CanvasToolbarRadioButtons.swift
//  ColorPenMemo
//
//  Created by Yuichiro MASUI on 2017/12/30.
//  Copyright © 2017 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

protocol CanvasToolbarRadioButtonsProtocol {
    func didChangeSubmenuValue(sender: CanvasToolbarRadioButtons)
}

class CanvasToolbarRadioButtons: UIView {
    var delegate:CanvasToolbarRadioButtonsProtocol?
    
    var name:String?
    var buttons:[UIButton] = []
    let images:[String]
    var value:String = "" {
        didSet(oldValue) {
            for button in buttons {
                button.isSelected = (value == button.accessibilityValue)
            }
            if oldValue != value {
                delegate?.didChangeSubmenuValue(sender:self)
            }
        }
    }
    
    init(origin:CGPoint, images:[String]) {
        self.images = images
        super.init(frame: CGRect(origin: origin, size: CGSize.zero))
        createButtons()
    }
    
    private func createButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        self.frame = CGRect(origin: self.frame.origin, size: CGSize.zero)
        buttons = []
        for image in images {
            addButton(name:image)
        }
    }
    
    private func addButton(name:String) {
        let activeImg = UIImage(named: name + "Active")!
        let deactiveImg = UIImage(named: name + "Deactive")!

        let x = self.frame.width
        let btn = UIButton(frame: CGRect(origin: CGPoint(x: x, y: 0), size: activeImg.size))
        btn.accessibilityValue = name

        btn.setImage(deactiveImg, for: .normal)
        btn.setImage(activeImg, for: .selected)
        btn.setImage(activeImg, for: .highlighted)
        
        btn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        self.frame = CGRect(
            origin: self.frame.origin,
            size: CGSize(
                width: self.frame.width + btn.frame.width,
                height: max(self.frame.height, btn.frame.height)
            )
        )
        
        addSubview(btn)
        buttons.append(btn)
    }
    // frame外のsubviewもtapできる様にする
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        return false
    }
    
    @objc func didTapButton(sender: AnyObject) {
        guard let btn = sender as? UIButton else { return }
        guard let value = btn.accessibilityValue else { return }
        self.value = value
    }
    
    // UIViewを継承したクラスには必要?
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
