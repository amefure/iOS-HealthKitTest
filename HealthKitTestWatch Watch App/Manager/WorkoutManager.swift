//
//  WorkoutManager.swift
//  HealthKitTest
//
//  Created by t&a on 2025/01/13.
//

import HealthKit

class WorkoutManager: ObservableObject {
    
    
    @Published var isStart = false
    @Published var isError = false
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    
    /// 書き込み許可申請項目
    public let writeAllTypes: Set = [
        // ワークアウト
        HKQuantityType.workoutType()
    ]
    
    /// 読み取り許可申請項目
    public let readAllTypes: Set = [
        // 消費エネルギー
        HKQuantityType(.activeEnergyBurned),
        // サイクリングの移動距離
        HKQuantityType(.distanceCycling),
        // ウォーキング・ランニングの移動距離
        HKQuantityType(.distanceWalkingRunning),
        // 車椅子ユーザーの移動距離
        HKQuantityType(.distanceWheelchair),
        // 心拍数
        HKQuantityType(.heartRate),
        // ワークアウト
        HKQuantityType.workoutType()
    ]
    
    /// HealthKit許可申請要求
    public func requestAuthorization() async {
        do {
            // HealthKitが有効なデバイスかどうか
            guard HKHealthStore.isHealthDataAvailable() else { return }
            // 許可申請要求
            // プライバシー保護の一環で許可申請の承認/拒否はアプリから識別はできない
            try await healthStore.requestAuthorization(toShare: writeAllTypes, read: readAllTypes)
        } catch {
            // 失敗するのはアプリのInfo.plistの設定不足
            // もしくは現在のデバイスで健康データが利用できない場合
            fatalError("承認を要求中に予期しないエラーが発生しました： \(error.localizedDescription)")
        }
    }
    

    public func start() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
//            session.delegate = self
//            builder.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        } catch {
            // Handle failure here.
            return
        }
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { [weak self] (success, error) in
            guard let self else { return }
            
            guard success else {
                // Handle errors.
                self.isError = true

                print("ワークアウト開始失敗：", error)
                return
            }
            self.isStart = true
            print("ワークアウト開始成功")
        }
    }
    
    public func stop() {
        self.isStart = false
        session?.pause()
    }
    
    public func resume() {
        self.isStart = true
        session?.resume()
    }
    
    public func end() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { [weak self] (success, error) in
            guard let self else { return }
            
            guard success else {
                print("ワークアウト終了失敗：", error)
                return
            }
            
            self.builder?.finishWorkout { [weak self]  (workout, error) in
                guard let self else { return }
                
                guard workout != nil else {
                    print("ワークアウト終了失敗：", error)
                    return
                }

                print("ワークアウト終了")
            }
        }
    }
}

