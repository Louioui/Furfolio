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
    @State private var showPassword = false  // State to toggle password visibility
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(NSLocalizedString("Welcome to Furfolio", comment: "Welcome message on login screen"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
                .accessibilityAddTraits(.isHeader)
            
            // Username Input
            TextField(NSLocalizedString("Username", comment: "Placeholder for username input"), text: $username)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .accessibilityLabel(NSLocalizedString("Username", comment: "Accessibility label for username field"))
            
            // Password Input with visibility toggle
            HStack {
                if showPassword {
                    TextField(NSLocalizedString("Password", comment: "Placeholder for password input"), text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .accessibilityLabel(NSLocalizedString("Password", comment: "Accessibility label for password field"))
                } else {
                    SecureField(NSLocalizedString("Password", comment: "Placeholder for password input"), text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .accessibilityLabel(NSLocalizedString("Password", comment: "Accessibility label for password field"))
                }
                
                Button(action: {
                    showPassword.toggle()  // Toggle password visibility
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
                .accessibilityLabel(NSLocalizedString("Toggle password visibility", comment: "Accessibility label for password visibility toggle"))
            }

            // Login Button
            Button(action: {
                authenticateUser(username: username, password: password)
            }) {
                Text(NSLocalizedString("Login", comment: "Button label for logging in"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .accessibilityLabel(NSLocalizedString("Login Button", comment: "Accessibility label for login button"))
            }
            
            // Authentication Error Message
            if let error = authenticationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 10)
                    .accessibilityLabel(NSLocalizedString("Error Message", comment: "Accessibility label for error message"))
            }
            
            // Successful Authentication Message
            if isAuthenticated {
                Text(NSLocalizedString("Successfully Authenticated!", comment: "Message for successful login"))
                    .foregroundColor(.green)
                    .font(.headline)
                    .accessibilityLabel(NSLocalizedString("Success Message", comment: "Accessibility label for success message"))
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
    
    /// Authenticates the user with provided credentials
    func authenticateUser(username: String, password: String) {
        // Example: Replace with actual secure authentication logic (e.g., using a backend service)
        let storedCredentials: [String: String] = [
            "lvconcepcion": "jesus2024" // Replace this with securely stored and hashed credentials
        ]
        
        // Check if username exists in the dictionary and the password matches
        if let storedPassword = storedCredentials[username], storedPassword == password {
            isAuthenticated = true
            authenticationError = nil
        } else {
            isAuthenticated = false
            authenticationError = NSLocalizedString("Invalid username or password. Please try again.", comment: "Error message for invalid login credentials")
        }
    }
}
