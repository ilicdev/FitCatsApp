//
//  LeaguesView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import SwiftUI

struct LeaguesView: View {
    @ObservedObject var viewModel: FitCatsViewModel
    @State private var selectedTab = "My Leagues"
    @State private var selectedSegment = "Invites"
    @State private var showLeagueDetails = false
    @State private var selectedLeague: League?
    
    var body: some View {
        VStack {
            // Main Tab Picker
            Picker("Tabs", selection: $selectedTab) {
                Text("My Leagues").tag("My Leagues")
                Text("Create New League").tag("Create New League")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == "My Leagues" {
                myLeaguesView
            } else {
                createLeagueView
            }
        }
        .onAppear {
            viewModel.fetchLeagues()
        }
        .navigationTitle("Leagues")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showLeagueDetails) {
            if let league = selectedLeague {
                LeagueDetailView(league: league, viewModel: viewModel)
            }
        }
    }
    
    // MARK: - My Leagues View
    private var myLeaguesView: some View {
        VStack {
            // Sub-Tab Picker for Invites, Active, Completed
            Picker("Segments", selection: $selectedSegment) {
                Text("Invites").tag("Invites")
                Text("Active").tag("Active")
                Text("Completed").tag("Completed")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // List of Leagues based on the selected segment
            ScrollView {
                if selectedSegment == "Invites" {
                    ForEach(viewModel.invites.filter { !$0.participants.contains(viewModel.currentUser?.id ?? "") }) { league in
                        InviteLeagueRow(league: league, onAccept: {
                            viewModel.respondToInvite(leagueID: league.id, accept: true)
                        }, onDecline: {
                            viewModel.respondToInvite(leagueID: league.id, accept: false)
                        })
                    }
                } else if selectedSegment == "Active" {
                    ForEach(viewModel.activeLeagues) { league in
                        ActiveLeagueRow(league: league, onTap: {
                            selectedLeague = league
                            showLeagueDetails = true
                        })
                    }
                } else if selectedSegment == "Completed" {
                    ForEach(viewModel.completedLeagues) { league in
                        CompletedLeagueRow(league: league)
                    }
                }
            }
        }
    }
    
    // MARK: - Create New League View
    private var createLeagueView: some View {
        CreateLeagueForm(viewModel: viewModel)
    }
}

// MARK: - League Row Views

// Row for an invited league with accept/decline buttons
struct InviteLeagueRow: View {
    var league: League
    var onAccept: () -> Void
    var onDecline: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(league.name)
                    .font(.headline)
                Text("Invited by: \(league.createdBy)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onAccept) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            Button(action: onDecline) {
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Row for an active league that can be tapped to view more details
struct ActiveLeagueRow: View {
    var league: League
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(league.name)
                        .font(.headline)
                    Text("Ends in: \(formattedDate(league.endDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack {
                    Text("\(league.participants.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Row for a completed league
struct CompletedLeagueRow: View {
    var league: League
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(league.name)
                    .font(.headline)
                Text("Ended: \(formattedDate(league.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("#\(league.participants.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Create New League Form

struct CreateLeagueForm: View {
    @ObservedObject var viewModel: FitCatsViewModel
    @State private var leagueName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var invitedFriends: [String] = []
    @State private var currentStep = 1
    
    var body: some View {
        VStack {
            Text("Step \(currentStep) of 4")
                .font(.headline)
                .padding(.top)
            
            if currentStep == 1 {
                TextField("League name", text: $leagueName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            } else if currentStep == 2 {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    .padding()
            } else if currentStep == 3 {
                DatePicker("End date", selection: $endDate, displayedComponents: .date)
                    .padding()
            } else if currentStep == 4 {
                List(viewModel.currentUser?.friends ?? [], id: \.self) { friendID in
                    Button(action: {
                        if invitedFriends.contains(friendID) {
                            invitedFriends.removeAll { $0 == friendID }
                        } else {
                            invitedFriends.append(friendID)
                        }
                    }) {
                        HStack {
                            Text(friendID)
                            Spacer()
                            if invitedFriends.contains(friendID) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                if currentStep > 1 {
                    Button("Back") {
                        currentStep -= 1
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentStep < 4 {
                    Button("Next") {
                        currentStep += 1
                    }
                    .padding()
                } else {
                    Button("Create new league") {
                        viewModel.createLeague(name: leagueName, startDate: startDate, endDate: endDate, invitedFriends: invitedFriends)
                        // Reset form
                        leagueName = ""
                        startDate = Date()
                        endDate = Date()
                        invitedFriends = []
                        currentStep = 1
                    }
                    .padding()
                    .disabled(leagueName.isEmpty)
                }
            }
        }
        .padding()
    }
}

