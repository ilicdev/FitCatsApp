//
//  FriendsView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var viewModel: FitCatsViewModel
    @State private var searchText = ""
    @State private var selectedUser: User?
    @State private var selectedTab: String // Use @State here

    init(viewModel: FitCatsViewModel, initialTab: String = "My friends") {
        self.viewModel = viewModel
        // Set initial value in _selectedTab with State's wrapper for custom initial value
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        VStack {
            // Segmented Picker
            Picker("Tabs", selection: $selectedTab) {
                Text("My friends").tag("My friends")
                Text("Add New").tag("Add New")
                Text("Requests").tag("Requests")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Search Bar
            TextField("Search by username...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Content based on selected tab
            if selectedTab == "My friends" {
                friendsListView
            } else if selectedTab == "Add New" {
                addNewFriendsView
            } else {
                friendRequestsView
            }
        }
        .sheet(item: $selectedUser) { user in
            ProfileView(viewModel: viewModel, isUserSignedIn: $viewModel.isSignedIn, user: user) // Pass necessary parameters
        }
        .onAppear {
            if selectedTab == "Add New" {
                viewModel.fetchAllUsers() // Ensure fetching all users when on Add New tab
            }
        }
    }
    
    // MARK: - My Friends View
    private var friendsListView: some View {
        VStack(alignment: .leading) {
            Text("Sorted by: Default")
                .font(.caption)
                .padding(.horizontal)
            
            ScrollView {
                ForEach(viewModel.filteredFriends(searchText: searchText), id: \.id) { friend in
                    FriendRow(friend: friend, actionIcon: "xmark.circle.fill", actionColor: .red) {
                        viewModel.removeFriend(friendID: friend.id)
                    }
                    .onTapGesture {
                        selectedUser = friend
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Add New Friends View
    private var addNewFriendsView: some View {
        VStack(alignment: .leading) {
            Text("Sorted by: Default")
                .font(.caption)
                .padding(.horizontal)
            
            ScrollView {
                ForEach(viewModel.filteredUsers(searchText: searchText), id: \.id) { user in
                    FriendRow(friend: user, actionIcon: "plus.circle.fill", actionColor: .blue) {
                        viewModel.sendFriendRequest(to: user.id)
                    }
                    .onTapGesture {
                        selectedUser = user
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Friend Requests View
    private var friendRequestsView: some View {
        VStack(alignment: .leading) {
            Text("Sorted by: Default")
                .font(.caption)
                .padding(.horizontal)
            
            ScrollView {
                ForEach(viewModel.filteredRequests(searchText: searchText), id: \.id) { request in
                    HStack {
                        FriendRow(friend: request)
                        
                        Button(action: {
                            viewModel.acceptFriendRequest(from: request.id)
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        
                        Button(action: {
                            viewModel.declineFriendRequest(from: request.id)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                    .onTapGesture {
                        selectedUser = request
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - FriendRow Component
struct FriendRow: View {
    var friend: User
    var actionIcon: String? = nil
    var actionColor: Color? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(friend.username)
                    .font(.headline)
                Text("\(friend.thisWeekSteps) steps")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(friend.currentRank.imageName)
                .resizable()
                .frame(width: 40, height: 40)
            
            if let icon = actionIcon, let color = actionColor, let action = action {
                Button(action: action) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
}



