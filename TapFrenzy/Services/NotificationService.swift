import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let dailyChallengeID = "daily-challenge-notification"

    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleDailyChallenge(at time: DateComponents) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your daily challenge is ready — come beat your best score!"
        content.sound = .default

        var trigger = DateComponents()
        trigger.hour = time.hour
        trigger.minute = time.minute

        let request = UNNotificationRequest(
            identifier: dailyChallengeID,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        center.add(request)
    }

    func cancelDailyChallenge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])
    }
}
