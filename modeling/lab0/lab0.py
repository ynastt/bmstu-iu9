import math

radius = 0.1
rho = 7874
air_rho = 1.29
v_0 = 100
g = 9.8
alph = 45

# m = pV
def find_massa(radius, p):
	V = 4/3 * math.pi * (radius ** 3)
	return p * V


# B = Csp / 2
def find_betta(radius, p, C=0.15):
	s = math.pi * (radius ** 2)
	return C * s * p/ 2


def galileo(speed, angle):
	alpha = math.radians(angle)
	return math.tan(alpha) * 2 * (math.cos(alpha) * speed) ** 2 / g


# u = V_x = V*cos(a)
def find_w(v, angle, t):
	return v * math.cos(math.radians(angle))

# w = V_y = V*sin(a)
def find_u(v, angle, t):
	return v * math.sin(math.radians(angle)) - g * t

# du/dt
def find_u_deriv(betta, m, u, w):
	return -betta * u * math.sqrt(u ** 2 + w ** 2) / m

# dw/dt
def find_w_deriv(betta, m, u, w):
	return -betta * w * math.sqrt(u ** 2 + w ** 2) / m - g

def newton(speed, radius, rho, angle, h=0.01):
	massa = find_massa(radius, rho)
	betta = find_betta(radius, air_rho) # rho
	v = [(find_u(speed, angle, 0), find_w(speed, angle, 0))]
	# print(f'v\n', v)
	# The Runge Kutta method of the 4th order
	coords = [(0, 0)]
	while coords[-1][1] >= 0:
		cur_v = v[-1]
		# print("cur_v:", cur_v)
		cur_u = cur_v[0] # u = V_x
		cur_w = cur_v[1] # w = V_y

		k1_u = h * find_u_deriv(betta, massa, cur_u, cur_w)
		k1_w = h * find_w_deriv(betta, massa, cur_u, cur_w)

		k2_u = h * find_u_deriv(betta, massa, cur_u + k1_u / 2, cur_w + k1_w / 2)
		k2_w = h * find_w_deriv(betta, massa, cur_u + k1_u / 2, cur_w + k1_w / 2)

		k3_u = h * find_u_deriv(betta, massa, cur_u + k2_u / 2, cur_w + k2_w / 2)
		k3_w = h * find_w_deriv(betta, massa, cur_u + k2_u / 2, cur_w + k2_w / 2)

		k4_u = h * find_u_deriv(betta, massa, cur_u + k3_u, cur_w + k3_w)
		k4_w = h * find_w_deriv(betta, massa, cur_u + k3_u, cur_w + k3_w)

		cur_u += (k1_u + 2 * k2_u + 2 * k3_u + k4_u) / 6
		cur_w += (k1_w + 2 * k2_w + 2 * k3_w + k4_w) / 6

		v.append((cur_u, cur_w))
		cur_coords = coords[-1]
		cur_coord_x = cur_coords[0] + h * cur_u
		cur_coord_y = cur_coords[1] + h * cur_w
		coords.append((cur_coord_x, cur_coord_y))

	return coords[-1][0]


if __name__ == "__main__":
	print(f">\n alpha={alph}, v0={v_0}")
	gl = galileo(v_0, alph)
	nw = newton(v_0, radius, rho, alph)
	print("метод Галилея\n", gl)
	print("метод Ньютона\n", nw)
	print("Разница: ", gl - nw)
	air_rho = 0
	nw0 = newton(v_0, radius, rho, alph)
	print("\nметод Ньютона c beta=0 \n", nw0)
	print("Разница: ", gl - nw0)
	

	print("\n\nОптимизация соотношения угла и начальной скорости в модели Ньютона")
	eps = 0.01
	v_0s = [98, 99, 100, 101, 102, 105, 110, 120, 130, 140]
	n_alphas = [25, 30, 40, 41, 42, 43, 44, 44.9, 44.99, 45, 46, 47, 48, 49, 50]
	best_params = []
	for v in v_0s:
		for a in n_alphas:
			print(f">\n alpha={a}, v0={v}")
			res = newton(v, radius, rho, a)
			print("Расстояние: ",  res)
			print("Соотношение alpha/v0:", a/v)
			if abs(45/100 - a/v) <= 0.01 and abs(res - 1020) < 100:
				print("FOUND BEST")
				best_params.append((a, v, res))

	print("\nНаилучшее соотношение параметров:")
	for p in best_params:
		if abs(p[2] - 1020) <= 0.5:
			print()
		print(f"Угол: {p[0]}, скорость: {p[1]}, расстояние: {p[2]}")

		if abs(p[2] - 1020) <= 0.5:
			print()



