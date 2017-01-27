//
//  HideEventDialogListener.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2017/01/26.
//  Copyright © 2017年 兎澤佑. All rights reserved.
//

import Foundation
import SwiftyJSON
import JSONSchema
import SpriteKit
import PromiseKit

class HideEventDialogListener: EventListener {
    var id: UInt64!
    var delegate: NotifiableFromListener?
    var invoke: EventMethod?
    var rollback: EventMethod?
    var listensers: ListenerChain?
    var params: JSON?
    var isExecuting: Bool = false
    var eventObjectId: MapObjectId? = nil
    let triggerType: TriggerType
    internal var listeners: ListenerChain?

    required init(params: JSON?, chainListeners listeners: ListenerChain?) {
        self.triggerType   = .touch
        self.listeners     = listeners
        self.params        = params
        self.invoke        = { (sender: GameSceneProtocol?, args: JSON?) -> Promise<Void> in
            sender!.eventDialog.isHidden = true

            do {
                let nextEventListener = try InvokeNextEventListener(params: self.params, chainListeners: self.listeners)
                nextEventListener.eventObjectId = self.eventObjectId
                self.delegate?.invoke(self, listener: nextEventListener)
            } catch {
                throw error
            }

            return Promise<Void> { fullfill, reject in fullfill() }
        }
    }

    internal func chain(listeners: ListenerChain) {
        self.listeners = listeners
    }
}
