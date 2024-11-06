//
//  DashboardView.swift
//  FitCats
//
//  Created by Milos Ilic on 28.10.24..
//

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @ObservedObject var viewModel: FitCatsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Home")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            // Today's Score
            scoreView(
                title: "Today's score",
                score: viewModel.dailySteps,
                rank: viewModel.currentUser?.currentRank.name ?? "Cat",
                imageName: viewModel.currentUser?.currentRank.imageName ?? "rank1"
            )
            
            // Weekly Progress
            progressView(
                currentSteps: viewModel.weeklySteps,
                nextRank: viewModel.nextRank,
                targetSteps: viewModel.nextRank?.minSteps ?? 10000
            )

            // Last Week's Score
            scoreView(
                title: "Last week",
                score: viewModel.currentUser?.lastWeekSteps ?? 0,
                rank: viewModel.previousRank?.name ?? "Cat",
                imageName: viewModel.previousRank?.imageName ?? "rank1"
            )
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchUser(by: Auth.auth().currentUser?.uid ?? "") { _ in }
            viewModel.startStepUpdates() // Start fetching steps every 3 seconds
        }
    }
    
    // MARK: - Subviews
    
    // Score View for today's score and last week's score
    private func scoreView(title: String, score: Int, rank: String, imageName: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            Spacer()
            VStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(rank)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // Weekly Progress View
    private func progressView(currentSteps: Int, nextRank: Rank?, targetSteps: Int) -> some View {
        VStack {
            Text("This week progress")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("\(formattedWeekDates())")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 15, dash: [10]))
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(Double(currentSteps) / Double(targetSteps)))
                    .stroke(Color.orange, lineWidth: 15)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                
                VStack {
                    Text("\(currentSteps)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Next: \(nextRank?.name ?? "Cat")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
    
    // Helper to format week dates as "MM.dd - MM.dd"
    private func formattedWeekDates() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        let startDate = viewModel.thisWeekStartDate
        let endDate = viewModel.thisWeekEndDate
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

