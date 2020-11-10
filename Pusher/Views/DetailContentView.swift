//
//  DetailContentView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI
import Terminal

struct DetailContentView: View {
    private var apps: [ApplicationContext] = [ApplicationContext.default]
    private var viewModel: ViewModel
    @State private var isEditPresented = false
    @State private var pickerIndex = 0
    
    init(_ application: [ApplicationContext]?, viewModel: ViewModel) {
        self.apps = application ?? [ApplicationContext.default]
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center) {
            VStack(alignment: .center) {
                Picker(selection: $pickerIndex, label: Text(Constant.selectbundle.message)
                    .opacity(Double((apps.count <= 1) ? 0.5 : 1.0)).font(.subheadline)) {
                        ForEach(0..<apps.count, id: \.self) { index in
                            Text(self.apps[index].displayName)
                                .foregroundColor(Color.primary)
                        }
                }
            }
            .background(Color.clear)
            .padding(32)
            Spacer().frame(maxHeight: 20)
            TextView(text: self.viewModel.pushPayload, isEditable: false)
                .opacity(Double((apps.count <= 1) ? 0.5 : 1.0))
                .frame(minHeight: 150, maxHeight: 200)
                .padding(32)
            Spacer().frame(maxHeight: 40)
            HStack(spacing: 10)  {
                Button(Constant.editPush.message, action: { self.isEditPresented.toggle() })
                    .disabled(apps.count <= 1)
                    .buttonStyle(BorderedButtonStyle())
                    .frame(minWidth:150)
                    .background(Color.clear)
                    .sheet(isPresented: $isEditPresented) {
                        EditPayLoadView(viewModel: self.viewModel)
                            .frame(minWidth: 700, maxWidth: 800, minHeight: 500, maxHeight: 550)
                }
                Spacer()
                Button(Constant.sendPush.message, action: {
                    self.viewModel.send(event: ViewModel.Event.onSendingPush(self.viewModel.selectedDeviceContext!, self.apps[self.pickerIndex].bundleIdentifier, self.viewModel.pushPayload))
                }).disabled(apps.count <= 1)
                    .buttonStyle(BorderedButtonStyle())
                    .frame(minWidth:100)
                    .layoutPriority(1)
            }
            .background(Color.clear)
            .padding(32)
            Spacer()
        }
        .frame(maxWidth: 500)
        .background(Color(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0))
        .cornerRadius(5)
        .shadow(radius: 0.2)
        .disabled(apps.count <= 1)
    }
}

struct DetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        DetailContentView([ApplicationContext.default], viewModel: ViewModel())
    }
}

