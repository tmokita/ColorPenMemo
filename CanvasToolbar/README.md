# CanvasToolbar

お絵かきアプリ内部で使うツールバー



## Example

サンプルは[Example/ViewController.swift](https://github.com/tmokita/ColorPenMemo/blob/master/CanvasToolbar/Example/CanvasToolbar/ViewController.swift)を参照してください

```Sample.swift
 // パレットの色を指定して生成’
 let toolbar = CanvasToolbar(colors: [.gray, .red, .blue, .green, .brown, .cyan])
 toolbar.delegate = self

 // センターに表示する
 let middle = Int(UIScreen.main.bounds.height - toolbar.frame.height) / 2
 toolbar.frame = CGRect(origin: CGPoint(x:0, y:middle), size: toolbar.frame.size)
 
 self.view.addSubview(toolbar)
 ```

ボタンが押されたり、色が変更された通知はdelegateで来ます。

## Requirements

## Installation

CanvasToolbar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CanvasToolbar', path: "../CanvasToolbar"
```

## Author

Yuichiro MASUI, masui@masuidrive.jp

## License

CanvasToolbar is available under the MIT license. See the LICENSE file for more info.
