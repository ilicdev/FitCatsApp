//
//  ProfileView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: FitCatsViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isUserSignedIn: Bool
    
    var user: User

    var body: some View {
        VStack {
            // Profile Header
            HStack {
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title)
                        .bold()
                    Text("\(user.friends.count) Friends")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("This week score: \(user.thisWeekSteps)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    Image(user.currentRank.imageName)
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(user.currentRank.name)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.orange)
                }
            }
            .padding()

            // Rank Achievements Section
            VStack(alignment: .leading) {
                Text("Rank Achievements")
                    .font(.headline)
                    .padding(.bottom, 5)

                HStack(spacing: 10) {
                    ForEach(viewModel.ranks, id: \.name) { rank in
                        VStack {
                            Image(rank.imageName)
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("\(viewModel.rankAchievementCount(for: rank))")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()

            // Add Friends Button
            NavigationLink(destination: FriendsView(viewModel: viewModel, initialTab: "Add New")) {
                Text("Add friends")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding()

            // Sign Out Button
            Button(action: {
                signOut()
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    private func signOut() {
        viewModel.signOut()
        isUserSignedIn = false
        UserDefaults.standard.set(false, forKey: "isSignedIn")
    }
}






