package main

import (
	"fmt"
	"math"
)

const SIZE = 10

func f(x float64) float64 {
	return math.Exp(x)
}

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

func main() {
	var l, r, h float64 
	l , r = 0, 1
	h = (r - l) / SIZE
	xs := []float64{}
	for i := 0; i <= SIZE; i++ {
		xs = append(xs, float64(i) * h)
	}
	ys := []float64{}
	for i := 0; i <= SIZE; i++ {
		ys = append(ys, f(xs[i]))
	}

	fmt.Println("table for f(x):")
	for i := 0; i <= SIZE; i++ {
		fmt.Printf("%f; %f\n", xs[i], ys[i])
	}
	fmt.Println()

	d := []float64{}
	for i := 1; i < SIZE - 1; i++ {
		d = append(d, 3 * (ys[i + 1] - 2 * ys[i] + ys[i - 1]) / (h * h) )
	}

	b := []float64{}
	for i := 1; i < SIZE - 1; i++ {
		b = append(b, 4)
	}

	a := []float64{}
	for i := 1; i < SIZE - 2; i++ {
		a = append(a, 1)
	}

	c := []float64{}
	for i := 1; i < SIZE - 2; i++ {
		c = append(c, 1)
	}

	alpha, beta := direct(b, a, c, d, SIZE - 2)
	coefC := reverse(alpha, beta, SIZE - 2)
	coefC = append([]float64{0}, coefC...)

	coefA :=  make([]float64, 0, SIZE - 1)
	for i := 0; i < SIZE - 1; i++ {
		coefA = append(coefA, ys[i])
	}

	coefB := make([]float64, 0, SIZE - 1)
	for i := 0; i < SIZE - 2; i++ {
		coefB = append(coefB, (ys[i + 1] - ys[i]) / h - h / 3 * (coefC[i + 1] + 2 * coefC[i]))
	}
	coefB = append(coefB, (ys[SIZE - 1]-ys[SIZE - 2]) / h - 2.0 / 3 * h * coefC[SIZE - 2])

	coefD := make([]float64, 0, SIZE-1)
	for i := 0; i < SIZE - 2; i++ {
		coefD = append(coefD, (coefC[i + 1] - coefC[i]) / ( 3 * h))
	}
	coefD = append(coefD, -coefC[len(coefC) - 1] / (3 * h))


	fmt.Println("coefA: ", coefA)
	fmt.Println("coefB: ", coefB)
	fmt.Println("coefC: ", coefC)
	fmt.Println("coefD: ", coefD)
	
	fmt.Println("\nSplines in interpolation nodes:")
	for i := 0; i < SIZE - 1; i++ {
		varX := l + float64(i) * h
		varY := f(varX)
		s := coefA[i] + coefB[i] * (varX - xs[i]) + coefC[i] * math.Pow(varX - xs[i], 2) + coefD[i] * math.Pow(varX - xs[i], 3)
		fmt.Printf("xi: %f, yi: %f, yi*: %f, |yi-yi*|: %f\n", varX, varY, s, math.Abs(varY - s))
	}

	fmt.Println("\nSplines in the middles of interpolation nodes:")
	for i := 0; i < SIZE - 1; i++ {
		varX := l + (float64(i + 1) - 0.5) * h
		varY := f(varX)
		s := coefA[i] + coefB[i] * (varX - xs[i]) + coefC[i] * math.Pow(varX - xs[i], 2) + coefD[i] * math.Pow(varX - xs[i], 3)
		fmt.Printf("xi: %f, yi: %f, yi*: %f, |yi-yi*|: %f\n", varX, varY, s, math.Abs(varY - s))
	}
}
