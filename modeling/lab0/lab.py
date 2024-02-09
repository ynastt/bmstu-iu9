import math

radius = 0.1
rho = 7874
air_rho = 1.29
v_0 = 100
g = 9.8
alpha = 45

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
	# The Runge Kutta method of the 4th order
	coords = [(0, 0)]
	while coords[-1][1] >= 0:
		cur_v = v[-1]
		cur_u = cur_v[0] # u = V_x
		cur_w = cur_v[1] # w = V_y

		k1_u = h * find_u_deriv(betta, massa, cur_u, cur_w)
		k1_w = h * find_w_deriv(betta, massa, cur_u, cur_w)

		k2_u = h * find_u_deriv(betta, massa, cur_u + k1_u / 2, cur_w + k1_w / 2)
		k2_w = h * find_w_deriv(betta, massa, cur_u + k1_u / 2, cur_w + k1_w / 2)

		k3_u = h * find_u_deriv(betta, massa, cur_u + k2_u / 2, cur_w + k2_w / 2)
		k3_w = h * find_w_deriv(betta, massa, cur_u + k2_u / 2, cur_w + k2_w / 2)

		k4_u = h * find_u_deriv(betta, massa, cur_u + k3_u / 2, cur_w + k3_w / 2)
		k4_w = h * find_w_deriv(betta, massa, cur_u + k3_u / 2, cur_w + k3_w / 2)

		cur_u += (k1_u + 2 * k2_u + 2 * k3_u + k4_u) / 6
		cur_w += (k1_w + 2 * k2_w + 2 * k3_w + k4_w) / 6

		v.append((cur_u, cur_w))
		cur_coords = coords[-1]
		cur_coord_x = cur_coords[0] + h * cur_u
		cur_coord_y = cur_coords[1] + h * cur_w
		coords.append((cur_coord_x, cur_coord_y))

	return coords[-1][0]


if __name__ == "__main__":
	print("метод Галилея\n", galileo(v_0, alpha))
	print("метод Ньютона\n", newton(v_0, radius, rho, alpha))