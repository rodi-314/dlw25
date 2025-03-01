from ucimlrepo import fetch_ucirepo

# # fetch dataset
# heart_disease = fetch_ucirepo(id=45)
#
# # data (as pandas dataframes)
# X = heart_disease.data.features
# y = heart_disease.data.targets
#
# # metadata
# print(heart_disease.targets)
#
# # variable information
# # print(heart_disease.variables)

from ucimlrepo import fetch_ucirepo

# fetch dataset
cdc_diabetes_health_indicators = fetch_ucirepo(id=891)

# data (as pandas dataframes)
X = cdc_diabetes_health_indicators.data.features
y = cdc_diabetes_health_indicators.data.targets

print(set(cdc_diabetes_health_indicators.data.targets['Diabetes_binary']))

# # metadata
# print(cdc_diabetes_health_indicators.metadata)
#
# # variable information
# print(cdc_diabetes_health_indicators.variables)

