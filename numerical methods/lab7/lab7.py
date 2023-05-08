import numpy as np
import pandas as pd
from tabulate import tabulate

def simple_iter_method(x, a, b):
    x1 = [0] * len(b)
    for i in range(len(x)):
        s = 0
        for j in range(len(x)):
            if i != j:
                s += a[i][j] * x[j]
        x1[i] = (b[i] - s) / a[i][i]
    return x1


def calc_X_norm(xk_new, xk_old):
    D = 0
    for i in range(len(xk_new)):
        D = max(abs(xk_new[i] - xk_old[i]), D)
    return D


def zeidel(A, b, eps):
    N = len(A)
    F_v = [[0] * N for i in range(N)]
    F_n = [[0] * N for i in range(N)]
    c = [0] * N
    for i in range(N):
        for j in range(N):
            if i < j:
                F_v[i][j] = -A[i][j] / A[i][i]
            elif i > j:
                F_n[i][j] = -A[i][j] / A[i][i]
        c[i] = b[i] / A[i][i]

    Xk1 = c.copy()
    Xk2 = c.copy()

    x_norm = 1
    iters = 0

    while x_norm > eps:
        t = Xk2
        Xk2 = [0] * N

        for i in range(N):
            for j in range(N):
                Xk2[i] += F_n[i][j] * t[j] + F_v[i][j] * Xk1[j]
            Xk2[i] += c[i]
        x_norm = calc_X_norm(Xk2, t)
        Xk1 = t
        iters += 1
    print("iters:", iters)
    return Xk2


def true_solution():
    return [1626087/6243449, -444093/6243449, 1666859/6243449, 1297732/6243449]

if __name__ == "__main__":
    k = 29
    aa = 0.1 * k
    bb = 0.1 * k

    a = np.array([[10.0 + aa, -1.0, 0.2, 2.0], [1.0, 12.0 - aa, -2.0, 0.1], [0.3, -4.0, 12.0 - aa, 1.0], [0.2, -0.3, -0.5, 8.0 - aa]])

    b = np.array([1.0 + bb, 2.0 - bb, 3.0, 1.0])
    
    print(a)
    print(b)
    blen = len(b)

    x = [0] * blen
    c = [0] * blen
    for i in range(blen):
        x[i] = b[i] / a[i][i]
        c[i] = x[i]

    f = []
    for i in range(blen):
        f.append([0] * blen)
        for j in range(blen):
            if i == j:
                f[i][j] = 0
            else:
                f[i][j] = -a[i][j] / a[i][i]
    
    print("\n--Simple iteration method--")
    print('\nF:')
    for i in f:
        print(i)

    print('\nC:', c)

    f_norm = -1
    for i in range(blen):
        s = 0
        for j in range(blen):
            s += abs(f[i][j])
        if s < 1:
            f_norm = max(s, f_norm)

    print('\n||F||:', f_norm)

    iters = 0
    while True:
        iters += 1
        x1 = simple_iter_method(x, a, b)

        D = 0
        for i in range(len(x)):
            D = max(abs(x1[i] - x[i]), D)

        Delta = 0
        for i in range(len(x)):
            Delta = max(abs(x1[i]), Delta)

        delta = D / Delta

        print()
        print("iter:", iters)
        print("Δ_k:", Delta)
        print("δ_k:", delta)

        if delta < 0.01:
            print("\nstop\n")
            break
        else:
            x = x1

    print("X:", x)
    new_b = [0] * blen
    for i in range(blen):
        for j in range(blen):
            new_b[i] += a[i][j] * x1[j]
    print("B:", new_b)

    print("\n--Zeidel's method--\n")
    new_x = zeidel(a, b, 0.0001)

    print("X", new_x)
    new_b = [0] * blen
    for i in range(blen):
        for j in range(blen):
            new_b[i] += a[i][j] * new_x[j]
    print("B:", new_b)

    rr = true_solution()
    # print("true solution:", rr)
    print()
    diff1 = [np.abs(rr[i] - x[i]) for i in range(len(rr))]
    diff2 = [np.abs(rr[i] - new_x[i]) for i in range(len(rr))]
    dd = {"true x*": rr, "simple iter x_s": x, "zeidel x_z": new_x,  "|x* - x_s|": diff1, "|x* - x_z|": diff2}
    res = pd.DataFrame(dd)
    print(tabulate(res, headers='keys', tablefmt='github', showindex=False))
