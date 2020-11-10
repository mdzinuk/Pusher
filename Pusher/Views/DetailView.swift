//
//  DetailView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI
import Terminal

struct DetailView: View {
    var viewModel: ViewModel
    private var applications: [ApplicationContext]?
    private(set) var context: DeviceContext?
    
    init(with viewModel: ViewModel, and applications: [ApplicationContext]?) {
        self.viewModel = viewModel
        self.applications = applications
        self.context = viewModel.selectedDeviceContext
    }
    var body: some View {
        return GeometryReader { (geometry) in
            return VStack(alignment: HorizontalAlignment.center, spacing: 32) {
                DetailHeaderView(model: self.viewModel, current: self.context)
                DetailContentView(self.applications, viewModel: self.viewModel)
            }
        }.padding([.leading, .trailing, .bottom])
            .border(Color.white, width: 1)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(with: ViewModel(), and: nil)
    }
}

