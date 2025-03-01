//
//  HealthDataView.swift
//  DLW25
//
//  Created by Brandon Kang on [Date].
//

import SwiftUI
import HealthKit

class HealthDataViewModel: ObservableObject {
    // Basic Metrics
    @Published var age: Int?
    @Published var sex: String = "N/A"
    
    // Activity
    @Published var restingEnergy: Double?
    @Published var activeEnergy: Double?
    @Published var workoutsCount: Int?
    @Published var exerciseMinutes: Double?
    @Published var standMinutes: Double?
    @Published var standHours: Double?
    @Published var steps: Double?
    @Published var walkingRunningDistance: Double?
    @Published var flightsClimbed: Double?
    
    // Body Measurements
    @Published var bodyTemperature: Double?
    @Published var weight: Double?
    @Published var height: Double?
    @Published var bmi: Double?
    @Published var bodyFatPercentage: Double?
    @Published var leanBodyMass: Double?
    
    // Hearing
    @Published var environmentalSoundLevels: Double?
    @Published var headphoneAudioLevels: Double?
    
    // Heart
    @Published var currentHeartRate: Double?
    @Published var restingHeartRate: Double?
    @Published var heartRateVariability: Double?
    @Published var cardioFitness: Double?
    
    // Sleep
    @Published var sleepHours: Double?
    
    private var hkManager = HealthKitManager()
    
    init() {
        hkManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if success {
                    self.fetchBasicMetrics()
                } else {
                    print("Authorization error: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchBasicMetrics() {
        // Fetch biological sex and age
        do {
            let bioSex = try hkManager.healthStore.biologicalSex()
            self.sex = bioSex.biologicalSex.stringRepresentation
        } catch {
            self.sex = "Error"
            print("Error retrieving biological sex: \(error)")
        }
        do {
            let dobComponents = try hkManager.healthStore.dateOfBirthComponents()
            if let year = dobComponents.year {
                let currentYear = Calendar.current.component(.year, from: Date())
                self.age = currentYear - year
            } else {
                print("DOB components did not include a year")
            }
        } catch {
            print("Error fetching DOB: \(error)")
        }
    }
    
    func fetchAllMetrics() {
        // Activity
        hkManager.fetchBasalEnergy { value in DispatchQueue.main.async { self.restingEnergy = value } }
        hkManager.fetchActiveEnergy { value in DispatchQueue.main.async { self.activeEnergy = value } }
        hkManager.fetchWorkoutsCount { value in DispatchQueue.main.async { self.workoutsCount = value } }
        hkManager.fetchExerciseMinutes { value in DispatchQueue.main.async { self.exerciseMinutes = value } }
        hkManager.fetchSteps { value in DispatchQueue.main.async { self.steps = value } }
        hkManager.fetchWalkingRunningDistance { value in DispatchQueue.main.async { self.walkingRunningDistance = value } }
        hkManager.fetchFlightsClimbed { value in DispatchQueue.main.async { self.flightsClimbed = value } }
        
        // Body Measurements
        hkManager.fetchLatestBodyTemperature { value in DispatchQueue.main.async { self.bodyTemperature = value } }
        hkManager.fetchWeight { value in DispatchQueue.main.async { self.weight = value } }
        hkManager.fetchHeight { value in DispatchQueue.main.async { self.height = value } }
        hkManager.fetchBMI { value in DispatchQueue.main.async { self.bmi = value } }
        hkManager.fetchBodyFatPercentage { value in DispatchQueue.main.async { self.bodyFatPercentage = value } }
        hkManager.fetchLeanBodyMass { value in DispatchQueue.main.async { self.leanBodyMass = value } }
        
        // Hearing
        hkManager.fetchEnvironmentalSoundLevel { value in DispatchQueue.main.async { self.environmentalSoundLevels = value } }
        hkManager.fetchHeadphoneAudioLevel { value in DispatchQueue.main.async { self.headphoneAudioLevels = value } }
        
        // Heart
        hkManager.fetchCurrentHeartRate { value in DispatchQueue.main.async { self.currentHeartRate = value } }
        hkManager.fetchRestingHeartRate { value in DispatchQueue.main.async { self.restingHeartRate = value } }
        hkManager.fetchHeartRateVariability { value in DispatchQueue.main.async { self.heartRateVariability = value } }
        hkManager.fetchCardioFitness { value in DispatchQueue.main.async { self.cardioFitness = value } }
        
        // Sleep
        hkManager.fetchSleepHours { value in DispatchQueue.main.async { self.sleepHours = value } }
    }
}

extension HKBiologicalSex {
    var stringRepresentation: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        default: return "Not Set"
        }
    }
}

struct HealthDataView: View {
    @ObservedObject var viewModel = HealthDataViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Basic Metrics
                Group {
                    Text("Basic Metrics")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Age:")
                        Spacer()
                        Text(viewModel.age != nil ? "\(viewModel.age!)" : "N/A")
                    }
                    HStack {
                        Text("Sex:")
                        Spacer()
                        Text(viewModel.sex)
                    }
                }
                
                Divider()
                
                // Activity
                Group {
                    Text("Activity")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Resting Energy:")
                        Spacer()
                        Text(viewModel.restingEnergy != nil ? "\(viewModel.restingEnergy!) kcal" : "N/A")
                    }
                    HStack {
                        Text("Active Energy:")
                        Spacer()
                        Text(viewModel.activeEnergy != nil ? "\(viewModel.activeEnergy!) kcal" : "N/A")
                    }
                    HStack {
                        Text("Exercise Minutes:")
                        Spacer()
                        Text(viewModel.exerciseMinutes != nil ? "\(viewModel.exerciseMinutes!) min" : "N/A")
                    }
                    HStack {
                        Text("Steps:")
                        Spacer()
                        Text(viewModel.steps != nil ? "\(Int(viewModel.steps!))" : "N/A")
                    }
                    HStack {
                        Text("Walking + Running Distance:")
                        Spacer()
                        Text(viewModel.walkingRunningDistance != nil ? "\(viewModel.walkingRunningDistance!) m" : "N/A")
                    }
                    HStack {
                        Text("Flights Climbed:")
                        Spacer()
                        Text(viewModel.flightsClimbed != nil ? "\(Int(viewModel.flightsClimbed!))" : "N/A")
                    }
                }
                
                Divider()
                
                // Body Measurements
                Group {
                    Text("Body Measurements")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Body Temperature:")
                        Spacer()
                        Text(viewModel.bodyTemperature != nil ? "\(viewModel.bodyTemperature!, specifier: "%.1f") °C" : "N/A")
                    }
                    HStack {
                        Text("Weight:")
                        Spacer()
                        Text(viewModel.weight != nil ? "\(viewModel.weight!) kg" : "N/A")
                    }
                    HStack {
                        Text("Height:")
                        Spacer()
                        Text(viewModel.height != nil ? "\(viewModel.height!) m" : "N/A")
                    }
                    HStack {
                        Text("BMI:")
                        Spacer()
                        Text(viewModel.bmi != nil ? "\(viewModel.bmi!)" : "N/A")
                    }
                    HStack {
                        Text("Body Fat Percentage:")
                        Spacer()
                        Text(viewModel.bodyFatPercentage != nil ? "\(viewModel.bodyFatPercentage! * 100)%" : "N/A")
                    }
                    HStack {
                        Text("Lean Body Mass:")
                        Spacer()
                        Text(viewModel.leanBodyMass != nil ? "\(viewModel.leanBodyMass!) kg" : "N/A")
                    }
                }
                
                Divider()
                
                // Hearing
                Group {
                    Text("Hearing")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Environmental Sound Levels:")
                        Spacer()
                        Text(viewModel.environmentalSoundLevels != nil ? "\(viewModel.environmentalSoundLevels!) dBA" : "N/A")
                    }
                    HStack {
                        Text("Headphone Audio Levels:")
                        Spacer()
                        Text(viewModel.headphoneAudioLevels != nil ? "\(viewModel.headphoneAudioLevels!) dBA" : "N/A")
                    }
                }
                
                Divider()
                
                // Heart
                Group {
                    Text("Heart")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Current Heart Rate:")
                        Spacer()
                        Text(viewModel.currentHeartRate != nil ? "\(Int(viewModel.currentHeartRate!)) BPM" : "N/A")
                    }
                    HStack {
                        Text("Walking Heart Rate Average:")
                        Spacer()
                        Text("N/A")
                    }
                    HStack {
                        Text("Resting Heart Rate:")
                        Spacer()
                        Text(viewModel.restingHeartRate != nil ? "\(Int(viewModel.restingHeartRate!)) BPM" : "N/A")
                    }
                    HStack {
                        Text("Heart Rate Variability:")
                        Spacer()
                        Text(viewModel.heartRateVariability != nil ? "\(viewModel.heartRateVariability!) ms" : "N/A")
                    }
                    HStack {
                        Text("Cardio Fitness:")
                        Spacer()
                        Text(viewModel.cardioFitness != nil ? "\(viewModel.cardioFitness!) mL/kg*min" : "N/A")
                    }
                }
                
                Divider()
                
                // Sleep
                Group {
                    Text("Sleep")
                        .font(.title2)
                        .padding(.bottom, 5)
                    HStack {
                        Text("Sleep Hours:")
                        Spacer()
                        Text(viewModel.sleepHours != nil ? "\(viewModel.sleepHours!) hrs" : "N/A")
                    }
                }
                
                Button("Fetch All Data") {
                    viewModel.fetchAllMetrics()
                }
                .padding()
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchBasicMetrics()
        }
        .navigationTitle("HealthKit Data")
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { HealthDataView() }
    }
}
