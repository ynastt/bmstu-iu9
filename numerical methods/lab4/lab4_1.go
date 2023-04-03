// метод стрельбы
package main

import (
	"fmt"
	"math"
)

func f(x float64) float64 {
	return math.Exp(x)
}

func analytical(x float64) float64 {
	return math.Exp(x)
}

var (
	n = 10
	p = 2.0
	q = -2.0
	a =  analytical(0) //1.0
	b = analytical(1) //math.E
	ys = make([][]float64, 2)
)

func getC1() float64 {
	return (b - ys[0][n]) / ys[1][n]
}

func getYi(i int) float64 {
	return ys[0][i] + getC1() * ys[1][i]
}

func main() {
	fmt.Printf("y'' + %0.1fy' %0.1fy = exp(x)\n", p, q)
	fmt.Printf("y(0) = %f\ny(1) = %f\n", a, b)
	fmt.Printf("Количество разбиений: %d\n", n)
	h := 1.0 / float64(n)
	xs := make([]float64, 0, n + 1)
	for i := 0; i <= n; i++ {
		xs = append(xs, float64(i) * h)
	}
	for i := 0; i < 2; i++ {
		ys[i] = make([]float64, 2, n)
	}
	ys[0][0], ys[0][1] = a, a + h
	ys[1][0], ys[1][1] = 0, h

	for i := 1; i < n; i++ {
		ys[0] = append(ys[0], 
				(h * h * f(xs[i]) + (2.0 - q * h * h) * ys[0][i] - (1.0 - h / 2 * p) * ys[0][i - 1]) / (1 + h / 2 * p))
		ys[1] = append(ys[1], 
				((2.0 - q * h * h) * ys[1][i] - (1.0 - h / 2 * p) * ys[1][i - 1]) / (1 + h / 2 * p))
	}

	y := make([]float64, 0, n + 1)
	y = append(y, a)
	for i := 1; i <= n; i++ {
		y = append(y, getYi(i))
	}
	
	for i := range y {
		fmt.Printf("x=%.1f, y=%.16f, y*=%.16f  |y-y*|=%.16f\n",
			float64(i) * h, analytical(float64(i) * h), y[i], math.Abs(y[i] - analytical(float64(i) * h)))
	}
}
