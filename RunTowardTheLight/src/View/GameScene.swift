//
//  GameScene.swift
//  RunTowardTheLight
//
//  Created by 兎澤佑 on 2015/06/27.
//  Copyright (c) 2015年 兎澤佑. All rights reserved.
//

import SpriteKit
import Foundation

/// view controller に処理を delegate する
protocol GameSceneDelegate: class {
    func displayTouched(touch: UITouch?)
    func actionButtonTouched()
}

/// ゲーム画面
class GameScene: SKScene {
    var gameSceneDelegate: GameSceneDelegate?
    
    /* ゲーム画面の各構成要素 */
    var map: Map!
    var textBox_: Dialog!
    var actionButton_: UIButton!

    override func didMoveToView(view: SKView) {
        // マップ生成
        if let map = Map(mapName: "sample_map02", frameWidth: self.frame.width, frameHeight: self.frame.height) {
            self.map = map
            self.map.addSheetTo(self)
        }

        // アクションボタン生成
        actionButton_ = UIButtonAnimated(frame: CGRectMake(0, 0, 250, 80))
        actionButton_.backgroundColor = UIColor.blackColor();
        actionButton_.setTitle("TALK", forState: UIControlState.Normal)
        actionButton_.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        actionButton_.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton_.layer.cornerRadius = 10.0
        actionButton_.layer.position = CGPoint(x: self.view!.frame.width / 2, y: self.view!.frame.height * 3/4)
        actionButton_.layer.borderColor = UIColor.whiteColor().CGColor
        actionButton_.layer.borderWidth = 2.0
        actionButton_.addTarget(self, action: "actionButtonTouched:", forControlEvents: .TouchUpInside)
        actionButton_.hidden = true
        self.view!.addSubview(actionButton_);

        // テキストボックス生成
        textBox_ = Dialog(frame_width: self.frame.width, frame_height: self.frame.height)
        textBox_.hide()
        textBox_.setPositionY(Dialog.POSITION.top)
        textBox_.addTo(self)
    }

    
    ///  タッチ時の処理
    ///
    ///  - parameter touches: タッチ情報
    ///  - parameter event:   イベント
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // コントローラに処理を委譲する
        gameSceneDelegate?.displayTouched(touches.first)
    }

    
    ///  アクションボタン押下時の処理
    ///  コントローラに処理を委譲する
    ///
    ///  - parameter sender: sender
    func actionButtonTouched(sender: UIButton) {
        gameSceneDelegate?.actionButtonTouched()
    }

    
    override func update(currentTime: CFTimeInterval) {
        map.updateObjectsZPosition()
    }
}