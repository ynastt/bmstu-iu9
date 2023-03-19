// индивидуальный вариант
package main

import (
	"fmt"
	"math"
)

const SIZE = 8

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
	l , r = 1.0, 5.0
	h = (r - l) / SIZE

	xs := []float64{1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0}
	ys := []float64{3.33, 2.30, 1.60, 1.27, 1.18, 0.99, 1.41, 0.80, 1.12}

	fmt.Println("table for f(x):")
	for i := 0; i <= SIZE; i++ {
		fmt.Printf("%.1f; %.16f\n", xs[i], ys[i])
	}

	d := []float64{}
	for i := 1; i < SIZE; i++ {
		d = append(d, 3 * (ys[i + 1] - 2 * ys[i] + ys[i - 1]) / (h * h) )
	}

	b := []float64{}
	for i := 1; i < SIZE; i++ {
		b = append(b, 4)
	}

	a := []float64{}
	for i := 1; i < SIZE - 1; i++ {
		a = append(a, 1)
	}

	c := []float64{}
	for i := 1; i < SIZE - 1; i++ {
		c = append(c, 1)
	}

	alpha, beta := direct(b, a, c, d, SIZE - 1)
	coefC := reverse(alpha, beta, SIZE - 1)
	coefC = append([]float64{0}, coefC...)
	coefC = append(coefC, 0)
	
	coefA :=  make([]float64, 0, SIZE)
	for i := 1; i <= SIZE; i++ {
		coefA = append(coefA, ys[i - 1])
	}

	coefB := make([]float64, 0, SIZE + 1)
	for i := 1; i <= SIZE; i++ {
		coefB = append(coefB, (ys[i] - ys[i - 1]) / h - (h / 3) * (coefC[i] + 2 * coefC[i - 1]))
	}
	
	coefD := make([]float64, 0, SIZE)
	for i := 1; i <= SIZE; i++ {
		coefD = append(coefD, (coefC[i] - coefC[i - 1]) / ( 3 * h))
	}
	
	fmt.Println("\ninterpolation nodes:") // погрешность сопоставима с вычислительной
	for i := 0; i < SIZE; i++ {
		varX := l + float64(i) * h
		varY := ys[i]
		s := coefA[i] + coefB[i] * (varX - xs[i]) + coefC[i] * math.Pow(varX - xs[i], 2) + coefD[i] * math.Pow(varX - xs[i], 3)
		fmt.Printf("x: %.1f, y: %.16f, y*: %.16f, |y-y*|: %.16f\n", varX, varY, s, math.Abs(varY - s))
	}
	// ближе к краям тоже сопоставима с выч
	fmt.Println("\nin the middles of interpolation nodes:")
	for i := 0; i < SIZE; i++ {
		varX := l + (float64(i + 1) - 0.5) * h
		//varY := f(varX)
		s := coefA[i] + coefB[i] * (varX - xs[i]) + coefC[i] * math.Pow(varX - xs[i], 2) + coefD[i] * math.Pow(varX - xs[i], 3)
		fmt.Printf("x: %.2f, y*: %.16f\n", varX, s)
	}
}
