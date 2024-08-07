//
//  OnboardingView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome to")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            
            Text("Fitness Cats!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: "cat")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, 20)
            
            Text("Sign in or create a new account")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Button(action: {
                // Action for "Go to Sign In"
            }) {
                Text("Go to Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            Button(action: {
                // Action for "Sign Up"
            }) {
                Text("Don’t have an account? Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    OnboardingView()
}

