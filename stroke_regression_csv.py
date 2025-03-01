import pandas as pd
import numpy as np
from numpy.linalg import inv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import PolynomialFeatures
from sklearn.preprocessing import StandardScaler

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
    df = pd.read_csv("stroke.csv")
    # Display the first few rows
    print(df.head())

    # Show dataset info
    print(df.info())

    # Show missing values
    print(df.isnull().sum())

    df.drop(columns=["id"], inplace=True) 
    df.drop(columns=["ever_married"], inplace=True)
    df.drop(columns=["work_type"], inplace=True)
    df.drop(columns=["Residence_type"], inplace=True)
    df.drop(columns=["smoking_status"], inplace=True)

    df['gender'] = df['gender'].map({"Female": 0, "Male": 1})
    df = df.dropna()

    # Separate features (X) and target (y)
    X = df.drop(columns=["stroke"])  # Features
    y = df["stroke"]  # Target

    # Identify all numeric columns in the DataFrame
    numeric_cols = X.select_dtypes(include=[np.number]).columns

    # Apply outlier removal for each feature column iteratively
    for col in numeric_cols:
        X = remove_outliers(X, col)

    # Filter the target array to include only rows corresponding to the remaining data
    target = y[X.index]

    # Scale all numeric columns using StandardScaler
    scaler = StandardScaler()
    X[numeric_cols] = scaler.fit_transform(X[numeric_cols])

    # Convert the cleaned and scaled DataFrame back to a NumPy array
    data = X.to_numpy()
    target = target.to_numpy()


    X_train, X_test, y_train, y_test = train_test_split(
        data, target, random_state=N, train_size=TRAIN_SIZE
    )
    onehot_encoder = OneHotEncoder(sparse_output=False)
    Ytr = onehot_encoder.fit_transform(y_train.reshape(-1, 1))
    Yts = onehot_encoder.fit_transform(y_test.reshape(-1, 1))
    Ptrain_list = create_p_list(X_train, MAX_ORDER)
    Ptest_list = create_p_list(X_test, MAX_ORDER)
    w_list = create_w_list(Ptrain_list, Ytr, REG)
    train_score = create_score_array(Ptrain_list, w_list, Ytr)
    test_score = create_score_array(Ptest_list, w_list, Yts)

    # return in this order
    return w_list, train_score, test_score


w_list, train_score, test_score = test_diabetes_prediction()
print(train_score)
print(test_score)

# Test
#print(w_list)
print(np.array([[1, 45, 1, 0, 120, 29, 1]]) @ w_list[0])
