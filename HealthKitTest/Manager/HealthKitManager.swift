//
//  HealthKitManager.swift
//  HealthKitTest
//
//  Created by t&a on 2025/01/11.
//

import HealthKit

class HealthKitManager: ObservableObject {
    
    /// 消費カロリー
    @Published private(set) var kilocalorie: Double = 0
    
    // MARK　特性
    /// 性別
    @Published private(set) var biologicalSex: HKBiologicalSex = .notSet
    /// 年齢
    @Published private(set) var age: Int = 0
    /// 血液型
    @Published private(set) var bloodType: HKBloodType = .notSet
    
    public let healthStore = HKHealthStore()
    
    /// 書き込み許可申請項目
    public let writeAllTypes: Set = [
        // 歩数
        HKQuantityType(.stepCount),
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
    
    /// 読み取り許可申請項目
    public let readAllTypes: Set = [
        // 性別
        HKCharacteristicType(.biologicalSex),
        // 血液型
        HKCharacteristicType(.bloodType),
        // 誕生日
        HKCharacteristicType(.dateOfBirth),
        // 歩数
        HKQuantityType(.stepCount),
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
    
    public func reading() {
        // 昨日の開始時刻と終了時刻を計算
        let calendar = Calendar.current
        // 昨日の開始時刻
        let startOfYesterday = calendar.startOfDay(for: Date().addingTimeInterval(-86400))
        // 昨日の終了時刻（開始時刻 + 1日）
        guard let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday) else { return }
        
        // 取得したいデータタイプ
        let type = HKQuantityType(.activeEnergyBurned)
        // 取得対象期間 Date型
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: endOfYesterday, options: [])
        // 取得数制限 HKObjectQueryNoLimit = 無制限
        let limit = HKObjectQueryNoLimit
        // 並び順
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        
        // データ読み出しクエリ
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sort
        ) { [weak self] (query, results, error) in
            guard let self else { return }
            guard error == nil else { return }
            guard let tmpResults = results as? [HKQuantitySample]  else { return }
            // 総カロリーを計算
            let totalEnergyBurned = tmpResults.reduce(0.0) { sum, sample in
                return sum + sample.quantity.doubleValue(for: .kilocalorie())
            }
            print("総消費カロリー: \(totalEnergyBurned) kcal")
            self.kilocalorie = totalEnergyBurned
        }
        // クエリ実行
        healthStore.execute(query)
        readCharacteristic()
    }

    /// 特性情報を取得
    public func readCharacteristic() {
        // 性別を取得
        guard let biologicalSex = try? healthStore.biologicalSex().biologicalSex else { return }
        self.biologicalSex = biologicalSex
        switch biologicalSex {
        case .female:
            print("性別: 女性")
        case .male:
            print("性別: 男性")
        case .other:
            print("性別: その他")
        case .notSet:
            print("性別: 未設定")
        @unknown default:
            print("性別: 不明")
        }
       
        // 年齢を計算
        guard let dateOfBirth = try? healthStore.dateOfBirthComponents().date else { return }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        guard let age = ageComponents.year else { return }
        print("年齢: \(age) 歳")
        self.age = age

        // 血液型を取得
        guard let bloodType = try? healthStore.bloodType().bloodType else { return }
        self.bloodType = bloodType
        switch bloodType {
        case .aPositive:
            print("血液型: A+")
        case .aNegative:
            print("血液型: A-")
        case .bPositive:
            print("血液型: B+")
        case .bNegative:
            print("血液型: B-")
        case .abPositive:
            print("血液型: AB+")
        case .abNegative:
            print("血液型: AB-")
        case .oPositive:
            print("血液型: O+")
        case .oNegative:
            print("血液型: O-")
        case .notSet:
            print("血液型: 未設定")
        @unknown default:
            print("血液型: 不明")
        }
    }
}

