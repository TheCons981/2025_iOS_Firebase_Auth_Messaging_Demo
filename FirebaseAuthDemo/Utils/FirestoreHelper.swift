//
//  FirestoreHelper.swift
//  FirebaseAuthDemo
//
//  Created by Andrea Consorti on 28/06/25.
//

import FirebaseAuth
import FirebaseFirestore

final class FirestoreHelper: @unchecked Sendable  {
    static let shared = FirestoreHelper()
    private init() {}
    
    func saveFCMToken(_ token: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).setData([
            "fcmToken": token
        ], merge: true) { error in
            if let error = error {
                print("Error saving FCM token: \(error)")
            } else {
                print("FCM token saved successfully!")
            }
        }
    }
    
    func fetchFCMToken(userId: String, completion: @escaping (String?, String?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let token = data?["fcmToken"] as? String
                completion(token, nil)
            } else {
                let errorMessage = "User document not found or error: \(error?.localizedDescription ?? "Unknown error")"
                print(errorMessage)
                completion(nil, errorMessage)
            }
        }
    }
    
    func deleteFCMToken(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
