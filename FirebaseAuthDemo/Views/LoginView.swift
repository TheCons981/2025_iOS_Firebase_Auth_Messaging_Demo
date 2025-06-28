//
//  LoginView.swift
//  FirebaseAuthDemo
//
//  Created by Andrea Consorti on 27/06/25.
//


import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionViewModel
    
    var body: some View {
        VStack() {
            
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Login") {
                session.login(username: username, password: password)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
