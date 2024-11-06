//
//  SignUpView.swift
//  FitCats
//
//  Created by Milos Ilic on 7.8.24..
//

import SwiftUI

struct SignUpView: View {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @StateObject var viewModel = FitCatsViewModel()
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Create new Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            Image("catImage") // Replace with your cat image
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)

            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button {
                guard password == confirmPassword else {
                    showError = true
                    errorMessage = "Passwords do not match"
                    return
                }

                viewModel.signUp(username: username, email: email, password: password) { error in
                    if let error = error {
                        showError = true
                        errorMessage = error
                    } else {
                        isSignedIn = true
                        UserDefaults.standard.set(true, forKey: "isSignedIn")
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding()

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}



