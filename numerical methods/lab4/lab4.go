// индивидуальный вариант 29
// метод прогонки
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
	return 3 * math.Sin(2 * x) 
}

//через вольфрам альфа 
func analytical(x float64) float64 {
	return (2 - 0.75 * x) * math.Cos(2 * x) + 1.5 * math.Sin(x) * math.Cos(x)  	
}

var (
	p = 0.0
	q = 4.0
	a = analytical(0)
	b = analytical(1)
)

func main() {
	fmt.Println("МЕТОД ПРОГОКНИ")
	fmt.Printf("y'' + %0.1fy' + %0.1fy = (2 - 0.75*x)*cos(2x) + 1.5*sin(x)*cos(x)\n", p, q)
	fmt.Printf("y(0) = %f\ny(1) = %f\n", a, b)
	n := 40
	fmt.Printf("Количество разбиений: %d\n", n)
	h := 1.0 / float64(n)
	//fmt.Println(h)
	xs := make([]float64, 0, n)
	for i := 0; i < n + 1; i++ {
		xs = append(xs, float64(i) * h)
	}
	
	as := make([]float64, 0, n - 2)
	bs := make([]float64, 0, n - 1)
	cs := make([]float64, 0, n - 2)
	ds := make([]float64, 0, n -1)

	for i := 1; i < n - 1; i++ {
		as = append(as, 1 - h / 2 *p)
		cs = append(cs, 1 + h / 2 * p)
	}

	for i := 1; i < n; i++ {
		bs = append(bs, h * h * q - 2)
	}

	ds = append(ds, h * h * f(0) - a * (1 - h / 2 * p))
	for i := 2; i < n; i++ {
		ds = append(ds, h * h * f(float64(i) * h))
	}
	ds[len(ds) - 1] = h * h * f(float64(len(ds) - 1) * h) - b * (1 + h / 2 * p)

	//fmt.Println(len(as), len(bs), len(cs), len(ds))
	fmt.Println("rang:", len(ds))
	alpha, beta := direct(bs, as, cs, ds, len(ds))
	ys := []float64{a}
	ys = append(ys, reverse(alpha, beta, len(ds))...)
	ys = append(ys, b)
	//fmt.Println(len(xs), len(ys))
	// for i := range ys {
	// 	fmt.Printf("x=%.1f, y=%.6f, y*=%.6f  |y-y*|=%.6f\n",
	// 		float64(i) * h, analytical(xs[i]), ys[i], math.Abs(ys[i] - analytical(xs[i])))
	// }
	maxInaccuracy := 0.0
	for i := 0; i < len(ys); i+=4 {
		fmt.Printf("x=%.1f, y=%.6f, y*=%.6f  |y-y*|=%.6f\n",
			float64(i) * h, analytical(xs[i]), ys[i], math.Abs(ys[i] - analytical(xs[i])))
			if math.Abs(ys[i] - analytical(xs[i])) > maxInaccuracy {
				maxInaccuracy = math.Abs(ys[i] - analytical(xs[i]))
			}
	}
	fmt.Printf("||y-y*||=%.6f\n", maxInaccuracy)
}
