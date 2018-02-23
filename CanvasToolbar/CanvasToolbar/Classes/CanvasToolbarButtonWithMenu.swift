//
//  CanvasToolbarButtonWithMenu.swift
//  CanvasToolbar
//
//  Created by MASUI Yuichiro on 2018/02/22.
//

import Foundation

class CanvasToolbarButtonWithMenu : UIControl {
    var contentView : UIView!
    var bundle:Bundle!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))

        //self.backgroundColor = UIColor.red
        // self.addSubview(contentView)
        loadBundle()
        let activeImage = loadImage("DrawMainActive")!
        //activeImage.backgroundColor = UIColor.red

        contentView.addSubview(activeImage)
        
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: .touchDown)

        addSubview(contentView)
    }
    
    @objc func buttonClicked(sender:UIControl) {
        print("buttonClicked")
        print(sender)
    }
    
    // 画像リソースを読み込み
    private func loadBundle() {
        let podBundle = Bundle(for: self.classForCoder)
        let bundleURL = podBundle.url(forResource: "CanvasToolbar", withExtension: "bundle")!
        bundle = Bundle(url: bundleURL)!
    }
    
    func loadImage(_ named:String) -> UIImageView? {
        let image = UIImage(named: named, in: bundle, compatibleWith: nil)!
        let view = UIImageView(image: image)
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        return view
    }
}
