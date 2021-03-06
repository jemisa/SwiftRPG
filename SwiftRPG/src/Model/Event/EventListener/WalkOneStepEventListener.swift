//
//  WalkOneStepEventListener.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2017/01/26.
//  Copyright © 2017年 兎澤佑. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import SwiftyJSON
import JSONSchema
import PromiseKit

class WalkOneStepEventListener: EventListenerImplement {
    required init(params: JSON?, chainListeners listeners: ListenerChain?) throws {
        try! super.init(params: params, chainListeners: listeners)

        let schema = Schema([
            "type": "object",
            "properties": [
                "destination": ["type": "string"],
            ],
            "required": ["destination"],
            ])
        let result = schema.validate(params?.rawValue ?? [])
        if result.valid == false {
            throw EventListenerError.illegalParamFormat(result.errors!)
        }

        self.triggerType   = .immediate
        self.invoke        = { (sender: GameSceneProtocol?, args: JSON?) -> Promise<Void> in
            self.isExecuting = true

            let map   = sender!.map!
            let sheet = map.sheet!

            let player      = map.getObjectByName(objectNameTable.PLAYER_NAME)!
            let destination = TileCoordinate.parse(from: (self.params?["destination"].string)!)

            // Generate SKAction for moving
            let action = player.getActionTo(
                player.position,
                destination: TileCoordinate.getSheetCoordinateFromTileCoordinate(destination),
                preCallback: {
                    map.setCollisionOn(coordinate: destination)
                },
                postCallback: {
                    map.removeCollisionOn(coordinate: destination)
                    map.updateObjectPlacement(player, departure: player.coordinate, destination: destination)
                }
            )

            let screenAction = sheet.getActionTo(
                player.position,
                destination: TileCoordinate.getSheetCoordinateFromTileCoordinate(destination),
                speed: player.speed
            )

            // If player can't reach destination tile because of collision, stop
            if !map.canPass(destination) {
                self.delegate?.invoke(WalkEventListener.init(params: nil, chainListeners: nil), invoker: self)
                return Promise<Void> { fullfill, reject in fullfill() }
            }

            return Promise<Void> { fullfill, reject in
                firstly {
                    sender!.movePlayer(
                        action,
                        departure: player.coordinate,
                        destination: destination,
                        screenAction: screenAction,
                        invoker: self
                    )
                }.then { _ -> Void in
                    // If reached at destination, stop walking and set WalkEvetListener as touch event again
                    if self.listeners == nil || self.listeners?.count == 0
                    || map.getEventsOn(destination).isEmpty == false {
                        let nextEventListener = WalkEventListener.init(params: nil, chainListeners: nil)
                        nextEventListener.eventObjectId = self.eventObjectId
                        nextEventListener.isBehavior = self.isBehavior
                        self.delegate?.invoke(nextEventListener, invoker: self)
                        return
                    }

                    // If player don't reach at destination, invoke next step animation listener
                    let nextListener = self.listeners!.first!.listener
                    let nextListenerChain: ListenerChain? = self.listeners!.count == 1 ? nil : Array(self.listeners!.dropFirst())
                    do {
                        let nextListenerInstance = try nextListener.init(params: self.listeners!.first!.params, chainListeners: nextListenerChain)
                        nextListenerInstance.isBehavior = self.isBehavior
                        self.delegate?.invoke(nextListenerInstance, invoker: self)
                    } catch {
                        throw error
                    }
                }.then {
                    fullfill()
                }.catch { error in
                    print(error.localizedDescription)
                }
            }
        }
    }
}
