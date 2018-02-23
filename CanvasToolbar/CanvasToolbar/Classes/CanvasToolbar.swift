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
     - parameter penState: 新しいペンの状態
    */
    func didChangePenState(penState:CanvasToolbar.PenState)
    
    /**
     パレットから色を変更
     - parameter colorIndex: 新しいカラー番号(colorsのインデックス)
    */
    func didChangeColor(colorIndex:Int)
    
    /**
     アクティブな色を変更
     - parameter activeColors: 新しいアクティブな色
     */
    func didChangeActiveColors(activeColors:[Bool]) // 未実装
    
    /**
     ペンの太さを変更した
     - parameter weight: ペンの太さ
    */
    func didChangeDrawWeight(weight:CanvasToolbar.DrawWeight)
    
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
    
    /// ツールバーが表示された
    func didShowToolbar()
    
    /// ツールバーが非表示になった
    func didHideToolbar()
}

/**
 ツールバーのコンポーネント
 
 init後にframeで大きさが決定されているので、適当な位置に配置してください。
 */
public class CanvasToolbar: UIView, CanvasToolbarRadioButtonsProtocol {
    /// delegate
    public var delegate:CanvasToolbarDelegate?
    
    // メインボタンを置く部分のView
    var bodyView:UIView!
    
    // ボタン群
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
    
    var hideBtn:UIButton!
    var showBtn:UIButton!
    
    // ペンの太さとイメージ
    var drawWeightImages:[String] = ["DrawSmall", "DrawMedium", "DrawLarge"]
    var drawWeightValues:[DrawWeight] = [.small, .medium, .large]
    var drawWeightMenu:CanvasToolbarRadioButtons?
    
    // ペンの色一覧
    let colors:[UIColor]
    
    /// 現在選択されている色のIndex
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
    
    /**
     現在どの色が有効か
     falseでも選択可能なので、許可したくない場合は`willChangeColor()`でfalseを返してください。

     indexは0-5まで
     */
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
    
    /// 線の太さ
    public enum DrawWeight:Int {
        case small = 4
        case medium = 8
        case large = 16
    }
    
    // 表示されているsubmenu
    enum SubMenu {
        case none
        case erase
        case cut
        case image
    }
    
    // ツールバーが表示されているか
    public enum Visibility {
        case shown
        case hidden
    }
    
    /**
     ペンの太さ
     現在 4, 8 16が設定可能
    */
    public var drawWeight:DrawWeight {
        set {
            guard let index = drawWeightValues.index(of: newValue) else { return }
            drawWeightMenu?.value = drawWeightImages[index]
        }
        get {
            guard let value = drawWeightMenu?.value else { return .medium }
            guard let index = drawWeightImages.index(of: value) else { return .medium }
            return drawWeightValues[index]
        }
    }
    
    /// Eraseボタンのレイヤー指定
    /// あまり触ることはないはず
    public var eraseLayer:Layer {
        set(layer) {
            switch layer {
            case .single:
                eraseLayerMenu?.value = "EraseSingle"
                if penState == .eraseMultiple {
                    penState = .eraseSingle
                }
            case .multiple:
                eraseLayerMenu?.value = "EraseMultiple"
                if penState == .eraseSingle {
                    penState = .eraseMultiple
                }
            }
            eraseSingleBtn.isHidden = !(layer == .single)
            eraseMultipleBtn.isHidden = !(layer == .multiple)
        }
        get {
            return eraseSingleBtn.isHidden ? .multiple : .single
        }
    }
    
    /// Cutボタンのレイヤー指定
    /// あまり触ることはないはず
    public var cutLayer:Layer {
        set(layer) {
            switch layer {
            case .single:
                cutLayerMenu?.value = "CutSingle"
                if penState == .cutMultiple {
                    penState = .cutSingle
                }
            case .multiple:
                cutLayerMenu?.value = "CutMultiple"
                if penState == .cutSingle {
                    penState = .cutMultiple
                }
            }
            cutSingleBtn.isHidden = !(layer == .single)
            cutMultipleBtn.isHidden = !(layer == .multiple)
        }
        get {
            return cutSingleBtn.isHidden ? .multiple : .single
        }
    }
    
    /// 現在選択中のペンの種類
    public var penState:PenState = .draw {
        didSet(oldPenState) {
            drawBtn.isSelected = (penState == .draw)
            eraseSingleBtn.isSelected = (penState == .eraseSingle || penState == .eraseMultiple)
            eraseMultipleBtn.isSelected = (penState == .eraseSingle || penState == .eraseMultiple)
            cutSingleBtn.isSelected = (penState == .cutSingle || penState == .cutMultiple)
            cutMultipleBtn.isSelected = (penState == .cutSingle || penState == .cutMultiple)
            delegate?.didChangePenState(penState: penState)
        }
    }
    
    /// ツールバーの表示・非表示
    /// アニメーションします
    public var visibility:Visibility = .shown {
        didSet(oldVisibility) {
            if oldVisibility != visibility {
                let duration = 0.5
                let movement = self.bodyView.frame.size.width * -1
                switch visibility {
                case .shown:
                    self.hideBtn.frame.origin.x = movement
                    UIView.animate(withDuration: duration, delay: 0.0, animations: {
                        self.showBtn.frame.origin.x = movement
                        self.hideBtn.frame.origin.x = 0
                        self.bodyView.frame.origin.x = 0
                    }, completion: nil)
                    delegate?.didShowToolbar()
                    
                case .hidden:
                    UIView.animate(withDuration: duration, delay: 0.0, animations: {
                        self.hideBtn.frame.origin.x = movement
                        self.bodyView.frame.origin.x = movement
                    }, completion: nil)
                    let ratio = Double(self.hideBtn.frame.origin.x / self.bodyView.frame.origin.x)
                    UIView.animate(withDuration: duration * ratio, delay: duration * (1.0 - ratio), animations: {
                        self.showBtn.frame.origin.x = 0
                    }, completion: nil)
                    delegate?.didHideToolbar()
                }
            }
        }
    }


    /**
     初期化してボタンを配置
     - parameter colors: パレットの色の配列 6コ設定する
     */
    public init(colors:[UIColor]) {
        self.colors = colors
        self.activeColors = colors.map { _ in true }
        
        super.init(frame: CGRect.zero)

        loadBundle()
        
        // 表示・非表示ボタン
        createVisibilityButton()
        
        // ツールバー本体部分を生成
        bodyView = UIView(frame: CGRect(x: 0, y: 24, width: 64, height: 620))
        //createPenStateButtons(view: bodyView)
        //createPalette(view: bodyView)
        //createActionButtons(view: bodyView)
        //createSubmenus(view: bodyView)
        let bwm = CanvasToolbarButtonWithMenu(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        bodyView.addSubview(bwm)
        addSubview(bodyView)
        
        // 初期値設定
        //setInitValues()
    }
    
    /**
     中央になるy座標を取得
     
     - return Y座標
     */
    public func middleOf(height:Double) -> Double {
        return (height - Double(bodyView.frame.size.height)) / 2.0 - Double(showBtn.frame.size.height)
    }
    
    // 画像リソースを読み込み
    private func loadBundle() {
        let podBundle = Bundle(for: self.classForCoder)
        let bundleURL = podBundle.url(forResource: "CanvasToolbar", withExtension: "bundle")!
        bundle = Bundle(url: bundleURL)!
    }
    
    // 初期値を設定
    private func setInitValues() {
        colorIndex = 0
        drawWeight = .medium
        eraseLayer = .single
        cutLayer = .multiple
        visibility = .shown
    }

    // ツールバーの表示・非表示ボタン
    func createVisibilityButton() {
        let hideImg = loadImage("HideActive")!
        hideBtn = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: hideImg.size))
        hideBtn.accessibilityValue = "HideToolbar"
        hideBtn.setImage(hideImg, for: .normal)
        hideBtn.addTarget(self, action: #selector(didTapVisibilityButton), for: .touchUpInside)
        addSubview(hideBtn)

        let showImg = loadImage("ShowActive")!
        showBtn = UIButton(frame: CGRect(origin: CGPoint(x: -hideImg.size.width, y: 0), size: hideImg.size))
        showBtn.accessibilityValue = "ShowToolbar"
        showBtn.setImage(showImg, for: .normal)
        showBtn.addTarget(self, action: #selector(didTapVisibilityButton), for: .touchUpInside)
        addSubview(showBtn)
    }
    
    // 表示・非表示ボタンをタップ
    @objc func didTapVisibilityButton(sender: AnyObject) {
        guard let btn = sender as? UIButton else { return }
        switch btn.accessibilityValue ?? "" {
        case "ShowToolbar":
            visibility = .shown
        case "HideToolbar":
            visibility = .hidden
        default:
            break
        }
    }
    
    // パレットを生成
    private func createPalette(view: UIView) {
        paletteBG = UIImageView(frame: CGRect(x: 0, y: 288, width: 64, height: 256))
        paletteBG.image = loadImage("PaletteBackgroundActive")
        view.addSubview(paletteBG)

        for (index, color) in colors.enumerated() {
            let palette = UIButton(type: .custom)
            palette.frame = CGRect(x: 10, y: 2 + 6 + 42 * index + Int(paletteBG.frame.minY), width: 44, height: 30)
            palette.backgroundColor = color
            palette.accessibilityValue = String(index)
            palette.addTarget(self, action: #selector(didTapPaletteButton), for: .touchUpInside)
            palettes.append(palette)
            view.addSubview(palette)
        }
        
        // カーソル
        let cursorImage = loadImage("PaletteSelectActive")!
        paletteCursor = UIImageView(frame: CGRect(origin: CGPoint.zero, size: cursorImage.size))
        paletteCursor.image = cursorImage
        paletteCursor.isUserInteractionEnabled = false
        paletteCursor.isHidden = true
        view.addSubview(paletteCursor)
    }
    
    // ペンの状態変更を行うボタン群を生成
    private func createPenStateButtons(view: UIView) {
        drawBtn = addButton(view: view, name: "DrawMain", x: 0, y: 0, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        eraseSingleBtn = addButton(view: view, name: "EraseMainSingle", x: 0, y: 64, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        eraseMultipleBtn = addButton(view: view, name: "EraseMainMultiple", x: 0, y: 64, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        cutSingleBtn = addButton(view: view, name: "CutMainSingle", x: 0, y: 128, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
        cutMultipleBtn = addButton(view: view, name: "CutMainMultiple", x: 0, y: 128, action: #selector(didTapPenStateButton), longPressAction: #selector(didLongPressButton))
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
    private func createSubmenus(view: UIView) {
        drawWeightMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: drawBtn.frame.maxX, y: drawBtn.frame.minY),
            images: drawWeightImages
        )
        drawWeightMenu?.delegate = self
        drawWeightMenu?.isHidden = true
        drawWeightMenu?.name = "Draw"
        view.addSubview(drawWeightMenu!)

        eraseLayerMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: eraseSingleBtn.frame.maxX, y: eraseSingleBtn.frame.minY),
            images: eraseLayerImages
        )
        eraseLayerMenu?.delegate = self
        eraseLayerMenu?.isHidden = true
        eraseLayerMenu?.name = "Erase"
        view.addSubview(eraseLayerMenu!)

        cutLayerMenu = CanvasToolbarRadioButtons(
            origin: CGPoint(x: cutSingleBtn.frame.maxX, y: cutSingleBtn.frame.minY),
            images: cutLayerImages
        )
        cutLayerMenu?.delegate = self
        cutLayerMenu?.isHidden = true
        cutLayerMenu?.name = "Cut"
        view.addSubview(cutLayerMenu!)
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
    private func createActionButtons(view: UIView) {
        imageBtn = addButton(view: view, name: "ImageMain", x: 0, y: 192, action: #selector(didTapActionButton))
        undoBtn = addButton(view: view, name: "Undo", x: 0, y: 240, action: #selector(didTapActionButton))
        redoBtn = addButton(view: view, name: "Redo", x: 32, y: 240, action: #selector(didTapActionButton))
        settingBtn = addButton(view: view, name: "Setting", x: 0, y: 544, action: #selector(didTapActionButton))
        exportBtn = addButton(view: view, name: "Export", x: 32, y: 544, action: #selector(didTapActionButton))
        exitBtn = addButton(view: view, name: "Exit", x: 0, y: 592, action: #selector(didTapActionButton))
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
    private func addButton(view: UIView, name:String, x: Int, y:Int, action:Selector, longPressAction:Selector? = nil) -> UIButton {
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
        
        view.addSubview(btn)
        return btn
    }
    
    // パレットを選択
    @objc func didTapPaletteButton(sender: AnyObject) {
        closeSubmenu()
        guard let btn = sender as? UIButton else { return }
        guard let value = btn.accessibilityValue else { return }
        guard let index = Int(value) else { return }

        self.colorIndex = index
        delegate?.didChangeColor(colorIndex: index)
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
