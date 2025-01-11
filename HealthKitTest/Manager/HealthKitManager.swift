//
//  HealthKitManager.swift
//  HealthKitTest
//
//  Created by t&a on 2025/01/11.
//

import HealthKit

class HealthKitManager {
    
    public let healthStore = HKHealthStore()
    
    /// 許可申請項目
    public let allTypes: Set = [
        // ワークアウト
        HKQuantityType.workoutType(),
        // 消費エネルギー
        HKQuantityType(.activeEnergyBurned),
        // サイクリングの移動距離
        HKQuantityType(.distanceCycling),
        // ウォーキング・ランニングの移動距離
        HKQuantityType(.distanceWalkingRunning),
        // 車椅子ユーザーの移動距離
        HKQuantityType(.distanceWheelchair),
        // 心拍数
        HKQuantityType(.heartRate)
    ]
    
    /// HealthKit許可申請要求
    public func requestAuthorization() async {
        do {
            // HealthKitが有効なデバイスかどうか
            guard HKHealthStore.isHealthDataAvailable() else { return }
            print(type(of: allTypes))
            // 許可申請要求
            // プライバシー保護の一環で許可申請の承認/拒否はアプリから識別はできない
            try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
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
        ){ (query, results, error) in
            guard error == nil else { return }
            guard let tmpResults = results as? [HKQuantitySample]  else { return }
            // 総カロリーを計算
            let totalEnergyBurned = tmpResults.reduce(0.0) { sum, sample in
                return sum + sample.quantity.doubleValue(for: .kilocalorie())
            }
            print("総消費カロリー: \(totalEnergyBurned) kcal")
        }
        // クエリ実行
        healthStore.execute(query)
    }

}

