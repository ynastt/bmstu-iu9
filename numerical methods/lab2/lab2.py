import math

eps = 0.01

def testFunc(x):
    return math.exp(x)
    # return x * math.cos(x) ** 2

def richardsonFormula(I_h, I_h2, k):
    return (I_h - I_h2) / (2 ** k - 1)

def rect(f, a, b, n):
    h = (b - a) / n
    s = sum(f(a + (i - 0.5) * h) for i in range(1, n + 1))
    return h * s

def trap(f, a, b, n):
    h = (b - a) / n
    s = sum(f(a + i * h) for i in range(1, n))
    return h * ((f(a) + f(b)) / 2 + s)

def simp(f, a, b, n):
    h = (b - a) / n
    s1 = sum(f(a + i * h) for i in range(1, n))
    s2 = sum(f(a + (i - 0.5) * h) for i in range (1, n + 1))
    s3 = sum(f(a + (i - 1) * h) for i in range(1, n + 2))
    s = s1 + 4 * s2 + s3
    return h / 6 * s

def res(metd, k, a, b, f):
    n = 1
    R = 100
    iter = 0
    I_h = 0
    while not (abs(R) < eps):
        n *= 2
        I_h2 = I_h
        I_h = metd(f, a, b, n)
        R = richardsonFormula(I_h, I_h2, k)
        iter += 1
    print(f' iterations: {iter}')
    print(f' res: {I_h}')

if __name__ == "__main__":
    print("FUNC: exp(x)")
    for i in range(1,4) :
        print("\n-----------\nEPS = " + str(eps))
        print("\nCentral rectangles method: ")
        res(rect, 2, 0, 1, testFunc)
        print("\nTrapezoids method: ")
        res(trap, 2, 0, 1, testFunc)
        print("\nSimpson`s method: ")
        res(simp, 4, 0, 1, testFunc)
        eps = eps / 10
    
