//
//  AppDelegate.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect.zero,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: true)
        window.center()
        window.setFrameAutosaveName("Terminal")
        window.title = Constant.appName.message
        window.isMovableByWindowBackground = true
        window.contentView = NSHostingView(rootView: SplitView(viewModel: ViewModel()))
        window.makeKeyAndOrderFront(nil)
    }
    func applicationWillTerminate(_ aNotification: Notification) {}
}
