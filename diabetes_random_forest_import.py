from ucimlrepo import fetch_ucirepo
import pandas as pd
import numpy as np
from numpy.linalg import inv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

# Constants
MAX_ORDER = 3
REG = 0.0001
TRAIN_SIZE = 0.2
N = np.random.randint(100)


def remove_outliers(data, column):
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    return data[(data[column] >= lower_bound) & (data[column] <= upper_bound)]


def create_p_list(x, max_order):
    p_list = []
    for order in range(1, max_order + 1):
        p_list.append(PolynomialFeatures(order).fit_transform(x))

    return p_list


def create_w_list(p_list, y, reg):
    w_list = []
    for p in p_list:
        if p.shape[1] > p.shape[0]:  # Use dual solution
            w = p.T @ inv(p @ p.T + reg * np.eye(p.shape[0])) @ y
        else:  # Use primal solution
            w = (inv(p.T @ p + reg * np.eye(p.shape[1])) @ p.T) @ y
        w_list.append(w)

    return w_list


def create_score_array(p_list, w_list, y):
    error_array = []
    for p, w in zip(p_list, w_list):
        y_new = p @ w
        y_new = [[1 if col == max(row) else 0 for col in row] for row in y_new]
        errors = 0
        total = 0
        for y_entry, y_new_entry in zip(y, y_new):
            if not np.array_equal(y_entry, y_new_entry):
                errors += 1
            total += 1
        error_array.append((total - errors) / total)
        print(f"Correct: {total - errors}, Total: {total}")

    return error_array


# Please replace "MatricNumber" with your actual matric number here and in the filename
def test_diabetes_prediction():
    """
    Input type
    :N type: int

    Return type
    :w_list type: List[numpy.ndarray]
    :train_score type: numpy.ndarray
    :test_score type: numpy.ndarray
    """
    # Fetch dataset
    cdc_diabetes_health_indicators = fetch_ucirepo(id=891)

    # Data (as pandas dataframes)
    data = cdc_diabetes_health_indicators.data.features.to_numpy()
    target = cdc_diabetes_health_indicators.data.targets.to_numpy()

    # Convert features to a pandas DataFrame with generated column names
    df = pd.DataFrame(data, columns=[f'feature_{i}' for i in range(data.shape[1])])

    # Identify all numeric columns in the DataFrame
    numeric_cols = df.select_dtypes(include=[np.number]).columns

    # Apply outlier removal for each feature column iteratively
    for col in numeric_cols:
        df = remove_outliers(df, col)

    # Filter the target array to include only rows corresponding to the remaining data
    target = target[df.index]

    # Scale all numeric columns using StandardScaler
    scaler = StandardScaler()
    df[numeric_cols] = scaler.fit_transform(df[numeric_cols])

    # Convert the cleaned and scaled DataFrame back to a NumPy array
    data = df.to_numpy()

    X_train, X_test, y_train, y_test = train_test_split(
        data, target, random_state=1, train_size=TRAIN_SIZE
    )

    # Create Random Forest model
    rf_model = RandomForestClassifier(n_estimators=100, random_state=N)

    # Train the model
    rf_model.fit(X_train, y_train)

    # Make predictions
    y_pred = rf_model.predict(X_test)

    # return in this order
    return rf_model, accuracy_score(y_test, y_pred), classification_report(y_test, y_pred)


rf_model, rf_accuracy_score, rf_classification_report = test_diabetes_prediction()
print(rf_accuracy_score)
print(rf_classification_report)

# Test
# print(rf_model.predict(np.array([[1, 1, 1, 40, 1, 0, 0, 0, 0, 1, 0, 1, 0, 5, 18, 15, 1, 0, 9, 4, 3]])))
