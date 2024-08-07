//
//  CircularProgressView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var total: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / self.total, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(red: 241/255, green: 223/255, blue: 187/255))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            VStack {
                Text("\(Int(progress))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Next: Leopard")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 48590, total: 63000)
            .frame(width: 200, height: 200)
    }
}

