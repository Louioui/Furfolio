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
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
                .border(Color(UIColor.separator))
            
            SecureField("Password", text: $password)
                .padding()
                .border(Color(UIColor.separator))
            
            Button("Login") {
                authenticateUser(username: username, password: password)
            }
            .padding()
            
            if isAuthenticated {
                Text("Successfully Authenticated!")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
    
    func authenticateUser(username: String, password: String) {
        // Here, replace with your actual logic to check credentials
        let storedUsername = "lvconcepcion" // Should be securely stored
        let storedPassword = "jesus2024" // Should be securely hashed and stored
        
        if username == storedUsername && password == storedPassword {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
}
