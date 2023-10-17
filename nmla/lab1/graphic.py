import numpy as np
import matplotlib.pyplot as plt

def f(x):
    return x ** 2

# метод построения графика произвольной функции от
# одной переменной.
def show_chart(func, x_0, x_n):
    xs = np.linspace(x_0, x_n)
    ys = func(xs)
    figure, axs = plt.subplots()
    axs.plot(xs, ys)
    axs.set_xlim(x_0, x_n)
    plt.plot(xs, ys)
    plt.legend()
    plt.show()

# test
show_chart(f, -4, 4)