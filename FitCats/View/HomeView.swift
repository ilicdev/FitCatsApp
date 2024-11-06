//
//  HomeView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = FitCatsViewModel()
    
    var body: some View {
        TabView {
            // About View Placeholder
            AboutView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("About")
                }

            // Leagues View Placeholder
            LeaguesView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leagues")
                }

            // Home (Dashboard) View
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Friends View Placeholder
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }

            // Profile View Placeholder
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

