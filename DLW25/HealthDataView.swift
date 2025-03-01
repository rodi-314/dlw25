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
                    // Start all observers for real-time updates.
                    self.hkManager.startAllObservers(handlers: [
                        self.hkManager.basalEnergyType: { newValue in self.restingEnergy = newValue },
                        self.hkManager.activeEnergyType: { newValue in self.activeEnergy = newValue },
                        self.hkManager.exerciseTimeType: { newValue in self.exerciseMinutes = newValue },
                        self.hkManager.stepCountType: { newValue in self.steps = newValue },
                        self.hkManager.distanceWalkingRunningType: { newValue in self.walkingRunningDistance = newValue },
                        self.hkManager.flightsClimbedType: { newValue in self.flightsClimbed = newValue },
                        self.hkManager.bodyTemperatureType: { newValue in self.bodyTemperature = newValue },
                        self.hkManager.weightType: { newValue in self.weight = newValue },
                        self.hkManager.heightType: { newValue in self.height = newValue },
                        self.hkManager.bmiType: { newValue in self.bmi = newValue },
                        self.hkManager.bodyFatPercentageType: { newValue in self.bodyFatPercentage = newValue },
                        self.hkManager.leanBodyMassType: { newValue in self.leanBodyMass = newValue },
                        self.hkManager.environmentalSoundType: { newValue in self.environmentalSoundLevels = newValue },
                        self.hkManager.headphoneAudioType: { newValue in self.headphoneAudioLevels = newValue },
                        self.hkManager.heartRateType: { newValue in self.currentHeartRate = newValue },
                        self.hkManager.restingHRType: { newValue in self.restingHeartRate = newValue },
                        self.hkManager.hrvType: { newValue in self.heartRateVariability = newValue },
                        self.hkManager.vo2MaxType: { newValue in self.cardioFitness = newValue }
                    ])
                } else {
                    print("Authorization error: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchBasicMetrics() {
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
        // Optionally, you can call individual fetch methods here if needed.
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
            }
            .padding()
        }
        .navigationTitle("HealthKit Data")
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { HealthDataView() }
    }
}
