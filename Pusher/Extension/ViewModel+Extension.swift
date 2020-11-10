//
//  ViewModel+Extension.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Combine
import Terminal

extension Publishers {
    static func system<State, Event,
        Scheduler: Combine.Scheduler>(initial: State, reduce: @escaping (State, Event) -> State,
                                      scheduler: Scheduler,
                                      feedbacks: [ViewModel.Feedback<State, Event>]) ->
        AnyPublisher<State, Never>{
            let stateSignal = CurrentValueSubject<State, Never>(initial)
            let eventsSignal = feedbacks.map { ($0.run(stateSignal.eraseToAnyPublisher()))}
            return Deferred {
                Publishers.MergeMany(eventsSignal)
                    .receive(on: scheduler)
                    .scan(initial, reduce)
                    .handleEvents(receiveOutput: stateSignal.send)
                    .receive(on: scheduler)
                    .prepend(initial)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}


#if DEBUG
extension ViewModel.State: CustomStringConvertible {
    var description: String {
        switch self {
        case .idle:
            return "idle"
        case .checkingAbiliti:
            return "checkingAbiliti"
        case .abililitFailed:
            return "abililitFailed"
        case .listFetching:
            return "listFetching"
        case .listFetchingFailed(_):
            return "listFetchingFailed"
        case .showingItems:
            return "showingItems"
        case .selectItem(_):
            return "SelectItem"
        case .applicationFetching(_):
            return "applicationFetching"
        case .applicationFetchingFailed(_, _):
            return "applicationFetchingFailed"
        case .applicationFetchingSuccess(_, _):
            return "applicationFetchingSuccess"
        case .deviceOperattion(_):
            return "deviceOperattion"
        case .sendPushNotification(_, _, _, _):
            return "sendPushNotification"
        }
    }
}

extension ViewModel.Event: CustomStringConvertible {
    var description: String {
        switch self {
        case .onStart: return "onStart"
        case .onAbilitiFailed(_): return "onAbilitiFailed"
        case .onAbilitiSuccess: return "onAbilitiSuccess"
        case .onListFetchingFailed(_): return "onListFetchingFailed"
        case .onListFetchingSuccess(_): return "onListFetchingSuccess"
        case .onDeviceOperation(_): return "onDeviceOperation"
        case .onApplicationLoadingFailed(_): return "onApplicationLoadingFailed"
        case .onApplicationLoadingSuccess(_): return "onApplicationLoadingSuccess"
        case .onRefreshList: return "onRefreshList"
        case .onSelecctedItem(_): return "onSelecctedItem"
        case .onSendingPush(_, _, _): return "SendingPush"
        case .onSentPush: return "SentPush"
        case .onEditingPush: return "onEditingPush"
        case .onEditingEndPush(_): return "onEditingEndPush"
        }
    }
}
#endif
