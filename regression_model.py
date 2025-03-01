from ucimlrepo import fetch_ucirepo
import numpy as np
from numpy.linalg import inv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import PolynomialFeatures

# Constants
MAX_ORDER = 1
REG = 0.0001
TRAIN_SIZE = 0.2


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


def create_error_array(p_list, w_list, y):
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
    :X_train type: numpy.ndarray of size (number_of_training_samples, 4)
    :y_train type: numpy.ndarray of size (number_of_training_samples,)
    :X_test type: numpy.ndarray of size (number_of_test_samples, 4)
    :y_test type: numpy.ndarray of size (number_of_test_samples,)
    :Ytr type: numpy.ndarray of size (number_of_training_samples, 3)
    :Yts type: numpy.ndarray of size (number_of_test_samples, 3)
    :Ptrain_list type: List[numpy.ndarray]
    :Ptest_list type: List[numpy.ndarray]
    :w_list type: List[numpy.ndarray]
    :error_train_array type: numpy.ndarray
    :error_test_array type: numpy.ndarray
    """
    data = np.genfromtxt('diabetes.csv', delimiter=',', skip_header=1)
    print(data[:, 1:])
    # fetch dataset
    cdc_diabetes_health_indicators = fetch_ucirepo(id=891)

    # data (as pandas dataframes)
    data = cdc_diabetes_health_indicators.data.features.to_numpy()
    target = cdc_diabetes_health_indicators.data.targets.to_numpy()

    # your code goes here
    X_train, X_test, y_train, y_test = train_test_split(
        data, target, random_state=1, train_size=TRAIN_SIZE
    )
    onehot_encoder = OneHotEncoder(sparse_output=False)
    Ytr = onehot_encoder.fit_transform(y_train.reshape(-1, 1))
    Yts = onehot_encoder.fit_transform(y_test.reshape(-1, 1))
    Ptrain_list = create_p_list(X_train, MAX_ORDER)
    Ptest_list = create_p_list(X_test, MAX_ORDER)
    w_list = create_w_list(Ptrain_list, Ytr, REG)
    error_train_array = create_error_array(Ptrain_list, w_list, Ytr)
    error_test_array = create_error_array(Ptest_list, w_list, Yts)

    # return in this order
    return X_train, y_train, X_test, y_test, Ytr, Yts, Ptrain_list, Ptest_list, w_list, error_train_array, error_test_array


X_train, y_train, X_test, y_test, Ytr, Yts, Ptrain_list, Ptest_list, w_list, error_train_array, error_test_array = test_diabetes_prediction()
print(w_list)
print(error_train_array)
print(error_test_array)
print(X_train.shape)
print(np.array([[1, 1, 1, 1, 40, 1, 0, 0, 0, 0, 1, 0, 1, 0, 5, 18, 15, 1, 0, 9, 4, 3]]) @ w_list[0])
