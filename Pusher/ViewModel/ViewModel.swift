//
//  ViewModel.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Combine
import Terminal
import SwiftUI

protocol ViewModelProtocol {
    static func checkDeveloperToolsEligiblity() -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
    func fetchAvailableDeviceList() -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
    static func fetchApplicationList() -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
    static func performDeviceOperation() -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
    static func receiveUserEvent(input: AnyPublisher<ViewModel.Event, Never>) -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
    static func sendPushNotification() -> ViewModel.Feedback<ViewModel.State, ViewModel.Event>
}


final class ViewModel: ObservableObject {
    /// Properties
    @Published private(set) var state = State.idle
    @Published private(set) var deviceList = [DeviceFamily: [DeviceContext]]() { didSet { updateSelectionIfNeeded() } }
    private(set) var selectedDeviceContext: DeviceContext?
    private(set) var pushPayload: String = Constant.payload.message
    private let event = PassthroughSubject<Event, Never>()
    private var disposeBag = Set<AnyCancellable>()
    struct Feedback<State, Event> {
        let run: (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
        init<SideEffect: Publisher>(sideEffects: @escaping(State) -> SideEffect) where
            SideEffect.Output == Event, SideEffect.Failure == Never {
                self.run = { (state: (AnyPublisher<State, Never>)) -> AnyPublisher<Event, Never> in
                    state.map { (s: State) in
                        return sideEffects(s)
                    }.switchToLatest().eraseToAnyPublisher()
                }
        }
    }
    
    /// Methods
    deinit { disposeBag.removeAll() }
    init() {
        Publishers.system( initial: state, reduce: State.reduce, scheduler: RunLoop.main,
                           feedbacks: [
                            Self.checkDeveloperToolsEligiblity(),
                            Self.fetchApplicationList(),
                            self.fetchAvailableDeviceList(),
                            Self.performDeviceOperation(),
                            Self.sendPushNotification(),
                            Self.receiveUserEvent(input: event.eraseToAnyPublisher())
        ]).assign(to: \.state, on: self).store(in: &disposeBag)
    }
    func send(event: Event) {
        if case let .onSelecctedItem(device) = event  {
            selectedDeviceContext = device
        }
        if case let .onEditingEndPush(payload) = event {
            self.pushPayload = payload
        }
        self.event.send(event)
    }
    func isValidPayload(_ rawPayload: String) -> Bool {
        return ApnsPayload.getPayload(from: rawPayload) != nil
    }
    
    private func updateSelectionIfNeeded() {
        guard let hasSelected = selectedDeviceContext,
            let selectedDeviceFromList = deviceList[hasSelected.family]?
                .filter({ $0.id == hasSelected.id })
                .first else {
                return
        }
        self.selectedDeviceContext = selectedDeviceFromList
    }
}

/// ViewModelProtocol.
extension ViewModel: ViewModelProtocol {
    static func checkDeveloperToolsEligiblity() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .checkingAbiliti = state else { return Empty().eraseToAnyPublisher() }
            return TerminalManager.isDeveloperToolSupportPush()
                .map ({ _ in Event.onAbilitiSuccess })
                .catch { Just(Event.onAbilitiFailed($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAvailableDeviceList() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .listFetching = state else { return Empty().eraseToAnyPublisher() }
            return TerminalManager.fetchingDeviceList()
                .receive(on: DispatchQueue.main)
                .map { (list: [DeviceFamily : [DeviceContext]]) in
                    Just(list)
                        .assign(to: \.deviceList, on: self)
                        .store(in: &self.disposeBag)
                    return Event.onListFetchingSuccess(list)
            }
            .catch { Just(Event.onListFetchingFailed($0)) }
                .eraseToAnyPublisher()
            /*return TerminalManager.fetchingDeviceList()
                .receive(on: DispatchQueue.main)
                .map { (list: [DeviceFamily : [DeviceContext]]) in
                    self.deviceList = list
                    return Event.onListFetchingSuccess(list)
            }
            .catch { Just(Event.onListFetchingFailed($0)) }
                .eraseToAnyPublisher()*/
        }
    }
    static func fetchApplicationList() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let  .applicationFetching(simulator) = state, simulator != nil else {
                return Empty().eraseToAnyPublisher()
            }
            return TerminalManager.fetchingApplicationsFor(udid: simulator!.udid)
                .receive(on: DispatchQueue.main)
                .map ({ Event.onApplicationLoadingSuccess($0) })
                .catch {( Just(Event.onApplicationLoadingFailed($0)) )}
                .eraseToAnyPublisher()
        }
    }
    static func receiveUserEvent(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        
        Feedback { _ in input }
    }
    static func performDeviceOperation() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let .deviceOperattion(simulator) = state else { return Empty().eraseToAnyPublisher() }
            let udid = simulator.udid
            let isActive = simulator.state == .booted
            return TerminalManager
                .deviceOperation(udid, isActive)
                .map({ _ in Event.onRefreshList})
                .eraseToAnyPublisher()
        }
    }
    static func sendPushNotification() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let .sendPushNotification(_, device, appid, payload) = state else { return Empty().eraseToAnyPublisher() }
            return TerminalManager.sendPush(for: device?.udid ?? "", app: appid, payload: payload)
                .map({ _ in Event.onSentPush })
                .eraseToAnyPublisher()
        }
    }
}

/// ViewModelProtocol.
extension ViewModel {
    enum State {
        case idle
        case checkingAbiliti
        case abililitFailed
        case listFetching
        case listFetchingFailed(Error)
        case showingItems
        case selectItem(DeviceContext?, [ApplicationContext]? = nil)
        case applicationFetching(DeviceContext?)
        case applicationFetchingFailed(Error, DeviceContext?)
        case applicationFetchingSuccess([ApplicationContext], DeviceContext?)
        case sendPushNotification([ApplicationContext], DeviceContext?, String, String)
        case deviceOperattion(DeviceContext)
        
        static func reduce(_ state: State, _ event: Event) -> State {
            switch (state, event) {
            case (.idle, .onStart): return .checkingAbiliti
            case (.checkingAbiliti, .onAbilitiFailed(_)): return .abililitFailed
            case (.checkingAbiliti, .onAbilitiSuccess): return .listFetching
            case (.listFetching, .onListFetchingFailed(let error)): return .listFetchingFailed(error)
            case (.listFetching, .onListFetchingSuccess( _)): return .showingItems
            case (.showingItems, .onSelecctedItem(let item)):
                return (item.state == .booted) ? .applicationFetching(item) : .selectItem(item)
            case (.showingItems, .onDeviceOperation(let item)): return .deviceOperattion(item)
            case (.selectItem(_), .onSelecctedItem(let item)):
                return (item.state == .booted) ? .applicationFetching(item) : .showingItems
            case (.selectItem(_), .onDeviceOperation(let item)): return .deviceOperattion(item)
            case (.applicationFetching(let item), .onApplicationLoadingFailed(let error)):
                return .applicationFetchingFailed(error, item)
            case (.applicationFetching(let item), .onApplicationLoadingSuccess(let appContexts)):
                return .applicationFetchingSuccess(appContexts, item)
            case (.applicationFetchingFailed(_, _), .onDeviceOperation(let item)):
                return .deviceOperattion(item)
            case (.applicationFetchingSuccess(_, _), .onDeviceOperation(let item)):
                return .deviceOperattion(item)
            case (.applicationFetchingSuccess(_, _), .onSelecctedItem(let item)):
                return (item.state == .booted) ? applicationFetching(item) : .selectItem(item)
            case (.deviceOperattion(_), .onRefreshList): return .listFetching
            case (.applicationFetchingSuccess(let apps, _), .onSendingPush(let item, let appid, let payload)):
                return .sendPushNotification(apps, item, appid, payload)
            case (.sendPushNotification(let apps, let item, _, _), .onSentPush):
                return .applicationFetchingSuccess(apps, item)
            default:
                return state
            }
        }
    }
    enum Event {
        case onStart
        case onAbilitiFailed(Error)
        case onAbilitiSuccess
        case onListFetchingFailed(Error)
        case onListFetchingSuccess([DeviceFamily: [DeviceContext]])
        case onDeviceOperation(DeviceContext)
        case onApplicationLoadingFailed(Error)
        case onApplicationLoadingSuccess([ApplicationContext])
        case onRefreshList
        case onSelecctedItem(DeviceContext)
        case onSendingPush(DeviceContext, String, String)
        case onSentPush
        case onEditingPush
        case onEditingEndPush(String)
    }
}

