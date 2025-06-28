//
//  SessionManager.swift
//  FirebaseAuthDemo
//
//  Created by Andrea Consorti on 27/06/25.
//


import Foundation
import Combine
import FirebaseAuth
import FirebaseMessaging

class SessionViewModel: ObservableObject {
    @Published var user: User?
    @Published var token: String?
    @Published var fcmToken: String?
    @Published var errorMessage: String = ""
    
    private var idTokenStateHandle: IDTokenDidChangeListenerHandle?
    
    init() {
        user = Auth.auth().currentUser
        idTokenStateHandle = Auth.auth().addIDTokenDidChangeListener { [weak self] auth, user in
            self?.user = user
            user?.getIDToken(completion: { token, error in
                self?.token = token
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFCMTokenNotification(_:)), name: .didReceiveFCMToken, object: nil)
    }
    
    deinit {
        user = nil
        if let handle = idTokenStateHandle {
            Auth.auth().removeIDTokenDidChangeListener(handle)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleFCMTokenNotification(_ notification: Notification) {
        guard let token = notification.userInfo?["token"] as? String else { return }
        self.fcmToken = token
    }
    
    func login(username: String, password: String) {
        clearData()
        Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.errorMessage = ""
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            authResult?.user.getIDToken { idToken, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            Messaging.messaging().token { token, error in
                if let token = token {
                    FirestoreHelper.shared.saveFCMToken(token)
                    self.fcmToken = token
                }
            }
        }
    }
    
    func logout() {
        guard let userId = user?.uid else { return }
        Messaging.messaging().token { token, error in
            FirestoreHelper.shared.deleteFCMToken(userId: userId) { result in
                switch result {
                case .success:
                    Messaging.messaging().deleteToken { _ in
                        self.signOut()
                    }
                case .failure(let error):
                    self.signOut()
                    print("Error deleting user related tokens: \(error)")
                }
            }
            
            guard let token = token, error == nil else {
                self.signOut()
                return
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.clearData()
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
            print("Error signing out: %@", signOutError)
        }
    }
    
    func clearData() {
        user = nil
        errorMessage = ""
        token = nil
        fcmToken = nil
    }
    
    func getIdToken(_ forceRefresh: Bool = true, completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        user.getIDTokenForcingRefresh(forceRefresh) { token, error in
            completion(token)
        }
    }
}

//Old Version to refresh keychain data management
/*class SessionViewModel: ObservableObject {
    @Published var token: String? {
        didSet {
            if let token = token {
                KeychainHelper.shared.save(Data(token.utf8), service: "FirebaseAuthDemo", account: "userToken")
            } else {
                KeychainHelper.shared.delete(service: "FirebaseAuthDemo", account: "userToken")
            }
        }
    }
    
    @Published var errorMessage: String = ""

    init() {
        
        if let data = KeychainHelper.shared.read(service: "FirebaseAuthDemo", account: "userToken"),
           let storedToken = String(data: data, encoding: .utf8) {
            self.token = storedToken
        } else {
            self.token = nil
        }
    }

    func login(username: String, password: String) {
        
        if username == "admin" && password == "123456" {
            let token = "token_\(username)_12345"
            self.errorMessage = ""
            self.token = token
        }
        else {
            errorMessage = "Wrong Credentials"
        }
    }

    func logout() {
        self.token = nil
    }
}*/
