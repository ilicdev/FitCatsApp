//
//  HomeView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import Foundation
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FitCatsViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                AboutView()
            }
            .tabItem {
                Image(systemName: "pawprint.fill")
                Text("About")
            }
            
            NavigationStack {
                LeaguesView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Leagues")
            }
            
            NavigationStack {
                FriendsView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Friends")
                
            }
            
            NavigationStack {
                if let user = viewModel.currentUser {
                    ProfileView(viewModel: viewModel, isUserSignedIn: $viewModel.isSignedIn, user: user)
                } else {
                    Text("Loading Profile...")
                }
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .onAppear {
            viewModel.fetchLeagues()
            // Fetch leagues data when HomeView appears
        }
    }
}



