//
//  LoginView.swift
//  FirebaseAuthDemo
//
//  Created by Andrea Consorti on 27/06/25.
//


import SwiftUI

struct HomeView: View {
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        VStack {
            Text("Welcome, \(session.user?.email ?? "")!")
                .font(.title2)
            
            Text("Token: \(session.token ?? "")")
                .lineLimit(3)
                .truncationMode(.middle)
                .textSelection(.enabled)
            Divider()
            if let fcmToken = session.fcmToken {
                Text("FCM Token: \(fcmToken)")
                    .lineLimit(3)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
            
            
            Button("Logout") {
                session.logout()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

        }
        .padding()
    }
}
