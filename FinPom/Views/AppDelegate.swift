//  AppDelegate.swift
//  FinPom
//
//  Created by Adrian Alfajri on 07/04/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // Set delegate agar notifikasi muncul saat app sedang terbuka
        UNUserNotificationCenter.current().delegate = self

        // Minta izin notifikasi dari user
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Gagal meminta izin notifikasi: \(error.localizedDescription)")
            } else {
                print("✅ Izin notifikasi diberikan: \(granted)")
            }
        }

        // Menambahkan kategori untuk notifikasi
        let breakNotificationCategory = UNNotificationCategory(identifier: "BREAK_NOTIFICATION", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([breakNotificationCategory])

        return true
    }

    // Tampilkan notifikasi sebagai banner meski app sedang terbuka
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // Metode delegate untuk interaksi notifikasi di masa depan (opsional)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response
        completionHandler()
    }
}
