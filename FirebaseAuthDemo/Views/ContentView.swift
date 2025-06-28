//
//  ContentView.swift
//  FirebaseAuthDemo
//
//  Created by Andrea Consorti on 27/06/25.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var session = SessionViewModel()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            if session.user != nil {
                HomeView()
                    .environmentObject(session)
                    .onAppear() {
                        notificationManager.request()
                    }
            }
            else {
                LoginView()
                    .environmentObject(session)
            }
            
            if !session.errorMessage.isEmpty {
                Text("Login Error: \(session.errorMessage)")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
