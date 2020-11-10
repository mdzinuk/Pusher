//
//  PusherActivityView.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import SwiftUI

struct PusherActivityView: View {
    var notes: String?
    var body: some View {
        return GeometryReader { (geometry) in
            return VStack(alignment: HorizontalAlignment.center, spacing: 0) {
                Spacer(minLength: geometry.size.height/CGFloat(2.0) - 50)
                self.content(self.notes, geometry: geometry)
                Spacer(minLength: geometry.size.height/2 - 50)
            }
            .padding([.all])
            .border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
    func content(_ data: String? = nil, geometry: GeometryProxy ) -> some View {
        guard let note = data else {
            return HStack(alignment: .center, spacing: 0) {
                Spacer(minLength: geometry.size.width/2 - 50)
                ActivityIndicatorView()
                Spacer(minLength: geometry.size.width/2 - 50)
            }.eraseToAnyView()
        }
        return HStack(alignment: .center, spacing: 0) {
            Spacer()
            Text(note).font(.headline).foregroundColor(Color.orange)
            Spacer()
        }.eraseToAnyView()
    }
}
