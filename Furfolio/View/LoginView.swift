//
//  LoginView.swift
//  Furfolio
//
//  Created by mac on 11/27/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAuthenticated = false
    @State private var authenticationError: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Furfolio")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            Button(action: {
                authenticateUser(username: username, password: password)
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            if let error = authenticationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 10)
            }
            
            if isAuthenticated {
                Text("Successfully Authenticated!")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .padding()
    }
    
    func authenticateUser(username: String, password: String) {
        // Example: Replace with actual secure authentication logic
        let storedCredentials: [String: String] = [
            "lvconcepcion": "jesus2024" // Replace this with securely stored and hashed credentials
        ]
        
        if let storedPassword = storedCredentials[username], storedPassword == password {
            isAuthenticated = true
            authenticationError = nil
        } else {
            isAuthenticated = false
            authenticationError = "Invalid username or password. Please try again."
        }
    }
}
