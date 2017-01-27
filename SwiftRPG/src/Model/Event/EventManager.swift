//
//  EventManager.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2016/08/02.
//  Copyright © 2016年 兎澤佑. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol NotifiableFromDispacher {
    func invoke(_ invoker: EventListener, listener: EventListener)
}

enum EventManagerError: Error {
    case FailedToTrigger(String)
}

class EventManager: NotifiableFromDispacher {
    fileprivate var touchEventDispacher: EventDispatcher
    fileprivate var actionButtonEventDispacher: EventDispatcher
    fileprivate var cyclicEventDispacher: EventDispatcher

    init() {
        self.touchEventDispacher = EventDispatcher()
        self.actionButtonEventDispacher = EventDispatcher()
        self.cyclicEventDispacher = EventDispatcher()

        self.touchEventDispacher.delegate = self
        self.actionButtonEventDispacher.delegate = self
        self.cyclicEventDispacher.delegate = self
    }

    func add(_ listener: EventListener) -> Bool {
        let dispacher = self.getDispacherOf(listener.triggerType)
        if dispacher.add(listener) == false {
            return false
        } else {
            return true
        }
    }

    func trigger(_ type: TriggerType, sender: GameSceneProtocol!, args: JSON!) throws {
        let dispacher = self.getDispacherOf(type)
        do {
            try dispacher.trigger(sender, args: args)
        } catch EventDispacherError.FiledToInvokeListener(let string) {
            throw EventManagerError.FailedToTrigger(string)
        }
    }

    // MARK: - Private methods

    fileprivate func getDispacherOf(_ type: TriggerType) -> EventDispatcher {
        switch type {
        case .touch:
            return self.touchEventDispacher
        case .button:
            return self.actionButtonEventDispacher
        case .immediate:
            return self.cyclicEventDispacher
        }
    }

    // MARK: - NotifiableFromDispacher

    // TODO: remove, add が失敗した場合の処理の追加
    func invoke(_ invoker: EventListener, listener: EventListener) {
        let invokerDispacher = self.getDispacherOf(invoker.triggerType)
        let nextListenersDispacher = self.getDispacherOf(listener.triggerType)

        // Cannot execute following code:
        // In Listener chain, listeners which passed to here are defined as clojure in each event listeners.
        // The remove function of event dispatcher uses listener id which is specified at the time of adding listener to dispathcer.
        // But the clojure could only know about variables at the time of it is defined, so cannot access listener id from clojure.
        //   if invokerDispacher.remove(invoker) == false {}
        // Instead of listener id, we use event object id
        // Commonly, one event object has only one event listener chain, and it is defined at the time of 
        invokerDispacher.removeByEventObjectId(invoker)

        // TODO: うまく排他制御する
        nextListenersDispacher.removeAll()
        if nextListenersDispacher.add(listener) == false { return }
    }
}
