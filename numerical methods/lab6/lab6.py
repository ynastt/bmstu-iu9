from sympy import *
import math

eps = 0.001

x, y = symbols('x y')

def f():
    return 3*x**2 - 3*x*y - 4*y**2 - 2*x + y

def analytical_min():
    return 1/3, 0.0

print('f: ', f())
fx = diff(f(), x)
fy = diff(f(), y)
print('df/dx: ', fx)
# print(diff(fx, x).subs({x: 1, y: 0}))
# print((fx.subs({x: 1, y: 0}))**2)
print('df/dy: ', fy)
print('d^2f/dx^2: ',diff(fx, x))
print('d^2f/dy^2: ',diff(fy, y))
print()
k = 0
xk, yk = 0.0, 0.0
# print(xk, yk)
# print( max(fx.subs({x: xk, y: yk}), fy.subs({x: xk, y:yk})))
while ( max(fx.subs({x: xk, y: yk}), fy.subs({x: xk, y:yk})) >= eps):
    # print('~ep:', max(fx.subs({x: xk, y: yk}), fy.subs({x: xk, y:yk})))
    # print('xk:', xk, 'yk:', yk)
    phi1 = - (fx.subs({x: xk, y: yk}))**2 - (fy.subs({x: xk, y: yk}))**2
    # print('phi1: ', phi1)
    phi2 = diff(fx, x).subs({x: xk, y: yk}) * (fx.subs({x: xk, y: yk}))**2 + 2 * diff(fx , y).subs({x: xk, y: yk}) * fx.subs({x: xk, y: yk}) * fy.subs({x: xk, y: yk}) + diff(fy, y).subs({x: xk, y: yk}) * (fy.subs({x: xk, y: yk}))**2
    # print('phi2: ', phi2)
    t_star = - phi1 / phi2
    # print('t*: ', t_star)
    xk = xk - t_star * fx.subs({x: xk, y: yk})
    yk = yk - t_star * fy.subs({x: xk, y: yk})
    k +=1

# print('\nMIN\n~ep:', max(fx.subs({x: xk, y: yk}), fy.subs({x: xk, y:yk})))
print(f'methods min {xk, yk}')
print (f'analytical min: {analytical_min()}')
print(f'difference: {math.fabs(xk -analytical_min()[0]), math.fabs(yk -analytical_min()[1])}')
