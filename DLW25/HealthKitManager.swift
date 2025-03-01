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
    let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
    let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
    let bmiType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
    let bodyFatPercentageType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
    let leanBodyMassType = HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!
    
    // Hearing
    let environmentalSoundType = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
    let headphoneAudioType = HKQuantityType.quantityType(forIdentifier: .headphoneAudioExposure)!
    
    // Heart
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
    let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!  // used for Cardio Fitness
    
    // Sleep
    let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    // MARK: - Additional (Not Directly Implemented) Metrics
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
    
    // MARK: - Observer Query Methods
    
    func startObservingBasalEnergy(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: basalEnergyType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Basal Energy observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchBasalEnergy { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingActiveEnergy(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Active Energy observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchActiveEnergy { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingExerciseTime(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: exerciseTimeType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Exercise Time observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchExerciseMinutes { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingSteps(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Steps observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchSteps { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingWalkingRunningDistance(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: distanceWalkingRunningType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Walking/Running Distance observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchWalkingRunningDistance { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingFlightsClimbed(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: flightsClimbedType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Flights Climbed observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchFlightsClimbed { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingBodyTemperature(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: bodyTemperatureType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Body Temperature observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchLatestBodyTemperature { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingWeight(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: weightType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Weight observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchWeight { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingHeight(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: heightType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Height observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchHeight { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingBMI(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: bmiType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("BMI observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchBMI { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingBodyFatPercentage(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: bodyFatPercentageType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Body Fat Percentage observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchBodyFatPercentage { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingLeanBodyMass(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: leanBodyMassType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Lean Body Mass observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchLeanBodyMass { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingEnvironmentalSoundLevels(updateHandler: @escaping (Double?) -> Void) {
        guard #available(iOS 14.0, *) else { return }
        let observerQuery = HKObserverQuery(sampleType: environmentalSoundType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Environmental Sound Levels observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchEnvironmentalSoundLevel { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingHeadphoneAudioLevels(updateHandler: @escaping (Double?) -> Void) {
        guard #available(iOS 14.0, *) else { return }
        let observerQuery = HKObserverQuery(sampleType: headphoneAudioType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Headphone Audio Levels observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchHeadphoneAudioLevel { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingCurrentHeartRate(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Current Heart Rate observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchCurrentHeartRate { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingRestingHeartRate(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: restingHRType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Resting Heart Rate observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchRestingHeartRate { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingHeartRateVariability(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: hrvType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("HRV observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchHeartRateVariability { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    func startObservingCardioFitness(updateHandler: @escaping (Double?) -> Void) {
        let observerQuery = HKObserverQuery(sampleType: vo2MaxType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Cardio Fitness observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            self?.fetchCardioFitness { value in
                DispatchQueue.main.async { updateHandler(value) }
                completionHandler()
            }
        }
        healthStore.execute(observerQuery)
    }
    
    // MARK: - Start All Observers Convenience Method
    
    func startAllObservers(handlers: [HKQuantityType: (Double?) -> Void]) {
        if let handler = handlers[basalEnergyType] { startObservingBasalEnergy(updateHandler: handler) }
        if let handler = handlers[activeEnergyType] { startObservingActiveEnergy(updateHandler: handler) }
        if let handler = handlers[exerciseTimeType] { startObservingExerciseTime(updateHandler: handler) }
        if let handler = handlers[stepCountType] { startObservingSteps(updateHandler: handler) }
        if let handler = handlers[distanceWalkingRunningType] { startObservingWalkingRunningDistance(updateHandler: handler) }
        if let handler = handlers[flightsClimbedType] { startObservingFlightsClimbed(updateHandler: handler) }
        if let handler = handlers[bodyTemperatureType] { startObservingBodyTemperature(updateHandler: handler) }
        if let handler = handlers[weightType] { startObservingWeight(updateHandler: handler) }
        if let handler = handlers[heightType] { startObservingHeight(updateHandler: handler) }
        if let handler = handlers[bmiType] { startObservingBMI(updateHandler: handler) }
        if let handler = handlers[bodyFatPercentageType] { startObservingBodyFatPercentage(updateHandler: handler) }
        if let handler = handlers[leanBodyMassType] { startObservingLeanBodyMass(updateHandler: handler) }
        if let handler = handlers[environmentalSoundType] { startObservingEnvironmentalSoundLevels(updateHandler: handler) }
        if let handler = handlers[headphoneAudioType] { startObservingHeadphoneAudioLevels(updateHandler: handler) }
        if let handler = handlers[heartRateType] { startObservingCurrentHeartRate(updateHandler: handler) }
        if let handler = handlers[restingHRType] { startObservingRestingHeartRate(updateHandler: handler) }
        if let handler = handlers[hrvType] { startObservingHeartRateVariability(updateHandler: handler) }
        if let handler = handlers[vo2MaxType] { startObservingCardioFitness(updateHandler: handler) }
    }
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let basicTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ]
        let otherTypes: Set<HKObjectType> = [
            basalEnergyType,
            activeEnergyType,
            exerciseTimeType,
            stepCountType,
            distanceWalkingRunningType,
            flightsClimbedType,
            bodyTemperatureType,
            weightType,
            heightType,
            bmiType,
            bodyFatPercentageType,
            leanBodyMassType,
            environmentalSoundType,
            headphoneAudioType,
            heartRateType,
            restingHRType,
            hrvType,
            vo2MaxType,
            sleepType
        ]
        let typesToRead = basicTypes.union(otherTypes)
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Fetch Methods (Unchanged)
    func fetchBasalEnergy(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: basalEnergyType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let energy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    func fetchActiveEnergy(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: activeEnergyType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let energy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    func fetchExerciseMinutes(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: exerciseTimeType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let minutes = sample.quantity.doubleValue(for: HKUnit.minute())
            completion(minutes)
        }
        healthStore.execute(query)
    }
    
    func fetchSteps(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: stepCountType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            completion(steps)
        }
        healthStore.execute(query)
    }
    
    func fetchWalkingRunningDistance(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: distanceWalkingRunningType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let distance = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(distance)
        }
        healthStore.execute(query)
    }
    
    func fetchFlightsClimbed(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: flightsClimbedType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let flights = sample.quantity.doubleValue(for: HKUnit.count())
            completion(flights)
        }
        healthStore.execute(query)
    }
    
    func fetchLatestBodyTemperature(completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bodyTemperatureType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let temperature = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
            completion(temperature)
        }
        healthStore.execute(query)
    }
    
    func fetchWeight(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weight)
        }
        healthStore.execute(query)
    }
    
    func fetchHeight(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let height = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(height)
        }
        healthStore.execute(query)
    }
    
    func fetchBMI(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: bmiType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let bmi = sample.quantity.doubleValue(for: HKUnit.count())
            completion(bmi)
        }
        healthStore.execute(query)
    }
    
    func fetchBodyFatPercentage(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: bodyFatPercentageType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let fatPercentage = sample.quantity.doubleValue(for: HKUnit.percent())
            completion(fatPercentage)
        }
        healthStore.execute(query)
    }
    
    func fetchLeanBodyMass(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: leanBodyMassType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let leanMass = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(leanMass)
        }
        healthStore.execute(query)
    }
    
    func fetchEnvironmentalSoundLevel(completion: @escaping (Double?) -> Void) {
        guard #available(iOS 14.0, *) else { completion(nil); return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: environmentalSoundType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let level = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(level)
        }
        healthStore.execute(query)
    }
    
    func fetchHeadphoneAudioLevel(completion: @escaping (Double?) -> Void) {
        guard #available(iOS 14.0, *) else { completion(nil); return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: headphoneAudioType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let level = sample.quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(level)
        }
        healthStore.execute(query)
    }
    
    func fetchCurrentHeartRate(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hr = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(hr)
        }
        healthStore.execute(query)
    }
    
    func fetchRestingHeartRate(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: restingHRType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hr = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            completion(hr)
        }
        healthStore.execute(query)
    }
    
    func fetchHeartRateVariability(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            completion(hrv)
        }
        healthStore.execute(query)
    }
    
    func fetchCardioFitness(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: vo2MaxType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKQuantitySample else { completion(nil); return }
            let vo2 = sample.quantity.doubleValue(for: HKUnit(from: "mL/kg*min"))
            completion(vo2)
        }
        healthStore.execute(query)
    }
    
    func fetchSleepHours(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, results, _ in
            guard let sample = results?.first as? HKCategorySample else { completion(nil); return }
            let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
            completion(sleepDuration)
        }
        healthStore.execute(query)
    }
}
