//
//  Node.swift
//  SwiftRPG
//
//  Created by 兎澤佑 on 2015/08/08.
//  Copyright © 2015年 兎澤佑. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

/// A*アルゴリズムのためのノード
class Node {

    enum STATE {
        case none, open, closed
    }

    /// ステータス
    fileprivate(set) var state: STATE!
    
    /// XY座標
    fileprivate(set) var coordinates: TileCoordinate!
    
    /// 親ノード
    fileprivate(set) var parentNode: Node!
    
    /// 推定コスト
    fileprivate var heuristicCost: Int!
    
    /// 移動コスト
    fileprivate(set) var moveCost: Int!

    var score: Int {
        get {
            return self.heuristicCost + self.moveCost
        }
    }

    ///  コンストラクタ
    ///
    ///  - parameter coordinates: タイル座標
    init(coordinates: TileCoordinate) {
        self.state = STATE.none
        self.coordinates = TileCoordinate(x: coordinates.x,
                                          y: coordinates.y)
    }

    ///  ノードを開く
    ///
    ///  - parameter parentNode:  親ノード
    ///  - parameter destination: 目的地のタイル座標
    func open(_ parentNode: Node?, destination: TileCoordinate) {
        // ノードをOpen状態にする
        self.state = STATE.open

        // 実コストを求める. スタート地点だった場合には 0
        if parentNode == nil {
            moveCost = 0
        } else {
            moveCost = parentNode!.moveCost + 1
        }

        // 推定コストを求める
        let dx = abs(destination.x - coordinates.x)
        let dy = abs(destination.y - coordinates.y)
        heuristicCost = dx + dy

        // 親ノードを保持する
        self.parentNode = parentNode
    }

    ///  ノードを閉じる
    func close() {
        self.state = STATE.closed
    }

    ///  ノードの現在位置を確認する
    ///
    ///  - parameter coordinates: 確認する座標
    ///
    ///  - returns: 指定した座標にノードが存在しなければ false, 存在すれば true
    func isPositioned(_ coordinates: TileCoordinate) -> Bool {
        if coordinates == coordinates {
            return true
        } else {
            return false
        }
    }
}
