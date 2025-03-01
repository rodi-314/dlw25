import numpy as np

lol = []
for _ in range(21):
    lol.append([0, 1])

print(np.array([[1, 1, 1, 40, 1, 0, 0, 0, 0, 1, 0, 1, 0, 5, 18, 15, 1, 0, 9, 4, 3]]) @ np.array(lol))