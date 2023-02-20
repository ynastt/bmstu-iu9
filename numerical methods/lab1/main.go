package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
	"gonum.org/v1/gonum/mat"
)

var N int

func parseArrs(line string, N int) ([]float64, error) {
	arr := make([]float64, 0, N)
	//string -> []string
	strs := strings.Split(line, " ")

	for _, s := range strs {
		num, err := strconv.ParseFloat(s, 64)
		if err != nil {
			return nil, err
		} else {
			arr = append(arr, num)
		}
	}

	return arr, nil
}

func solution(a, b, c, d []float64) ([]float64) {
	x := make([]float64 , N)
	//forward
	var alpha, beta []float64
	alpha = append(alpha, - c[0] / b[0])
	beta = append(beta, d[0] / b[0])
	var y float64
	for i := 1; i < N; i++ {
		if i != N-1 {
			y = a[i-1] * alpha[i-1] + b[i]
			alpha = append(alpha, -c[i] / y)
            beta = append(beta, (d[i]-a[i-1] * beta[i-1]) / y)
		} else {
			y = a[N-2] * alpha[N-2] + b[N-1]
            beta = append(beta, (d[N-1] - a[N-2] * beta[N-2]) / y)
		}
	}
	//backwards
	for i := N-1; i >= 0; i-- {
		if i == N-1 { 
			x[N-1] = beta[N-1] 
		} else {
			x[i] = alpha[i] * x[i+1] + beta[i]
		}
	}
    return x
}

func makeMatrix(c, b, a []float64) [][]float64 {
	m := make([][]float64, N)
	for i := 0; i < N; i++ {
		m[i] = make([]float64, N)
	}
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			if i == j {
				m[i][j] = b[i]
				if i != N-1 {
					m[i][i+1] = c[i]
					m[i+1][i] = a[i]
				}
			}
		}
	}
	return m
}

func mulMatVec(matrix [][]float64, x []float64) []float64 {
	d := make([]float64, N)
	for i := 0; i < N; i++ {
		var s float64 = 0
		for j := 0; j < N; j++ {
			s += matrix[i][j] * x[j]
		}
		d[i] = s
	}
	return d
}

func main() {
	// tets<i>.txt = dimension; matrix: main diagonal, above diagonal , under diagonal; vector D
	file, err := os.Open("tests/test1.txt")
	if err != nil {
		log.Fatal(err.Error())
	}
	defer file.Close()

	var arrs []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		N, _ = strconv.Atoi(scanner.Text())
		break
	}
	for scanner.Scan() {
		arrs = append(arrs, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

	b, err := parseArrs(arrs[0], N)
	if err != nil {
		log.Fatal(err.Error())
	}
	c, err := parseArrs(arrs[1], N-1)
	if err != nil {
		log.Fatal(err.Error())
	}
	a, err := parseArrs(arrs[2], N-1)
	if err != nil {
		log.Fatal(err.Error())
	}
	d, err := parseArrs(arrs[3], N)
	if err != nil {
		log.Fatal(err.Error())
	}
	// a priori х = 1 1 1 1
	// a posteriori:
	x := solution(a, b, c, d)

	m := makeMatrix(c, b, a)
	matrix := make([]float64, 0)
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			matrix = append(matrix, m[i][j])
		}
	}
	mm := mat.NewDense(N, N, matrix)
	f := mat.Formatted(mm, mat.Prefix("    "), mat.Squeeze())
	fmt.Printf("A = %.16f\n\n", f)

	fmt.Print("X: ")
	for _, n := range x {
		fmt.Print(fmt.Sprintf("%.16f", n), " ")
	}
	fmt.Println()

	d_new := mulMatVec(m, x)
	fmt.Print("new vector d: ")
	for _, n := range d_new {
		fmt.Print(fmt.Sprintf("%.16f", n), " ")
	}
	fmt.Println()

	// the diference between old vector d and new vector d
	var dif float64
	r := make([]float64, 0)
	fmt.Print("vector r: ")
	for i := 0; i < N; i++ {
		dif = math.Abs(d[i] - d_new[i])
		r = append(r, dif)
		fmt.Print(fmt.Sprintf("%.16f", dif), " ")
	}
	fmt.Println()

	// the difference between a priori X and a posteriori X:
	// e = A^(-1) * r
	
	var inv mat.Dense
	err = inv.Inverse(mm)
	if err != nil {
		log.Fatalf("matrix is not invertible: %v", err)
	}
	f = mat.Formatted(&inv, mat.Prefix("         "), mat.Squeeze())
	fmt.Printf("\nA^(-1) = %.16f\n\n", f)
	
	inverted := inv.RawMatrix().Data
	inv_m := make([][]float64, N)
	for i := 0; i < N; i++ {
		inv_m[i] = make([]float64, N)
	}
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			inv_m[i][j] = inverted[i * N + j]
		}
	}
	
	e := mulMatVec(inv_m, r)
	fmt.Print("vector e: ")
	for _, n := range e {
		fmt.Print(fmt.Sprintf("%.16f", n), " ")
	}
	fmt.Println()
}