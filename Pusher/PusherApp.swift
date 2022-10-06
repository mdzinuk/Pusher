//
//  PusherApp.swift
//  Pusher
//
//  Created by Mohammad Arafat Hossain on 29/09/22.
//

import SwiftUI

@main
struct PusherApp: App {
    var body: some Scene {
        WindowGroup {
            SplitView(viewModel: ViewModel())
        }
    }
}
