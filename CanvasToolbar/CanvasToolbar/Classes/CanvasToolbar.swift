//
//  CanvasToolbar.swift
//  ColorPenMemo
//
//  Created by Yuichiro MASUI on 2017/12/30.
//  Copyright © 2017 TOMOHIKO OKITA. All rights reserved.
//

import UIKit

/**
 CanvasToolbarの変更やボタンが押されたことを受け取るdelegate
 */
public protocol CanvasToolbarDelegate {
    /**
     種類をペン、消しゴム、カットから選択
     - parameter penState: これから変更されるペンの状態
     - returns: 変更の許可不許可
    */
    func willChangePenState(penState:CanvasToolbar.PenState) -> Bool
    
    /**
     パレットから色を変更
     - parameter colorIndex: 変更されるカラー番号(colorsのインデックス)
     - returns: 変更の許可不許可
    */
    func willChangeColor(colorIndex:Int) -> Bool
    
    /**
     ペンの太さを変更した
     - parameter weight: ペンの太さ
    */
    func didChangeDrawWeight(weight:Int)
    
    /// Undoボタンが押された
    func didPressUndo()
    
    // Redoボタンが押された
    func didPressRedo()
    
    /// カメラボタンが押された
    func didPressCamera() // 未実装
    
    /// イメージライブラリボタンが押された
    func didPressImageLibrary() // 未実装
    
    /// イメージ削除ボタンが押された
    func didPressClearImage() // 未実装
    
    /// 設定ボタンが押された
    func didPressSetting()
    
    /// 出力ボタンが押された
    func didPressExport()
    
    /// 終了ボタンが押された
    func didPressExit()
}

/**
 ツールバーのコンポーネント
 
 init後にframeで大きさが決定されているので、適当な位置に配置してください。
 
 ex)
 ```
 ```
 */
public class CanvasToolbar: UIView, CanvasToolbarRadioButtonsProtocol {
    /// delegate
    public var delegate:CanvasToolbarDelegate?
    
    var drawBtn:UIButton!
    var eraseSingleBtn:UIButton!
    var eraseMultipleBtn:UIButton!
    var cutSingleBtn:UIButton!
    var cutMultipleBtn:UIButton!
    
    var imageBtn:UIButton!
    var undoBtn:UIButton!
    var redoBtn:UIButton!
    var settingBtn:UIButton!
    var exportBtn:UIButton!
    var exitBtn:UIButton!
    
    // ペンの太さとイメージ
    var drawWeightImages:[String] = ["DrawSmall", "DrawMedium", "DrawLarge"]
    var drawWeightValues:[Int] = [4, 8, 16]
    var drawWeightMenu:CanvasToolbarRadioButtons?
    
    // ペンの色一覧
    let colors:[UIColor]
    
    // 現在選択されている色のIndex
    public var colorIndex:Int? {
        didSet(oldColorIndex) {
            if let colorIndex = colorIndex {
                paletteCursor.isHidden = false
                let y = 2 + 6 + 42 * colorIndex + Int(paletteBG.frame.minY)
                paletteCursor.frame = CGRect(x: 10, y: y, width: 44, height: 30)
            }
            else {
                paletteCursor.isHidden = true
            }
        }
    }
    
    // 現在activeな色が有効か
    public var activeColors:[Bool] {
        didSet(colors) {
            for (index, palette) in palettes.enumerated() {
                palette.alpha = activeColors[index] ? 1.0 : 0.33
            }
        }
    }
    
    var palettes:[UIButton] = []
    var paletteCursor:UIImageView!
    var paletteBG:UIImageView!
    
    var eraseLayerImages:[String] = ["EraseSingle", "EraseMultiple"]
    var eraseLayerMenu:CanvasToolbarRadioButtons?
    
    var cutLayerImages:[String] = ["CutSingle", "CutMultiple"]
    var cutLayerMenu:CanvasToolbarRadioButtons?
    
    var bundle:Bundle!
    
    /// Undoボタンが有効か
    public var undoIsEnabled:Bool {
        set {
            undoBtn.isEnabled = newValue
        }
        get {
            return undoBtn.isEnabled
        }
    }

    /// Redoボタンが有効か
    public var redoIsEnabled:Bool {
        set {
            redoBtn.isEnabled = newValue
        }
        get {
            return redoBtn.isEnabled
        }
    }
    
    /// 対象レイヤーが1枚か全部か
    public enum Layer {
        case single
        case multiple
    }
    
    /// 選択されてるペンの状態
    public enum PenState {
        case draw
        case eraseSingle
        case eraseMultiple
        case cutSingle
        case cutMultiple
    }
    
    // 表示されているsubmenu
    enum SubMenu {
        case none
        case erase
        case cut
        case image
    }
    
    /**
     ペンの太さ
     現在 4, 8 16が設定可能
    */
    public var drawWeight:Int {
        set {
            guard let index = drawWeightValues.index(of: newValue) else { return }
            drawWeightMenu?.value = drawWeightImages[index]
        }
        get {
            guard let value = drawWeightMenu?.value else { return 0 }
            guard let index = drawWeightImages.index(of: value) else { return 0 }
            return drawWeightValues[index]
        }
    }
    
    /// eraseのレイヤー指定
    public var eraseLayer:Layer {
        set(layer) {
            eraseSingleBtn.isHidden = !(layer == .single)
            eraseMultipleBtn.isHidden = !(layer == .multiple)
            switch layer {
            case .single:
                eraseLayerMenu?.value = "EraseSingle"
            case .multiple:
                eraseLayerMenu?.value = "EraseMultiple"
            }
        }
        get {
            return eraseSingleBtn.isHidden ? .multiple : .single
        }
    }
    
    /// cutのレイヤー指定
    public var cutLayer:Layer {
        set(layer) {
            cutSingleBtn.isHidden = !(layer == .single)
            cutMultipleBtn.isHidden = !(layer == .multiple)
            switch layer {
            case .single:
                cutLayerMenu?.value = "CutSingle"
            case .multiple:
                cutLayerMenu?.value = "CutMultiple"
            }
        }
        get {
            return cutSingleBtn.isHidden ? .multiple : .single
        }
    }
    
    /// 現在選択中のペンの種類
    public var penState:PenState = .draw {
        didSet(oldPenState) {
            if delegate?.willChangePenState(penState: penState) ?? true {
                drawBtn.isSelected = (penState == .draw)
                eraseSingleBtn.isSelected = (penState == .eraseSingle || penState == .eraseMultiple)
                eraseMultipleBtn.isSelected = (penState == .eraseSingle || penState == .eraseMultiple)
                cutSingleBtn.isSelected = (penState == .cutSingle || penState == .cutMultiple)
                cutMultipleBtn.isSelected = (penState == .cutSingle || penState == .cutMultiple)
            }
        }
    }


    /**
     初期化してボタンを配置
     parameter colors: パレットの色の配列 6コ設定する
     */
    public init(colors:[UIColor]) {
        self.colors = colors
        self.activeColors = colors.map { _ in true }
        
        super.init(frame: CGRect.zero)

        loadBundle()
        
        createPenStateButtons()
        createPalette()
        createActionButtons()
        createSubmenus()
        setInitValues()
    }
    
    func loadBundle() {
        let podBundle = Bundle(for: self.classForCoder)
        let bundleURL = podBundle.url(forResource: "CanvasToolbar", withExtension: "bundle")!
        bundle = Bundle(url: bundleURL)!
    }
    
    private func setInitValues() {
        colorIndex = 0
        drawWeight = 8
        eraseLayer = .single
        cutLayer = .multiple
    }

    // パレットを生成
    private func createPalette() {
        paletteBG = UIImageView(frame: CGRect(x: 0, y: 288, width: 64, height: 256))
        paletteBG.image = loadImage("PaletteBackgroundActive")
        addSubview(paletteBG)

        for (index, color) in colors.enumerated() {
            let palette = UIButton(type: .custom)
            palette.frame = CGRect(x: 10, y: 2 + 6 + 42 * index + Int(paletteBG.frame.minY), width: 44, height: 30)
            palette.backgroundColor = color
            palette.accessibilityValue = String(index)
            palette.addTarget(self, action: #selector(didTapPaletteButton), for: .touchUpInside)
            palettes.append(palette)
            addSubview(palette)
        }
        
        // カーソル
        let cursorImage = loadImage("PaletteSelectActive")!
        paletteCursor = UIImageView(frame: CGRect(origin: CGPoint.zero, size: cursorImage.size))
        paletteCursor.image = cursorImage
        paletteCursor.isUserInteractionEnabled = false
        paletteCursor.isHidden = true
        addSubview(paletteCursor)
    }
    
    // ペンの状態変更を行うボタン群を生成
    private func createPenStateButtons() {
        drawBtn = addButton(name: "DrawMain", x: 0, y: 0, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        eraseSingleBtn = addButton(name: "EraseMainSingle", x: 0, y: 64, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        eraseMultipleBtn = addButton(name: "EraseMainMultiple", x: 0, y: 64, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        cutSingleBtn = addButton(name: "CutMainSingle", x: 0, y: 128, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        cutMultipleBtn = addButton(name: "CutMainMultiple", x: 0, y: 128, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        drawBtn.isSelected = true // 初期値は.draw
    }
    
    // ペンの状態変更ボタンが押されたので変更する
    @objc func didTapPenStateButton(sender: AnyObject) {
        closeSubmenu()
        guard let btn = sender as? UIButton else { return }
        guard let value = btn.accessibilityValue else { return }
        switch value {
        case "DrawMain":
            penState = .draw
        case "EraseMainSingle":
            penState = .eraseSingle
        case "EraseMainMultiple":
            penState = .eraseMultiple
        case "CutMainSingle":
            penState = .cutSingle
        case "CutMainMultiple":
            penState = .cutMultiple
        default:
            break
        }
    }
    
    // LongPressでSubmenuを表示する
    @objc func didLongPressButton(sender: UIGestureRecognizer) {
        guard let name = sender.name else { return }
        if sender.state == .began {
            switch name {
            case "DrawMainLongPress":
                penState = .draw
                showSubmenu(drawWeightMenu!)
                break
            case "EraseMainSingleLongPress":
                penState = .eraseSingle
                showSubmenu(eraseLayerMenu!)
                break
            case "EraseMainMultipleLongPress":
                penState = .eraseMultiple
                showSubmenu(eraseLayerMenu!)
                break
            case "CutMainSingleLongPress":
                penState = .cutSingle
                showSubmenu(cutLayerMenu!)
            case "CutMainMultipleLongPress":
                penState = .cutMultiple
                showSubmenu(cutLayerMenu!)
                break
            default:
                break
            }
        }
    }
    
    // Submenuを生成
    private func createSubmenus() {
        drawWeightMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: drawBtn.frame.maxX, y: drawBtn.frame.minY),
            images: drawWeightImages
        )
        drawWeightMenu?.delegate = self
        drawWeightMenu?.isHidden = true
        drawWeightMenu?.name = "Draw"
        addSubview(drawWeightMenu!)

        eraseLayerMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: eraseSingleBtn.frame.maxX, y: eraseSingleBtn.frame.minY),
            images: eraseLayerImages
        )
        eraseLayerMenu?.delegate = self
        eraseLayerMenu?.isHidden = true
        eraseLayerMenu?.name = "Erase"
        addSubview(eraseLayerMenu!)

        cutLayerMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: cutSingleBtn.frame.maxX, y: cutSingleBtn.frame.minY),
            images: cutLayerImages
        )
        cutLayerMenu?.delegate = self
        cutLayerMenu?.isHidden = true
        cutLayerMenu?.name = "Cut"
        addSubview(cutLayerMenu!)
    }
    
    // Submenuを表示
    func showSubmenu(_ menu:CanvasToolbarRadioButtons) {
        closeSubmenu()
        menu.isHidden = false
    }

    // すべてのSubmenu(右に伸びるヤツ)を閉じる
    func closeSubmenu() {
        drawWeightMenu?.isHidden = true
        eraseLayerMenu?.isHidden = true
        cutLayerMenu?.isHidden = true
    }
    
    // Submenuの値を変更
    func didChangeSubmenuValue(sender: CanvasToolbarRadioButtons) {
        closeSubmenu()
        guard let name = sender.name else { return }
        switch name {
        case "Draw":
            delegate?.didChangeDrawWeight(weight: self.drawWeight)
        case "Erase":
            switch sender.value {
            case "EraseSingle":
                eraseLayer = .single
            case "EraseMultiple":
                eraseLayer = .multiple
            default:
                break
            }
        case "Cut":
            switch sender.value {
            case "CutSingle":
                cutLayer = .single
            case "CutMultiple":
                cutLayer = .multiple
            default:
                break
            }
        default:
            break
        }
    }

    // アクションボタン群を生成
    private func createActionButtons() {
        imageBtn = addButton(name: "ImageMain", x: 0, y: 192, action: #selector(didTapActionButton))
        undoBtn = addButton(name: "Undo", x: 0, y: 240, action: #selector(didTapActionButton))
        redoBtn = addButton(name: "Redo", x: 32, y: 240, action: #selector(didTapActionButton))
        settingBtn = addButton(name: "Setting", x: 0, y: 544, action: #selector(didTapActionButton))
        exportBtn = addButton(name: "Export", x: 32, y: 544, action: #selector(didTapActionButton))
        exitBtn = addButton(name: "Exit", x: 0, y: 592, action: #selector(didTapActionButton))
    }
    
    @objc func didTapActionButton(sender: AnyObject) {
        closeSubmenu()
        guard let btn = sender as? UIButton else { return }
        guard let value = btn.accessibilityValue else { return }
        switch value {
        case "Undo":
            delegate?.didPressUndo()
        case "Redo":
            delegate?.didPressRedo()
        case "Setting":
            delegate?.didPressSetting()
        case "Export":
            delegate?.didPressExport()
        case "Exit":
            delegate?.didPressExit()
        default:
            break
        }
    }
    
    // イメージ付きボタンを生成
    private func addButton(name:String, x: Int, y:Int, action:Selector, longPressAction:Selector? = nil) -> UIButton {
        let activeImg = loadImage("\(name)Active")!
        let deactiveImg = loadImage("\(name)Deactive")!
        
        let btn = UIButton(frame: CGRect(origin: CGPoint(x: x, y: y), size: activeImg.size))
        btn.accessibilityValue = name

        btn.setImage(deactiveImg, for: .normal)
        btn.setImage(activeImg, for: .selected)
        btn.setImage(activeImg, for: .highlighted)
        
        let disableImg = loadImage("\(name)Disable")
        if let disableImg = disableImg {
            btn.setImage(disableImg, for: .disabled)
        }
        
        btn.addTarget(self, action: action, for: .touchUpInside)
        
        if longPressAction != nil {
            let longGesture = UILongPressGestureRecognizer(target: self, action: longPressAction)
            longGesture.name = "\(name)LongPress"
            btn.addGestureRecognizer(longGesture)
        }
        
        self.frame = CGRect(
            origin: self.frame.origin,
            size: CGSize(
                width: max(self.frame.width, btn.frame.maxX),
                height: max(self.frame.height, btn.frame.maxY)
            )
        )
        
        addSubview(btn)
        return btn
    }
    
    // パレットを選択
    @objc func didTapPaletteButton(sender: AnyObject) {
        closeSubmenu()
        guard let btn = sender as? UIButton else { return }
        guard let value = btn.accessibilityValue else { return }
        guard let index = Int(value) else { return }
        
        if delegate?.willChangeColor(colorIndex: index) ?? true {
            self.colorIndex = index
        }
    }
    
    func loadImage(_ named:String) -> UIImage? {
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
    
    // frame外のsubviewもtapできる様にする
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        closeSubmenu()
        return false
    }
    
    // UIViewを継承したクラスには必要?
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
