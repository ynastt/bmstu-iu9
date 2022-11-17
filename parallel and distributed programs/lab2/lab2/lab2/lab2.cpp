#include <mpi.h>
#include <ctime>
#include <stdio.h>
#include <iostream>
#include <math.h>

using namespace std;

const long long N = 512;
const double eps = 0.0000001;
const double t = 0.1 / N;

void fillMatrix(double* matrix) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            if (i == j) matrix[i * N + j] = 2.0;
            else matrix[i * N + j] = 1.0;
        }
    }
}

void fillB(double* B) {
    for (int i = 0; i < N; i++) {
        B[i] = N + 1;
    }
}

void fillX(double* x) {
    for (int i = 0; i < N; i++) {
        x[i] = 0;
    }
}

void printMatrix(double* matrix) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%f ", matrix[i * N + j]);
        }
        printf("\n");
    }
}

void printVector(double* v) {
    cout << v[0];
    for (int i = 1; i < N; i++) {
        cout << ", " << v[i];
    }
    cout << endl;
}

void printX(double* x, int size) {
    cout << "Answer: " << x[0];
    for (int i = 1; i < size; i++) {
        cout << ", " << x[i];
    }
    cout << endl;
}

bool isAnswerCorrect(double* x) {
    for (int i = 0; i < N; i++) {
        if (abs(x[i] - 1.0) < 0.00001) {
            continue;
        }
        else {
            cout << "here " << i << " " << x[i] << endl;
            return false;
        }
    }
    return true;
}

double getNorm(double* v) {
    double s = 0;
    for (int i = 0; i < N; i++) {
        s += pow(v[i], 2);
    }
    s = sqrt(s);
    return s;
}

void mulMatrixByVector(double* matrix, double* x, double* y, int num) {
    // буфер для вычислений
    int buf_size = N * N / num;
    int rows_num = N / num;

    double* partOfA = new double[buf_size];

    // берем кусочек матрицы для процесса и ждем
    MPI_Scatter(matrix, buf_size, MPI_DOUBLE, partOfA, buf_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Barrier(MPI_COMM_WORLD);

    //умножаем матрицу на вектор
    double* res = new double[rows_num];
    for (int i = 0; i < rows_num; i++) {
        res[i] = 0;
        for (int j = 0; j < N; j++) {
            res[i] += partOfA[i * rows_num + j] * x[j];
        }
    }

    //отдаем посчитанный кусочек
    MPI_Gather(res, rows_num, MPI_DOUBLE, y, rows_num, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    delete[] partOfA;
    delete[] res;
}

void procFunc(int num_of_processes, int proc_rank, double* A, double* B, double* x, double* y) {
    double condition = eps;
    int k = 0;
    while (true) {
        cout << "_________________________iteration = " << k << "____________________________" << endl;
        k++;
        mulMatrixByVector(A, x, y, num_of_processes);
        if (proc_rank == 0) {
            for (int i = 0; i < N; i++) {
                y[i] -= B[i];
            }
            condition = getNorm(y) / getNorm(B);
        }
        MPI_Bcast(&condition, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
        if (condition < eps) {
            break;
        }
        MPI_Bcast(y, N, MPI_DOUBLE, 0, MPI_COMM_WORLD);
        if (proc_rank == 0) {
            for (int i = 0; i < N; i++) {
                x[i] -= t * y[i];
            }
        }
        cout << "probably ";
        printX(x, N);
        MPI_Bcast(x, N, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    }
}

int main(int argc, char* argv[]) {

    double* A = new double[N * N];
    double* B = new double[N];
    double* x = new double[N];
    double* y = new double[N];

    fillX(x);

    int num_of_processes;
    int proc_rank;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &num_of_processes);
    MPI_Comm_rank(MPI_COMM_WORLD, &proc_rank);

    if (num_of_processes == 1) {
        printf("\nProcess number equals to 1. Exit\n");
        MPI_Finalize();
        return 0;
    }
    if (proc_rank == 0) {
        printf("Generating matrix A, size %lldx%lld\n", N, N);
        fillMatrix(A);
        printMatrix(A);

        printf("Generating vector B, size %lld\n", N);
        fillB(B);
        printVector(B);

        fillX(y);
        printf("\n----------------Starting Calculations----------------\n");
    }
    double start = MPI_Wtime(); 
    MPI_Bcast(x, N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    procFunc(num_of_processes, proc_rank, A, B, x, y);

    MPI_Barrier(MPI_COMM_WORLD);
    double end = MPI_Wtime();
    if (proc_rank == 0) {
        printf("\n----------------Ending Calculations----------------\n");
        cout << "duration is " << end - start << " seconds for " << num_of_processes  << " threads" << endl;
        printX(x, N);
        if (!isAnswerCorrect(x)) {
            printf("\nERROR - THE WRONG ANSWER\n");
        }
        else {
            printf("\n!!THE RIGHT ANSWER!!\n");
        }
    }
    MPI_Finalize();

    delete[] A;
    delete[] B;
    delete[] x;
    delete[] y;

    return 0;
}
