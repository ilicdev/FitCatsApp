//
//  SignInView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct SignInView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Action for back button
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .padding()
                }
                Spacer()
            }
            
            Spacer()
            
            Text("Welcome back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Image(systemName: "cat")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Username")
                    .font(.headline)
                
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Text("Password")
                    .font(.headline)
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Toggle(isOn: $rememberMe) {
                    Text("Remember me")
                }
                .padding(.top, 10)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Action for "Sign In"
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    SignInView()
}

