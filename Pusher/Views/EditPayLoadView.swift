//
//  EditPayLoadView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI


struct EditPayLoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private(set) var pushdata = ""
    
    var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self._pushdata = State(initialValue: viewModel.pushPayload)
    }
    
    var body: some View {
        return GeometryReader { (geometry) in
            VStack(alignment: HorizontalAlignment.center) {
                Spacer()
                Text(Constant.editPayload.message)
                    .foregroundColor(Color.black)
                    .background(Color.clear)
                    .font(.headline)
                Spacer()
                VStack(alignment: HorizontalAlignment.center) {
                    TextView(text: self.$pushdata, isEditable: true)
                        .padding()
                        .frame(width: (geometry.size.width - 100.00), height: (geometry.size.height - 100.0), alignment: .leading)
                        .background(Color.clear)
                    
                }.background(Color(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0))
                    .cornerRadius(5)
                    .shadow(radius: 0.2)
                Spacer()
                Button(Constant.update.message, action: {
                    self.viewModel.send(event: ViewModel.Event.onEditingEndPush(self.pushdata))
                    self.presentationMode.wrappedValue.dismiss()
                }).disabled(!self.viewModel.isValidPayload(self.pushdata))
                    .buttonStyle(BorderedButtonStyle())
                    .shadow(color: .black, radius: 10, x: 5, y: 0)
                    .blendMode(.normal)
                Spacer()
            }
        }
    }
}


struct EditPayLoadView_Previews: PreviewProvider {
    static var previews: some View {
        EditPayLoadView(viewModel: ViewModel())
    }
}

