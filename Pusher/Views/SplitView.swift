//
//  SplitView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI
import Terminal

struct SplitView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        contentView
            .onAppear { self.viewModel.send(event: .onStart) }
            .frame(minWidth: 800, maxWidth: 900, minHeight: 600, maxHeight: 700)
    }
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .checkingAbiliti, .listFetching:
            return PusherActivityView().eraseToAnyView()
        case .showingItems, .applicationFetching(_):
            return contentView().eraseToAnyView()
        case .selectItem(_, let apps):
            return contentView(apps).eraseToAnyView()
        case .applicationFetchingSuccess(let apps, _):
            return contentView(apps).eraseToAnyView()
        case .sendPushNotification(let apps, _, _, _):
            return contentView(apps).eraseToAnyView()
        case .deviceOperattion(_):
            return contentView(nil, true).eraseToAnyView()
        default:
            return PusherActivityView(notes: Constant.xcodeFailed.message).transition(AnyTransition.slide.combined(with: .opacity)) .eraseToAnyView()
        }
    }
    private func onSelectMenu(_ item: DeviceContext) {
        viewModel.send(event: ViewModel.Event.onSelecctedItem(item))
    }
    private func contentView(_ apps: [ApplicationContext]? = nil,
                             _ showAnimation: Bool = false) -> some View {
        return HSplitView { masterView()
            detailView(apps, showAnimation)}.eraseToAnyView()
    }
    private func masterView() -> some View {
        return List {
            ForEach(viewModel.deviceList.keys.sorted(), id: \.self) { key in
                Section(header: Text("\(key.displayName)").frame(minHeight: 38)) {
                    ForEach(self.viewModel.deviceList[key]!, id: \.self) { (row) in
                        HStack(spacing: 6) {
                            Image(nsImage: NSImage(named: ((row.state == .booted) ?
                                NSImage.statusAvailableName : ((row.state == .shutdown) ? NSImage.statusUnavailableName :
                                    NSImage.statusPartiallyAvailableName)))! )
                                .aspectRatio(1.0, contentMode: .fill)
                                .frame(maxWidth: 6, maxHeight: 6).padding(.horizontal, 2)
                            Image(nsImage: row.image)
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(maxWidth: 24)
                            Text("\(row.name)")
                                .padding(2)
                                .foregroundColor(Color.black)
                                .font(.caption)
                        }.onTapGesture { self.onSelectMenu( row) }
                            .buttonStyle(BorderedButtonStyle())
                            .padding(.leading, 3)
                            .frame(maxHeight: 34)
                    }
                }.foregroundColor(Color.orange)
                    .font(.callout)
            }
        }.listStyle(SidebarListStyle())
            .blur(radius: -0.7)
            .zIndex(/*@START_MENU_TOKEN@*/8.0/*@END_MENU_TOKEN@*/)
            .frame(minWidth: 200, maxWidth: 300)
    }
    private func detailView(_ apps: [ApplicationContext]? = nil,
                            _ isAnimating: Bool = false) -> some View {
        guard viewModel.selectedDeviceContext != nil else {
            return PusherActivityView(notes: isAnimating ? nil : Constant.selectItem.message).eraseToAnyView()
        }
        return DetailView(with: viewModel, and: apps).eraseToAnyView()
    }
}


struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView(viewModel: ViewModel())
    }
}


