//
//  HealthKitManager.swift
//  DLW25
//
//  Created by Brandon Kang on [Date].
//

import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    // MARK: - Quantity & Category Types
    
    // Basic Metrics (Age and Sex are obtained using HealthKit’s built‑in methods)
    
    // Activity
    let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
    let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!  // in minutes
    let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    let distanceWalkingRunningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    let flightsClimbedType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
    
    // Body Measurements
    let bodyTemperature = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
    let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
    let bmiType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
    let bodyFatPercentageType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
    let leanBodyMassType = HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!
    
    // Hearing
    let environmentalSoundType = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
    let headphoneAudioType = HKQuantityType.quantityType(forIdentifier: .headphoneAudioExposure)!
    // Environmental Sound Reduction and Noise Notifications are not provided by HealthKit.
    
    // Heart
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
    let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!  // used for Cardio Fitness
    // Walking Heart Rate Average, Cardio Recovery, and High Heart Rate Notifications are not provided.
    
    // Sleep
    let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    // MARK: - Additional (Not Directly Implemented) Metrics
    
    // These methods return nil, so the UI can show “N/A”
    func fetchPhysicalEffort(completion: @escaping (Double?) -> Void) { completion(nil) }
    func fetchTimeInDaylight(completion: @escaping (Double?) -> Void) { completion(nil) }
    func fetchWorkoutsCount(completion: @escaping (Int?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
            if let workouts = results as? [HKWorkout] {
                completion(workouts.count)
            } else {
                completion(nil)
            }
        }
        healthStore.execute(query)
    }
    func fetchWalkingHeartRateAverage(completion: @escaping (Double?) -> Void) { completion(nil) }
    func fetchCardioRecovery(completion: @escaping (Double?) -> Void) { completion(nil) }
    func fetchHighHeartRateNotifications(completion: @escaping (Int?) -> Void) { completion(nil) }
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Include characteristic types for DOB and biological sex
        let basicTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ]
        
        // All the other quantity and category types you already want
        let otherTypes: Set<HKObjectType> = [
            // Activity
            basalEnergyType,
            activeEnergyType,
            exerciseTimeType,
            stepCountType,
            distanceWalkingRunningType,
            flightsClimbedType,
            // Body Measurements
            bodyTemperature,
            weightType,
            heightType,
            bmiType,
            bodyFatPercentageType,
            leanBodyMassType,
            // Hearing
            environmentalSoundType,
            headphoneAudioType,
            // Heart
            heartRateType,
            restingHRType,
            hrvType,
            vo2MaxType,
            // Sleep
            sleepType
        ]
        
        let typesToRead = basicTypes.union(otherTypes)
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Fetch Methods
    
    // Activity Metrics
    func fetchBasalEnergy(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: basalEnergyType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let energy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    func fetchActiveEnergy(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: activeEnergyType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let energy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    func fetchExerciseMinutes(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: exerciseTimeType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let minutes = sample.quantity.doubleValue(for: HKUnit.minute())
            completion(minutes)
        }
        healthStore.execute(query)
    }
    
    func fetchSteps(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: stepCountType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            completion(steps)
        }
        healthStore.execute(query)
    }
    
    func fetchWalkingRunningDistance(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: distanceWalkingRunningType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let distance = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(distance)
        }
        healthStore.execute(query)
    }
    
    func fetchFlightsClimbed(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: flightsClimbedType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let flights = sample.quantity.doubleValue(for: HKUnit.count())
            completion(flights)
        }
        healthStore.execute(query)
    }
    
    // Body Measurements
    func fetchLatestBodyTemperature(completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bodyTemperature,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let temperatureUnit = HKUnit.degreeCelsius()
            let temperature = sample.quantity.doubleValue(for: temperatureUnit)
            completion(temperature)
        }
        healthStore.execute(query)
    }
    
    func fetchWeight(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: weightType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weight)
        }
        healthStore.execute(query)
    }
    
    func fetchHeight(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: heightType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let height = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(height)
        }
        healthStore.execute(query)
    }
    
    func fetchBMI(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: bmiType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let bmi = sample.quantity.doubleValue(for: HKUnit.count())
            completion(bmi)
        }
        healthStore.execute(query)
    }
    
    func fetchBodyFatPercentage(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: bodyFatPercentageType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let fatPercentage = sample.quantity.doubleValue(for: HKUnit.percent())
            completion(fatPercentage)
        }
        healthStore.execute(query)
    }
    
    func fetchLeanBodyMass(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: leanBodyMassType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let leanMass = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(leanMass)
        }
        healthStore.execute(query)
    }
    
    // Hearing
    func fetchEnvironmentalSoundLevel(completion: @escaping (Double?) -> Void) {
        // If you need to support < iOS 14, add an availability check:
        guard #available(iOS 14.0, *) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: environmentalSoundType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            // Use the official decibel unit method:
            let level = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(level)
        }
        healthStore.execute(query)
    }

    func fetchHeadphoneAudioLevel(completion: @escaping (Double?) -> Void) {
        guard #available(iOS 14.0, *) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: headphoneAudioType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let level = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(level)
        }
        healthStore.execute(query)
    }
    
    // Heart Metrics
    func fetchCurrentHeartRate(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: heartRateType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hr = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(hr)
        }
        healthStore.execute(query)
    }
    
    func fetchRestingHeartRate(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: restingHRType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hr = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(hr)
        }
        healthStore.execute(query)
    }
    
    func fetchHeartRateVariability(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: hrvType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            completion(hrv)
        }
        healthStore.execute(query)
    }
    
    func fetchCardioFitness(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: vo2MaxType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let vo2 = sample.quantity.doubleValue(for: HKUnit(from: "mL/kg*min"))
            completion(vo2)
        }
        healthStore.execute(query)
    }
    
    // Sleep Metrics
    func fetchSleepHours(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, results, _ in
            guard let sample = results?.first as? HKCategorySample else { completion(nil); return }
            let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
            completion(sleepDuration)
        }
        healthStore.execute(query)
    }
}
