import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import StandardScaler


def filter():
    df = pd.read_csv("stroke.csv")
    # Display the first few rows
    print(df.head())

    # Show dataset info
    print(df.info())

    # Show missing values
    print(df.isnull().sum())

    df.drop(columns=["id"], inplace=True)  # Drop 'id' column
    df.drop(columns=["ever_married"], inplace=True)
    df.drop(columns=["work_type"], inplace=True)
    df.drop(columns=["Residence_type"], inplace=True)
    df.drop(columns=["smoking_status"], inplace=True)

    df['gender'] = df['gender'].map({"Female": 0, "Male": 1})
    df = df.dropna()

    # Separate features (X) and target (y)
    X = df.drop(columns=["stroke"])  # Features
    y = df["stroke"]  # Target

    # Apply SMOTE to balance classes
    smote = SMOTE(random_state=42)
    X_resampled, y_resampled = smote.fit_resample(X, y)

    # Split into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.2, random_state=42)


    scaler = StandardScaler()
    X_train[["age", "avg_glucose_level", "bmi"]] = scaler.fit_transform(X_train[["age", "avg_glucose_level", "bmi"]])
    X_test[["age", "avg_glucose_level", "bmi"]] = scaler.transform(X_test[["age", "avg_glucose_level", "bmi"]])

    print(X_train.shape, X_test.shape)

    # Create Random Forest model
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)

    # Train the model
    rf_model.fit(X_train, y_train)

    # Make predictions
    y_pred = rf_model.predict(X_test)

    print("Accuracy:", accuracy_score(y_test, y_pred))

    # Classification Report
    print("Classification Report:\n", classification_report(y_test, y_pred))

    return rf_model
    


def predict_result(model,new_patient):
    prediction = model.predict(new_patient)
    print("Stroke Prediction:", "Stroke" if prediction[0] == 1 else "No Stroke")



model = filter()
new_patient = np.array([[45, 1, 0, 120, 29, 1]])
predict_result(model,new_patient)
