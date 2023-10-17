import math

# метод вычисление скалярного произведения двух векторов
def scalar_mul(vec1, vec2):
    if len(vec1) < len(vec2):
        length = len(vec2)
    else:
        length = len(vec1)

    res = 0
    for i in range(0, length):
        res += vec1[i] * vec2[i]

    return res

# метод вычисления Евклидовой нормы вектора.
def euclidean_norm(vec):
    # return math.sqrt(scalar_mul(vec, vec))
    #or
    res = 0
    for el in vec:
        res += el**2
    return math.sqrt(res)    

# test
v1 = [1, 2, 3]
v2 = [-3, 2, 1]
print(f'scalar mul: {scalar_mul(v1, v2)}')
print(f'Euclidean norm v1: {euclidean_norm(v1)}')
print(f'Euclidean norm v2: {euclidean_norm(v2)}')