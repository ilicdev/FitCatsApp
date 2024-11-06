//
//  SignInView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct SignInView: View {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @StateObject var viewModel = FitCatsViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Welcome back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            Image("catImage")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)

            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button(action: {
                viewModel.signIn(email: email, password: password) { error in
                    if let error = error {
                        showError = true
                        errorMessage = error
                    } else {
                        isSignedIn = true
                        UserDefaults.standard.set(true, forKey: "isSignedIn")
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}



