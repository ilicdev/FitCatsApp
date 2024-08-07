//
//  ProgressView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct ProgressView: View {
    let currentSteps = 48590
    let goalSteps = 63000
    let startDate = "17.4.2023"
    let endDate = "23.4.2023"
    
    var body: some View {
        VStack {
            Text("This week progress")
                .font(.headline)
                .padding(.top, 20)
            
            Text("\(startDate) - \(endDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 5, dash: [5, 5]))
                    .foregroundColor(Color.gray.opacity(0.5))
                    .frame(width: 270, height: 270)
                
                CircularProgressView(progress: Double(currentSteps), total: Double(goalSteps))
                    .frame(width: 200, height: 200)
            }
            
            
            Spacer()
        }
        .padding()
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}

