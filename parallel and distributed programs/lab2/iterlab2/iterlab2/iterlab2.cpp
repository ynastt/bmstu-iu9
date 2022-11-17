// iterlab2.cpp : итерационный алгоритм
#include <iostream>
#include <math.h>
#include <ctime>
#include <cmath>

using namespace std;

#define N_SIZE 512
#define eps 0.0000001
#define t 0.1/N_SIZE    //τ – константа, параметр метода

double A[N_SIZE][N_SIZE];
double B[N_SIZE];

template<int rows, int cols>
void FillMatrix(double(&matrix)[rows][cols]) {
    for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
            if (i == j) {
                matrix[i][j] = 2.0;
            }
            else {
                matrix[i][j] = 1.0;
            }
        }
    }
}

template<int rows, int cols>
void PrintMatrix(double(&matrix)[rows][cols]) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

void PrintX(double* x) {
    cout << "Answer: " << x[0];
    for (int i = 1; i < N_SIZE; i++) {
        cout << ", " << x[i];
    }
    cout << endl;
}

double getNorm(double* v) {
    double s = 0;
    for (int i = 0; i < N_SIZE; i++) {
        s += pow(v[i], 2);
    }
    s = sqrt(s);
    return s;
}

bool isAnswerCorrect(double* x) {
    PrintX(x);
    for (int i = 0; i < N_SIZE; i++) {
        if ( abs(x[i]- 1.0) < 0.00001 ) {
            continue;
        }
        else {
            cout << "here " << i << " " << x[i] << endl;
            return false;
        }
    }
    return true;
}

int main(int argc, char* argv[]) {
    FillMatrix(A);

    for (int i = 0; i < N_SIZE; i++) {
        B[i] = N_SIZE + 1;
    }

    double* x = new double[N_SIZE];

    for (int i = 0; i < N_SIZE; i++) {
        x[i] = 0;
    }

    clock_t start = clock();

    int k = 0;
    while (true) {
        cout << "========= iteration = " << k << " =========" << endl;
        double res[N_SIZE];
        for (int i = 0; i < N_SIZE; i++) {
            res[i] = 0;
        }

        for (int i = 0; i < N_SIZE; i++) {
            for (int j = 0; j < N_SIZE; j++) {
                res[i] += A[i][j] * x[j];
            }
        }

        for (int i = 0; i < N_SIZE; i++) {
            res[i] -= B[i];
        }
        PrintX(res);

        double sum1 = 0;
        sum1 = getNorm(res);
        //cout << "numerator  " << sum1 << endl;

        double sum2 = 0;
        sum2 = getNorm(B);
        //cout << "denominator  " << sum2 << endl;
        //cout << "the condition  " << sum1 / sum2 << endl;

        if (sum1 / sum2 < eps) {
            break;
        }
        else {
            for (int i = 0; i < N_SIZE; i++) {
                x[i] -= t * res[i];
            }
        }
        cout << "probably";
        PrintX(x);
        cout << endl;
        k++;
    }

    clock_t end = clock();
    double duration = ((double)(end - start)) / (double)CLOCKS_PER_SEC;

    if (isAnswerCorrect(x)) {
        cout << "right ans!" << endl;
        PrintX(x);
    }
    else {
        cout << "wrong ans!" << endl;
        PrintX(x);
    }
    cout << endl;
    cout << "Time: " << duration << endl;
    delete[] x;
    return 0;
}
