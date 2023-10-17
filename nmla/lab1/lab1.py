# Реализовать оценку погрешности вычисления объема шара зажатого
# цилиндром тремя способами при двух различных приближениях
# вычисления значения 2^0.5: 7/5 и 17/12
import math

def relative_error(counted, correct):
    return abs(correct - counted) / correct

# S = (sqrt(2) - 1) / (sqrt(2) + 1)
# точное значение S
correct_s = 0.005051

# три способа вычисления S
sss = [ 
    lambda sqrt : (sqrt - 1)**6 ,
    lambda sqrt : (3 - 2 * sqrt)**3 ,
    lambda sqrt : (99 - 70 * sqrt)
]

# аппроксимации корня из 2
approx_sqrt_2 = [1.3, 7/5 , 17/12]

# погрешность вычисления корня из 2
print(relative_error(7/5, math.sqrt(2)))
print(relative_error(17/12, math.sqrt(2)))

# вычисление S тремя способами при различных приближениях корня из 2
for i , sqrt in enumerate(approx_sqrt_2):
    s_i = []
    for j, f in enumerate(sss):
        s_i.append(f(sqrt))
    print(s_i)    

# погрешность вычисления объема шара при двух приближениях
# вычисления значения 2^0.5: 7/5 и 17/12
for j, f in enumerate(sss):
    print(relative_error(f(7/5), correct_s))

for j, f in enumerate(sss):
    print(relative_error(f(17/12), correct_s))
