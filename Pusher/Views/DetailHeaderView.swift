//
//  DetailHeaderView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI
import Terminal

struct DetailHeaderView: View {
    var viewModel: ViewModel
    var selectedDevice: DeviceContext?
    
    init(model: ViewModel, current device: DeviceContext?) {
        self.viewModel = model
        self.selectedDevice = device
    }
    
    var body: some View {
        guard let device = selectedDevice else { return PusherActivityView().eraseToAnyView() }
        return createBodyFor(device).eraseToAnyView()
    }
    private func createBodyFor(_ device: DeviceContext) -> some View {
        return HStack(alignment: VerticalAlignment.center, spacing: 8) {
            HStack(alignment: VerticalAlignment.center, spacing: 16) {
                Image(nsImage: device.image)
                    .resizable()
                    .frame(width: 64.0, height: 64)
                    .shadow(color: .gray, radius: 2, x: 1, y: 0)
                    .blendMode(.colorBurn).scaledToFit()
                VStack(alignment: .leading) {
                    Text(device.name)
                        .foregroundColor(Color.orange)
                        .frame(maxWidth: 400, minHeight: 30, alignment: .topLeading)
                        .background(Color.clear)
                        .font(.title)
                        .lineLimit(1)
                    Text("\(device.family.displayName)(\(device.udid))")
                        .foregroundColor(Color.black)
                        .background(Color.clear)
                }
                Button(device.state == .booted ? Constant.close.message : Constant.activate.message, action: {
                    self.viewModel.send(event: ViewModel.Event.onDeviceOperation(device))
                }).buttonStyle(BorderedButtonStyle())
                    .shadow(color: .gray, radius: 2, x: 1, y: 0)
                    .blendMode(.normal)
            }
        }.padding(16)
    }
}

struct DetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DetailHeaderView(model: ViewModel(), current: DeviceContext.`default`)
    }
}

