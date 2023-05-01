import pandas as pd
import numpy as np
from tabulate import tabulate

m = 4
l = 0
r = 1
n = 10

# для индивидуального варианта
# l = 1
# r = 5
# n = 8

h = (r - l) / n

def f(x):
    return np.exp(x)

def find_lambd2(A, b):
    return (np.linalg.inv(A).dot(b.T)).T

def find_lambd(A, b):
    T = np.zeros((m,m))
    x = np.empty(m)
    y = np.empty(m)
    
    # T 
    for i in range(m):
        for j in range(i):
            T[i][j] = (A[i][j] - sum([T[i][k] * T[j][k] for k in range(j)])) / T[j][j]
        T[i][i] = np.sqrt(A[i][i] - sum(T[i][k] ** 2 for k in range(i)))
        
    # прямой ход
    for i in range(m):
        y[i] = (b[i] - sum([T[i,k]*y[k] for k in range(i)])) / T[i,i] 
    
    # обратный ход
    for i in range(m-1, -1, -1):
        x[i] = (y[i] - sum([T[k,i]*x[k] for k in range(i+1, m)])) / T[i,i] 

    return x
    
xs = np.linspace(l, r, n + 1, True)
ys = np.vectorize(f)(xs)

# для индивидуального варианта
# mids = np.linspace(l + 0.5 * h, r - 0.5 * h, n, True)
# ys = np.array([3.33, 2.30, 1.60, 1.27, 1.18, 0.99, 1.41, 0.80, 1.12])
# print("\nxs:\n", xs)
# print("\nys:\n", ys)
# print("\nmids:\n", mids)

A = np.empty((m,m))
b = np.empty(m)
A = np.array([[sum(xs[k] ** (i+j) for k in range(0,n+1))  for j in range(0, m)] for i in range(0,m)])
b = np.array([sum(ys[k] * (xs[k] ** i) for k in range(0,n+1))  for i in range(0, m)])
print("\nA:", A)
print("\nb:", b)

lambd = find_lambd(A,b)
print("\nλ:", lambd)

def z(x):
    return sum([lambd[i] * x**i for i in range(m)])

D = sum([(ys[k] - z(xs)[k]) for k in range(m+1)])**2 
D = np.sqrt(D) / np.sqrt(n)
print("\nСКО Δ:", D)

d = sum([ys[k]**2 for k in range(n+1)])
d = D / np.sqrt(d)
print("\nотн. погрешность δ:", d)
print()

tab = np.linspace(l, r, n+n+1, True)
counted = np.vectorize(z)(tab)
given = np.vectorize(f)(tab)

res = pd.DataFrame({"x": tab, "f(x)": given, "z(x)": counted,  "|f - z|": np.abs(given - counted)})
print(tabulate(res, headers='keys', tablefmt='github', showindex=False))

# для индивидуального варианта
# for k in range(n + 1):
#     print("x:", xs[k], "  f(x):", ys[k], "  z(x):", z(xs)[k], "  |f - z|:", abs(ys[k] - z(xs)[k]))
#     if k != n:
#         print("x:", mids[k], "              z(x):", z(mids)[k])
