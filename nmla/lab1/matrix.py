# умножение матрицы на матрицу
def mul_on_matrix(matrix1, matrix2):
    rows_matrix1 = len(matrix1)
    cols_matrix1 = len(matrix1[0])
    cols_matrix2 = len(matrix2[0])
    rows_matrix2 = len(matrix2)

    if rows_matrix1 != cols_matrix2:
        return f'Ошибка: Не удается умножить матрицы, т.к. несовместимые размеры {rows_matrix1}x{cols_matrix1} и {rows_matrix2}x{cols_matrix2}'
    else:
        res = []
        for i in range(0, rows_matrix1):
            tmp = []
            for j in range(0, cols_matrix2):
                el = 0
                for k in range(cols_matrix1):
                    el += matrix1[i][k] * matrix2[k][j]
                tmp.append(el)
            res.append(tmp)    
        return res

# умножение матрицы на вектор
def mul_on_vector(matrix, vector):
    res = []
    for i in range(len(matrix)):
        el = 0
        for j in range(len(vector)):
            el += matrix[i][j] * vector[j]
        res.append(el)
    return res        

# транспонирование матрицы
def transpose_matrix(matrix):
    transposed = [[0 for j in range(len(matrix))] for i in range(len(matrix[0]))]
    for i in range(len(matrix)):
         for j in range(len(matrix[0])):
              transposed[j][i] = matrix[i][j]
    return transposed

# test
mat = [[1, 2, 4], [31, 17, 15]]
print(mat)
print(f'\ntransposed matrix:\n{transpose_matrix(mat)}')
mat = [[2, 4, 0], [-2, 1, 3], [-1, 0, 1]]
vec = [1, 2, -1]
print(f'\nmultiply matrix on vector:\n{mul_on_vector(mat, vec)}')
mat1 = [[1, 2, 1], [0, 1, 2]]
mat2 = [[1, 0], [0, 1], [1, 1]]
print(f'\nmultiply matrix1 on matrix2:\n{mul_on_matrix(mat1, mat2)}')

print(f'\nmultiply matrix2 on matrix1:\n{mul_on_matrix(mat2, mat1)}')

print(f'\nmultiply matrix on matrix:\n{mul_on_matrix(mat1, mat1)}')