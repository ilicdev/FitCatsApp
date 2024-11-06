//
//  FitCatsApp.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI
import Firebase

@main
struct FitCatsApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
