import math
import numpy as np
from numpy import linalg

l = 1
r = 5
n = 9
m = 4

h = (r - l) / (n - 1)
y = []
x = []
mids = []
a = []
b = [0] * m

def f(x):
    return x**2

x = [l + i * h for i in range(0, n+1)]
mids = [l + (i + 0.5) * h for i in range(0, n+1)]

y = [f(l + i * h) for i in range(0, n+1)]   
# y = [3.33, 2.30, 1.60, 1.27, 1.18, 0.99, 1.41, 0.80, 1.12]
a = [[sum(x[k] ** (i+j) for k in range(0,n))  for j in range(0, m)] for i in range(0,m)]

b = [sum(y[k] * (x[k] ** i) for k in range(0,n))  for i in range(0, m)]

b = np.array(b).reshape(len(b), 1)    

print('\na:\n', np.array(a))
print('\nb:\n', np.array(b))


mat = linalg.inv(a)
lambd = np.dot(mat, b)
print('\nλ:\n', lambd)

z = []
z_mid = []
for k in range(n):
    z_k = 0
    z_mid_k = 0
    for i in range(m):
        z_k += lambd[i][0] * x[k]**i
        z_mid_k += lambd[i][0] * mids[k]**i
    z.append(z_k)
    z_mid.append(z_mid_k)


D = sum((y[k] - z[k])**2 for k in range(0,n))
D = (math.sqrt(D)) / (math.sqrt(n))
print("\nСКО Δ:", D)

d = sum(y[k]**2 for k in range(0,n))
d = D / d
print("\nотн. погрешность δ:", d)
print()

for k in range(n):
    print("x:", x[k], "  y:", y[k], "  y*:", z[k], "  |y - y*|:", abs(y[k] - z[k]))
    if k != n-1:
        print("x:", mids[k], "          y*:", z_mid[k])
