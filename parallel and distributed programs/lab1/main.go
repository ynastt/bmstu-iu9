package main

import (
	"bufio"
	"fmt"
	"log"
	"math/rand"
	"os"
	"reflect"
	"strconv"
	"strings"
	"sync"
	"time"
)

var res [][]int

func randomFill(n int) [][]int {
	matrix := make([][]int, n)
	for i := 0; i < n; i++ {
		matrix[i] = make([]int, n)
		for j := 0; j < n; j++ {
			matrix[i][j] = rand.Intn(10)
		}
	}
	return matrix
}

func standardMatrixMul(a [][]int, b [][]int) [][]int {
	n := len(a)
	c := make([][]int, len(a))
	for i := 0; i < n; i++ {
		c[i] = make([]int, n)
		for j := 0; j < n; j++ {
			sum := 0
			for k := 0; k < n; k++ {
				sum += a[i][k] * b[k][j]
			}
			c[i][j] = sum
		}
	}
	return c
}

func columnsMatrixMul(a [][]int, b [][]int) [][]int {
	n := len(a)
	c := make([][]int, len(a))
	for i := 0; i < n; i++ {
		c[i] = make([]int, n)
	}
	for j := 0; j < n; j++ {
		for i := 0; i < n; i++ {
			sum := 0
			for k := 0; k < n; k++ {
				sum += a[i][k] * b[k][j]
			}
			c[i][j] = sum
		}
	}
	return c
}

func parallelCalcMatrix(a [][]int, b [][]int, res [][]int, s int, e int, n int, wg *sync.WaitGroup) {
	defer wg.Done()
	for i := s; i < e; i++ {
		res[i] = make([]int, n)
	}
	for i := s; i < e; i++ {
		for j := 0; j < n; j++ {
			sum := 0
			for k := 0; k < n; k++ {
				sum += a[i][k] * b[k][j]
			}
			res[i][j] = sum
		}
	}
}

func areMatricesEqual(a [][]int, b [][]int) bool {
	for i, v := range a {
		if reflect.DeepEqual(v, b[i]) {
			continue
		} else {
			return false
		}
	}
	return true
}

func main() {
	var c [][]int
	file, err := os.Open("test1.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	scanner.Scan()
	sc := scanner.Text()
	n, err := strconv.Atoi(sc)
	if err != nil {
		log.Fatal(err)
	}

	a := make([][]int, n)
	for i := range a {
		a[i] = make([]int, n)
	}
	for j := 0; j < n; j++ {
		scanner.Scan()
		sc = scanner.Text()
		words := strings.Split(sc, " ")
		for i := 0; i < n; i++ {
			a[j][i], err = strconv.Atoi(words[i])
			if err != nil {
				log.Fatal(err)
			}
		}
	}
	scanner.Scan()
	b := make([][]int, n)
	for i := range b {
		b[i] = make([]int, n)
	}
	for j := 0; j < n; j++ {
		scanner.Scan()
		sc = scanner.Text()
		words := strings.Split(sc, " ")
		for i := 0; i < n; i++ {
			b[j][i], err = strconv.Atoi(words[i])
			if err != nil {
				log.Fatal(err)
			}
		}
	}
	fmt.Println("matrix A")
	for i := 0; i < len(a); i++ {
		fmt.Println(a[i])
	}
	fmt.Println("matrix B")
	for i := 0; i < len(b); i++ {
		fmt.Println(b[i])
	}
	start1 := time.Now()
	c = standardMatrixMul(a, b)
	end1 := time.Now()
	fmt.Println("matrix AxB")
	for i := 0; i < len(c); i++ {
		fmt.Println(c[i])
	}
	dim := len(c)
	start2 := time.Now()
	c = columnsMatrixMul(a, b)
	end2 := time.Now()
	fmt.Println("matrix AxB another type")
	for i := 0; i < len(c); i++ {
		fmt.Println(c[i])
	}
	fmt.Println("============")
	var th int
	fmt.Println("Input num of threads")
	fmt.Scan(&th)
	/* for th threads*/
	s := 0
	d := n / th
	e := 0
	res = make([][]int, dim)
	var wg sync.WaitGroup
	start3 := time.Now()
	for k := th; k > 0; k-- {
		wg.Add(1)
		if k == 1 {
			e = n
		} else {
			e += d
		}
		go parallelCalcMatrix(a, b, res, s, e, dim, &wg)
		s = e
	}
	wg.Wait()
	end3 := time.Now()
	fmt.Println(res)
	fmt.Println("standard matrix multiplication takes", end1.Sub(start1))
	fmt.Println("matrix multiplication through columns takes", end2.Sub(start2))
	fmt.Println("parallel matrix multiplication through threads takes:", end3.Sub(start3))
	fmt.Println("threads", th)
	fmt.Println(areMatricesEqual(c, res))
}
