//
//  RootView.swift
//  FitCats
//
//  Created by Milos Ilic on 31.10.24..
//

import Foundation
import SwiftUI

struct RootView: View {
    @StateObject var viewModel = FitCatsViewModel()

    var body: some View {
        if viewModel.isSignedIn {
            HomeView(viewModel: viewModel)
        } else {
            OnboardingView(viewModel: viewModel)
        }
    }
}
