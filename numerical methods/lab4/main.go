package main

import (
	"fmt"
	"math"
)

func direct(b, a, c, d []float64, size int) (alpha, beta []float64) {
	alpha = append(alpha, -c[0] / b[0])
	beta = append(beta, d[0] / b[0])
	var y float64
	for i := 1; i < size - 1; i++ {
		y = a[i - 1] * alpha[i - 1] + b[i]
		alpha = append(alpha, -c[i] / y)
		beta = append(beta, (d[i] - a[i - 1] * beta[i - 1]) / y)
	}
	y = a[size - 2] * alpha[size - 2] + b[size - 1]
	beta = append(beta, (d[size - 1] - a[size - 2] * beta[size - 2]) / y)
	return alpha, beta
}

func reverse(alpha, beta []float64, size int) (x []float64) {
	x = make([]float64, size)
	x[size - 1] = beta[size - 1]
	for i := size - 2; i >= 0; i-- {
		x[i] = alpha[i] * x[i + 1] + beta[i]
	}
	return x
}

func f(x float64) float64 {
	return math.Exp(x)
}

func analyticalSolution(x float64) float64 {
	return math.Exp(x)
}

var (
	p = 1.0
	q = -1.0
	a = 1.0
	b = math.E
)

func main() {
	n := 9
	h := 1.0 / float64(n+1)
	xs := make([]float64, 0, n+1)
	for i := 0; i <= n; i++ {
		xs = append(xs, float64(i) * h)
	}
	as := make([]float64, 0, n-1)
	bs := make([]float64, 0, n)
	cs := make([]float64, 0, n-1)
	ds := make([]float64, 0, n)

	for i := 0; i < n; i++ {
		as = append(as, 1 - h / 2 *p)
		cs = append(cs, 1 + h / 2 * p)
	}

	for i := 0; i < n + 1; i++ {
		bs = append(bs, h * h * q - 2)
		ds = append(ds, h * h * f(float64(i) * h))
	}

	ds[0] = h * h * f(0) - a * (1 - h / 2 * p)
	ds[len(ds) - 1] = h * h * f(float64(len(ds) - 1) * h) - b * (1 + h / 2 * p)

	alpha, beta := direct(bs, as, cs, ds, n + 1)
	ys := reverse(alpha, beta, n + 1)

	for i, y := range ys {
		fmt.Printf("x=%.16f, y=%.16f, y*=%.16f  |y-y*|=%.16f\n",
					xs[i], analyticalSolution(xs[i]), y, math.Abs(y-analyticalSolution(xs[i])))
	}
}
