//
//  ModelInput.swift
//  DLW25
//
//  Created by Roderick Kong on 2/3/25.
//

import Foundation
import CoreML

public class ModelInput: MLFeatureProvider {
    public var HighBP: Double
    public var HighChol: Double
    public var CholCheck: Double
    public var BMI: Double
    public var Smoker: Double
    public var Stroke: Double
    public var HeartDiseaseorAttack: Double
    public var PhysActivity: Double
    public var Fruits: Double
    public var Veggies: Double
    public var HvyAlcoholConsumption: Double
    public var AnyHealthcare: Double
    public var NoDocbcCost: Double
    public var GenHlth: Double
    public var MentHlth: Double
    public var PhysHlth: Double
    public var DiffWalk: Double
    public var Sex: Double
    public var Age: Double
    public var Education: Double
    public var Income: Double
    
    public var featureNames: Set<String> {
        return ["HighBP", "HighChol"]
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "HighBP":
            return MLFeatureValue(double: HighBP)
        case "HighChol":
            return MLFeatureValue(double: HighChol)
        case "CholCheck":
            return MLFeatureValue(double: CholCheck)
        case "BMI":
            return MLFeatureValue(double: BMI)
        case "Smoker":
            return MLFeatureValue(double: Smoker)
        case "Stroke":
            return MLFeatureValue(double: Stroke)
        case "HeartDiseasesorAttack":
            return MLFeatureValue(double: HeartDiseaseorAttack)
        case "Fruits":
            return MLFeatureValue(double: Fruits)
        case "Veggies":
            return MLFeatureValue(double: Veggies)
        case "HvyAlcoholConsumption":
            return MLFeatureValue(double: HvyAlcoholConsumption)
        case "AnyHealthcare":
            return MLFeatureValue(double: AnyHealthcare)
        case "NoDocbcCost":
            return MLFeatureValue(double: NoDocbcCost)
        case "GenHlth":
            return MLFeatureValue(double: GenHlth)
        case "MentHlth":
            return MLFeatureValue(double: MentHlth)
        case "PhysHlth":
            return MLFeatureValue(double: PhysHlth)
        case "DiffWalk":
            return MLFeatureValue(double: DiffWalk)
        case "Sex":
            return MLFeatureValue(double: Sex)
        case "Age":
            return MLFeatureValue(double: Age)
        case "Education":
            return MLFeatureValue(double: Education)
        case "Income":
            return MLFeatureValue(double: Income)
            
        default:
            return nil
        }
    }
    
    public init(HighBP: Double, HighChol: Double, CholCheck: Double, BMI: Double, Smoker: Double, Stroke: Double, HeartDiseaseorAttack: Double, PhysActivity: Double, Fruits: Double, Veggies: Double, HvyAlcoholConsumption: Double, AnyHealthcare: Double, NoDocbcCost: Double, GenHlth: Double, MentHlth: Double, PhysHlth: Double, DiffWalk: Double, Sex: Double, Age: Double, Education: Double, Income: Double) {
        self.HighBP = HighBP
        self.HighChol = HighChol
        self.CholCheck = CholCheck
        self.BMI = BMI
        self.Smoker = Smoker
        self.Stroke = Stroke
        self.HeartDiseaseorAttack = HeartDiseaseorAttack
        self.PhysActivity = PhysActivity
        self.Fruits = Fruits
        self.Veggies = Veggies
        self.HvyAlcoholConsumption = HvyAlcoholConsumption
        self.AnyHealthcare = AnyHealthcare
        self.NoDocbcCost = NoDocbcCost
        self.GenHlth = GenHlth
        self.MentHlth = MentHlth
        self.PhysHlth = PhysHlth
        self.DiffWalk = DiffWalk
        self.Sex = Sex
        self.Age = Age
        self.Education = Education
        self.Income = Income
    }
}
