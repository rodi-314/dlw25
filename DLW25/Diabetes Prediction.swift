import SwiftUI
import CoreML

struct DiabetesPrediction: View {
    @State private var predictionText: String = "Waiting for prediction..."
    @State private var predictionColor: Color = .black  // Default color

    var body: some View {
        VStack(spacing: 20) {
            Text("Smartwatch Health Prediction")
                .font(.title)

            Text(predictionText)
                .font(.headline)
                .foregroundColor(predictionColor) // Change text color

            Button("Run Prediction") {
                runPrediction()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

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
}

struct DiabetesPrediction_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
