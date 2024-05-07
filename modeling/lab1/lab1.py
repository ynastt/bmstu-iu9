# модель Лотки-Вольтерра 
from scipy.integrate import solve_ivp
import matplotlib.pyplot as plt
import numpy as np

# alpha = 0.045
# beta = 0.0001 
# gamma = 0.99998
# delta = 0.00002 

# alpha = 2/3
# beta = 4/3
# gamma = 1
# delta = 1


alpha = 0.075 # коэффициент рождаемость китов (рождаются и + к популяции)
beta = 0.00002 # не киты умирают с вероятностью 0ю99998, 0.00002 - коэф вероятности встречи китов и суден с квотами на убийство кита
delta = 0.0001 # коэффициент выдачи квот
gamma = 0.99998 # смертность квот: встречаем кита (уничтожен) - квота будет израсходована 


# dx/dt
def find_x_deriv(x, y):
	return x * (alpha - beta * y)

# dy/dt
def find_y_deriv(x, y):
	return y * (-gamma + delta * x)

def func(t, xy0):
	x_new = find_x_deriv(xy0[0], xy0[1])
	y_new = find_y_deriv(xy0[0], xy0[1])
	return x_new, y_new

def find_chisl(x, y, n):
	t = (0, n)
	x0 = x
	y0 = y
	system0 = [x0, y0]
	return solve_ivp(func, t, system0)
	

def find_chisl_linerised(x0, y0, n):
	xs = [x0]
	ys = [y0]
	ts = [0]
	prev_x = x0 
	prev_y = y0 
	prev_t = 0.0
	t = 0.0
	eps  = 0.01

	while t <= n:
		ts.append(t)
		delta_t = t - prev_t
		prev_t = t

		x_val = prev_x + prev_x * (alpha - beta * prev_y) * delta_t
		y_val = prev_y + prev_y * (-gamma + delta * prev_x) * delta_t
		xs.append(x_val)
		ys.append(y_val)
		
		prev_x = x_val
		prev_y = y_val
		
		t += eps

	return xs, ys, ts

if __name__ == "__main__":
	print(f">\n alpha={alpha}, beta={beta}, gamma={gamma}, delta={delta}")
	x = 20523 
	y = 1000
	print(f"x0={x}, y0={y}")
	n = 100
	coords = find_chisl(x, y, n)
	plt.plot(coords.t, coords.y[0], label="x", color='red')
	plt.plot(coords.t, coords.y[1], label="y", color= "green")
	plt.grid(True)
	plt.legend()
	plt.title("x(t) vs y(t) Runge Kutta")
	plt.show()

	coords_x, coords_y, coords_t = find_chisl_linerised(x, y, n)
	plt.plot(coords_t, coords_x, label="x", color='red')
	plt.plot(coords_t, coords_y, label="y", color= "green")
	plt.grid(True)
	plt.legend()
	plt.title("x(t) vs y(t) linerised")
	plt.show()
