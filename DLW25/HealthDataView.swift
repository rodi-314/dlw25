//
//  HealthDataView.swift
//  DLW25
//
//  Created by Brandon Kang on [Date].
//

import SwiftUI
import HealthKit
import CoreML

// MARK: - View Model

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
    
    //User Inputs
    @Published var bloodPressure: Float?
    @Published var cholestrol: Float?
    @Published var cholCheck: Float?
    @Published var smoke: Float?
    @Published var stroke: Float?
    @Published var heartDiseaseOrAttack: Float?
    @Published var physicalActivity: Float?
    @Published var fruits: Float?
    @Published var veggies: Float?
    @Published var alcohol: Float?
    @Published var healthcare: Float?
    @Published var noDocCozCost: Float?
    @Published var generalHealth: Float?
    @Published var mentalHealth: Float?
    @Published var physicalHealth: Float?
    @Published var difficultyWalking: Float?
    @Published var education: Float?
    @Published var income: Float?
    
    //ML Prediction
    @Published var predictionOutput: [Float]?
    
    import SwiftUI
    import CoreML

    func runPrediction() {
        do {
            let model = try diabetes_regression(configuration: MLModelConfiguration())
            let input = diabetes_regressionInput(HighBP: 0, HighChol: 0, CholCheck: 0, BMI: 21, Smoker: 0, Stroke: 0, HeartDiseaseorAttack: 0, PhysActivity: 0, Fruits: 1, Veggies: 1, HvyAlcoholConsump: 0, AnyHealthcare: 1, NoDocbcCost: 0, GenHlth: 4, MentHlth: 25, PhysHlth: 25, DiffWalk: 0, Sex: 1, Age: 21, Education: 5, Income: 1) // Adjust input features
            let output = try model.prediction(input: input)

            let result = output.Diabetes_012 // Adjust this based on your model’s actual output
            print("Prediction Result: \(result)")

            DispatchQueue.main.async {
                predictionText = "Prediction: \(result)"
                predictionColor = .green  // Change text color to green
            }
        } catch {
            print("Error running prediction: \(error)")
            DispatchQueue.main.async {
                predictionText = "Error: \(error.localizedDescription)"
                predictionColor = .red  // Show errors in red
            }
        }
    }

    struct DiabetesPrediction_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    func predictDisease() {
        // 1) Load the model
        guard let modelInstance = try? Model(configuration: MLModelConfiguration()) else {
            print("Error loading model")
            return
        }

        // 2) Gather 21 float values from your data
        var inputValues = [Float](repeating: 0, count: 21)
        inputValues[0] = Float(bloodPressure ?? 0)
        inputValues[1] = Float(cholestrol ?? 0)
        inputValues[2] = Float(cholCheck ?? 0)
        inputValues[3] = Float(bmi ?? 0)
        inputValues[4] = Float(smoke ?? 0)
        inputValues[5] = Float(stroke ?? 0)
        inputValues[6] = Float(heartDiseaseOrAttack ?? 0)
        inputValues[7] = Float(physicalActivity ?? 1)
        inputValues[8] = Float(fruits ?? 1)
        inputValues[9] = Float(veggies ?? 1)
        inputValues[10] = Float(alcohol ?? 0)
        inputValues[11] = Float(healthcare ?? 1)
        inputValues[12] = Float(noDocCozCost ?? 0)
        inputValues[13] = Float(generalHealth ?? 4)
        inputValues[14] = Float(mentalHealth ?? 23)
        inputValues[15] = Float(physicalHealth ?? 23)
        inputValues[16] = Float(difficultyWalking ?? 0)
        inputValues[17] = (sex == "Male") ? 1.0 : 0.0
        inputValues[18] = Float(age ?? 0)
        inputValues[19] = Float(education ?? 5)
        inputValues[20] = Float(income ?? 6)

        // 3) Create the MLMultiArray
        guard let mlArray = try? MLMultiArray(shape: [1, 21], dataType: .float32) else {
            print("Failed to create MLMultiArray")
            return
        }

        // Copy your inputValues into the MLMultiArray
        for i in 0..<21 {
            mlArray[[NSNumber(value: 0), NSNumber(value: i)]] = NSNumber(value: inputValues[i])
        }

        // 4) Create the auto-generated model input struct
        let inputStruct = ModelInput(input: mlArray)

        // 5) Call prediction
        do {
            let outputStruct = try modelInstance.prediction(input: inputStruct)
            let outputArray = outputStruct.var_35

            // Convert the MLMultiArray to [Float] if needed
            let count = outputArray.count
            var result = [Float](repeating: 0, count: count)
            for i in 0..<count {
                result[i] = outputArray[i].floatValue
            }
            self.predictionOutput = result
            print("Model output array: \(result)")
            // Save or interpret this result as needed (e.g., store in @Published var)
        } catch {
            print("Prediction error: \(error)")
        }
    }
    
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
                    
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                        self?.runPrediction()
                    }
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
        // Optionally, you can call individual fetch methods here for an initial refresh.
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

// MARK: - View

struct HealthDataView: View {
    @ObservedObject var viewModel = HealthDataViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Welcome to BioWatch")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                Form {
                    Section(header: Text("Prediction").font(.headline)) {
                        if let output = viewModel.predictionOutput {
                            Text("Prediction Output: \(output)")
                        } else {
                            Text("No prediction yet")
                        }
                        
                        Form {
                            // Daily Summary Section
                            Section(header: Text("Daily Summary").font(.headline)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("🌟 Daily Summary")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text("summaryText")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .cornerRadius(0)
                                .shadow(radius: 0)
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // 👈 Makes VStack fill available space
                            }
                            
                            // Basic Metrics Section
                            Section(header: Text("Basic Metrics").font(.headline)) {
                                HStack {
                                    Text("Age")
                                    Spacer()
                                    Text(viewModel.age != nil ? "\(viewModel.age!)" : "N/A")
                                }
                                
                                // Basic Metrics Section
                                Section(header: Text("Basic Metrics").font(.headline)) {
                                    HStack {
                                        Text("Age")
                                        Spacer()
                                        Text(viewModel.age != nil ? "\(viewModel.age!)" : "N/A")
                                    }
                                    HStack {
                                        Text("Sex")
                                        Spacer()
                                        Text(viewModel.sex)
                                    }
                                }
                                
                                // Activity Section
                                Section(header: Text("Activity").font(.headline)) {
                                    HStack {
                                        Text("Resting Energy")
                                        Spacer()
                                        Text(viewModel.restingEnergy != nil ? "\(viewModel.restingEnergy!, specifier: "%.0f") kcal" : "N/A")
                                    }
                                    HStack {
                                        Text("Active Energy")
                                        Spacer()
                                        Text(viewModel.activeEnergy != nil ? "\(viewModel.activeEnergy!, specifier: "%.0f") kcal" : "N/A")
                                    }
                                    HStack {
                                        Text("Exercise Minutes")
                                        Spacer()
                                        Text(viewModel.exerciseMinutes != nil ? "\(viewModel.exerciseMinutes!, specifier: "%.0f") min" : "N/A")
                                    }
                                    HStack {
                                        Text("Steps")
                                        Spacer()
                                        Text(viewModel.steps != nil ? "\(Int(viewModel.steps!))" : "N/A")
                                    }
                                    HStack {
                                        Text("Walking + Running Distance")
                                        Spacer()
                                        Text(viewModel.walkingRunningDistance != nil ? "\(viewModel.walkingRunningDistance!, specifier: "%.0f") m" : "N/A")
                                    }
                                    HStack {
                                        Text("Flights Climbed")
                                        Spacer()
                                        Text(viewModel.flightsClimbed != nil ? "\(Int(viewModel.flightsClimbed!))" : "N/A")
                                    }
                                }
                                
                                // Body Measurements Section
                                Section(header: Text("Body Measurements").font(.headline)) {
                                    HStack {
                                        Text("Body Temperature")
                                        Spacer()
                                        Text(viewModel.bodyTemperature != nil ? "\(viewModel.bodyTemperature!, specifier: "%.1f") °C" : "N/A")
                                    }
                                    HStack {
                                        Text("Weight")
                                        Spacer()
                                        Text(viewModel.weight != nil ? "\(viewModel.weight!, specifier: "%.1f") kg" : "N/A")
                                    }
                                    HStack {
                                        Text("Height")
                                        Spacer()
                                        Text(viewModel.height != nil ? "\(viewModel.height!, specifier: "%.2f") m" : "N/A")
                                    }
                                    HStack {
                                        Text("BMI")
                                        Spacer()
                                        Text(viewModel.bmi != nil ? "\(viewModel.bmi!, specifier: "%.1f")" : "N/A")
                                    }
                                    HStack {
                                        Text("Body Fat %")
                                        Spacer()
                                        Text(viewModel.bodyFatPercentage != nil ? "\(viewModel.bodyFatPercentage! * 100, specifier: "%.1f")%" : "N/A")
                                    }
                                    HStack {
                                        Text("Lean Body Mass")
                                        Spacer()
                                        Text(viewModel.leanBodyMass != nil ? "\(viewModel.leanBodyMass!, specifier: "%.1f") kg" : "N/A")
                                    }
                                }
                                
                                // Hearing Section
                                Section(header: Text("Hearing").font(.headline)) {
                                    HStack {
                                        Text("Env. Sound Levels")
                                        Spacer()
                                        Text(viewModel.environmentalSoundLevels != nil ? "\(viewModel.environmentalSoundLevels!, specifier: "%.0f") dBA" : "N/A")
                                    }
                                    HStack {
                                        Text("Headphone Audio")
                                        Spacer()
                                        Text(viewModel.headphoneAudioLevels != nil ? "\(viewModel.headphoneAudioLevels!, specifier: "%.0f") dBA" : "N/A")
                                    }
                                }
                                
                                // Heart Section
                                Section(header: Text("Heart").font(.headline)) {
                                    HStack {
                                        Text("Current HR")
                                        Spacer()
                                        Text(viewModel.currentHeartRate != nil ? "\(Int(viewModel.currentHeartRate!)) BPM" : "N/A")
                                    }
                                    HStack {
                                        Text("Resting HR")
                                        Spacer()
                                        Text(viewModel.restingHeartRate != nil ? "\(Int(viewModel.restingHeartRate!)) BPM" : "N/A")
                                    }
                                    HStack {
                                        Text("HR Variability")
                                        Spacer()
                                        Text(viewModel.heartRateVariability != nil ? "\(viewModel.heartRateVariability!, specifier: "%.0f") ms" : "N/A")
                                    }
                                    HStack {
                                        Text("Cardio Fitness")
                                        Spacer()
                                        Text(viewModel.cardioFitness != nil ? "\(viewModel.cardioFitness!, specifier: "%.1f") mL/kg*min" : "N/A")
                                    }
                                }
                                
                                // Sleep Section
                                Section(header: Text("Sleep").font(.headline)) {
                                    HStack {
                                        Text("Sleep Hours")
                                        Spacer()
                                        Text(viewModel.sleepHours != nil ? "\(viewModel.sleepHours!, specifier: "%.1f") hrs" : "N/A")
                                    }
                                }
                                
                                Section(header: Text("Additional User Inputs").font(.headline)) {
                                    HStack {
                                        Text("Blood Pressure")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.bloodPressure, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("High Cholestrol")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.cholestrol, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Cholestrol Check in the last 5 years")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.cholCheck, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Smoker")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.smoke, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Stroke")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.stroke, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Heart Disease")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.heartDiseaseOrAttack, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Physical Activity in the last 30 days")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.physicalActivity, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Eat fruits 1 or more times a day")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.fruits, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Eat veggies 1 or more times a day")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.veggies, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Heavy Drinker")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.alcohol, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Healthcare Coverage")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.healthcare, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Unable to see doctor due to cost")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.noDocCozCost, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("General Health")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.generalHealth, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Mental Health")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.mentalHealth, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Physical Health")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.physicalHealth, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Difficulty walking")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.difficultyWalking, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Education")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.education, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack {
                                        Text("Income")
                                        Spacer()
                                        TextField("Enter Value", value: $viewModel.income, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                            .listStyle(GroupedListStyle())
                        }
                    }
                    .navigationTitle("Welcome to BioWatch")
                }
            }
            
            struct HealthDataView_Previews: PreviewProvider {
                static var previews: some View {
                    HealthDataView()
                }
            }
        }
