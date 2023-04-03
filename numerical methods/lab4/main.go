//метод прогонки
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

func analytical(x float64) float64 {
	return math.Exp(x)
}

var (
	p = 2.0
	q = -2.0
	a =  analytical(0) //1.0
	b = analytical(1) //math.E
)

func main() {
	fmt.Printf("y'' + %0.1fy' %0.1fy = exp(x)\n", p, q)
	fmt.Printf("y(0) = %f\ny(1) = %f\n", a, b)
	n := 9
	fmt.Printf("Количество разбиений: %d\n", n + 1)
	h := 1.0 / float64(n + 1)
	//fmt.Println(h)
	xs := make([]float64, 0, n + 2)
	for i := 0; i <= n + 1; i++ {
		xs = append(xs, float64(i) * h)
	}
	
	as := make([]float64, 0, n)
	bs := make([]float64, 0, n + 1)
	cs := make([]float64, 0, n)
	ds := make([]float64, 0, n + 1)

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

	alpha, beta := direct(bs, as, cs, ds, len(ds))
	ys := reverse(alpha, beta, len(ds))
	ys = append(ys, b)
	fmt.Println(len(xs), len(ys))
	for i := range ys {
		fmt.Printf("x=%.1f, y=%.16f, y*=%.16f  |y-y*|=%.16f\n",
			float64(i) * h, analytical(float64(i) * h), ys[i], math.Abs(ys[i] - analytical(float64(i) * h)))
	}
}
