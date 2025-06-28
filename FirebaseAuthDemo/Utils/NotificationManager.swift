//
//  NotificationManager.swift
//  CodeScannerDemo
//
//  Created by Andrea Consorti on 26/06/25.
//


import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    
    init() {
        
    }
    
    func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func getAuthStatus(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { status in
            let permissionGranted: Bool
            switch status.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                permissionGranted = true
            default:
                permissionGranted = false
            }
            
            completion(permissionGranted)
        }
    }
}
