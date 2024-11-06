//
//  LeagueDetailView.swift
//  FitCats
//
//  Created by Milos Ilic on 31.10.24..
//

import SwiftUI

struct LeagueDetailView: View {
    var league: League
    @ObservedObject var viewModel: FitCatsViewModel

    var body: some View {
        VStack {
            // Display League Name and Date
            Text(league.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Ends on \(formattedDate(league.endDate))")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            // Participants List
            Text("Participants")
                .font(.headline)
                .padding(.bottom, 5)
            
            List(league.participants, id: \.self) { participantID in
                if let user = viewModel.allUsers.first(where: { $0.id == participantID }) {
                    HStack {
                        Text(user.username)
                        Spacer()
                        Text("Steps: \(user.thisWeekSteps)")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Leaderboard Section
            Text("Leaderboard")
                .font(.headline)
                .padding(.top, 20)
            
            List(viewModel.leaderboard) { entry in
                HStack {
                    Text(entry.name)
                    Spacer()
                    Text("\(entry.steps) steps")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.fetchLeaderboard(for: league)
        }
        .padding()
        .navigationTitle("League Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LeagueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLeague = League(
            id: "sample-id",
            name: "Sample League",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            participants: ["user1", "user2"],
            isActive: true,
            createdBy: "user1"
        )
        let viewModel = FitCatsViewModel()
        LeagueDetailView(league: sampleLeague, viewModel: viewModel)
    }
}

