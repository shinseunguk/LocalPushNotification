//
//  ViewController.swift
//  LocalPushNotification
//
//  Created by ukseung.dev on 2/1/24.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

enum PushNotificationType {
    case repeatYearly
    case repeatMonthly
    case repeatWeekly
    case repeatDaily
    
    var identifier: String {
        switch self {
        case .repeatYearly:
            return "연간 반복 알림"
        case .repeatMonthly:
            return "매월 반복 알림"
        case .repeatWeekly:
            return "매주 반복 알림"
        case .repeatDaily:
            return "매일 반복 알림"
        }
    }
}

enum Calendar {
    case month
    case day
    case weekday
    case hour
    case minute
    
    var value: Int {
        switch self {
        case .month:
            return 2
        case .day:
            return 16
        case .weekday:
            return 6
        case .hour:
            return 15
        case .minute:
            return 56
        }
    }
}

class ViewController: UIViewController {
    
    private let disposeBag: DisposeBag = .init()
    
    private let stackView = UIStackView().then {
        $0.layer.borderWidth = 1
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private lazy var yearlyButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        $0.setTitle(PushNotificationType.repeatYearly.identifier, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.configuration?.cornerStyle = .capsule
    }
    
    private lazy var monthlyButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        $0.setTitle(PushNotificationType.repeatMonthly.identifier, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.configuration?.cornerStyle = .capsule
    }
    
    private lazy var weeklyButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        $0.setTitle(PushNotificationType.repeatWeekly.identifier, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.configuration?.cornerStyle = .capsule
    }
    
    private lazy var dailyButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        $0.setTitle(PushNotificationType.repeatDaily.identifier, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.configuration?.cornerStyle = .capsule
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension ViewController {
    func setupSubviews() {
        view.backgroundColor = .white
        
        [
            stackView
        ].forEach { view.addSubview($0) }
        
        [
            yearlyButton,
            monthlyButton,
            weeklyButton,
            dailyButton
        ].forEach { stackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(5)
            $0.leading.trailing.equalToSuperview()
        }
        
        [
            yearlyButton,
            monthlyButton,
            weeklyButton,
            dailyButton
        ].forEach {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(80)
            }
        }
    }
    
    func setupBindings() {
        yearlyButton.rx.tap
            .bind { [weak self] in
                self?.scheduleNotificationAtSpecificTime(
                    type: PushNotificationType.repeatYearly,
                    month: Calendar.month.value,
                    day: Calendar.day.value,
                    weekday: nil,
                    hourMinute: (Calendar.hour.value, Calendar.minute.value)
                )
            }
            .disposed(by: disposeBag)
        
        monthlyButton.rx.tap
            .bind { [weak self] in
                
            }
            .disposed(by: disposeBag)
        
        weeklyButton.rx.tap
            .bind { [weak self] in
                
            }
            .disposed(by: disposeBag)
        
        dailyButton.rx.tap
            .bind { [weak self] in
                self?.scheduleNotificationAtSpecificTime(
                    type: PushNotificationType.repeatDaily,
                    month: nil,
                    day: nil,
                    weekday: nil,
                    hourMinute: (Calendar.hour.value, Calendar.minute.value)
                )
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    
    func scheduleNotificationAtSpecificTime(type: PushNotificationType, month: Int?, day: Int?, weekday: Int?, hourMinute: (Int, Int)) {
        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "Local Push Notification"
        content.body = "\(type.identifier) \(hourMinute.0)시 \(hourMinute.1)분 푸시알림"
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        
        if let month = month {
            dateComponents.month = month
        }
        
        if let day = day {
            dateComponents.day = day
        }
        
        if let weekday = weekday {
            dateComponents.weekday = weekday
        }
        
        dateComponents.hour = hourMinute.0
        dateComponents.minute = hourMinute.1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 알림 요청 생성
        let request = UNNotificationRequest(
            identifier: type.identifier,
            content: content,
            trigger: trigger
        )
        
        // 알림 스케줄링
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("로컬 푸시 알림 스케줄링 실패: \(error)")
            } else {
                print("\(type.identifier), 로컬 푸시 알림이 성공적으로 스케줄링됨 \(month) \(day) \(weekday) \(hourMinute.0)시 \(hourMinute.1)분")
            }
        }
    }
    
    func timeIntervalNotification() {
        // UNTimeIntervalNotificationTrigger 생성
        let timeInterval: TimeInterval = 90
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)

        // 알림 내용 설정
        let content = UNMutableNotificationContent()
        content.title = "주기적인 알림"
        content.body = "30분뒤 푸시"
        content.sound = UNNotificationSound.default

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: "TimeIntervalNotification", content: content, trigger: timeTrigger)

        // 알림 스케줄링
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("로컬 푸시 알림 스케줄링 실패: \(error)")
            } else {
                print("로컬 푸시 알림이 성공적으로 스케줄링됨")
            }
        }
    }
}

