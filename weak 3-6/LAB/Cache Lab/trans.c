/* 
 * trans.c - Matrix transpose B = A^T
 *
 * Each transpose function must have a prototype of the form:
 * void trans(int M, int N, int A[N][M], int B[M][N]);
 *
 * A transpose function is evaluated by counting the number of misses
 * on a 1KB direct mapped cache with a block size of 32 bytes.
 */ 
#include <stdio.h>
#include "cachelab.h"
#include <stdlib.h>

int is_transpose(int M, int N, int A[N][M], int B[M][N]);

int min(int x, int y){
    return x < y ? x : y;
}

/* 
 * transpose_submit - This is the solution transpose function that you
 *     will be graded on for Part B of the assignment. Do not change
 *     the description string "Transpose submission", as the driver
 *     searches for that string to identify the transpose function to
 *     be graded. 
 */
char transpose_submit_desc[] = "Transpose submission";
void transpose_submit(int M, int N, int A[N][M], int B[M][N])
{
    if (M == 32)
    {
        int i, j, k, s;
        int t0, t1, t2, t3, t4, t5, t6, t7;
        const int len = 8;
        for (i = 0; i < M; i += len) {
            for (j = 0; j < M; j += len) {
                for (k = i, s = j; k < i + len; k++, s++) {
                    t0 = A[k][j];
                    t1 = A[k][j + 1];
                    t2 = A[k][j + 2];
                    t3 = A[k][j + 3];
                    t4 = A[k][j + 4];
                    t5 = A[k][j + 5];
                    t6 = A[k][j + 6];
                    t7 = A[k][j + 7];
                    B[s][i] = t0;
                    B[s][i + 1] = t1;
                    B[s][i + 2] = t2;
                    B[s][i + 3] = t3;
                    B[s][i + 4] = t4;
                    B[s][i + 5] = t5;
                    B[s][i + 6] = t6;
                    B[s][i + 7] = t7;
                }
                for (k = 0; k < len; k++) {
                    for (s = k + 1; s < len; s++) {
                        t0 = B[k + j][s + i];
                        B[k + j][s + i] = B[s + j][k + i];
                        B[s + j][k + i] = t0;
                    }
                }
            }
        }
    }
    else if(M == 64){
        int i, j, k;
        int t0, t1, t2, t3, t4, t5, t6, t7;
        int tmp;
        const int len = 8;
        for (i = 0; i < M; i += len) {
            for (j = 0; j < N; j += len) {
                for (k = 0; k < len / 2; k++) {

                    t0 = A[k + i][j];
                    t1 = A[k + i][j + 1];
                    t2 = A[k + i][j + 2];
                    t3 = A[k + i][j + 3];
                    t4 = A[k + i][j + 4];
                    t5 = A[k + i][j + 5];
                    t6 = A[k + i][j + 6];
                    t7 = A[k + i][j + 7];

                    B[j][k + i] = t0;
                    B[j + 1][k + i] = t1;
                    B[j + 2][k + i] = t2;
                    B[j + 3][k + i] = t3;

                    B[j][k + 4 + i] = t4;
                    B[j + 1][k + 4 + i] = t5;
                    B[j + 2][k + 4 + i] = t6;
                    B[j + 3][k + 4 + i] = t7;
                }

                for (k = 0; k < len / 2; k++) {

                    t0 = A[i + 4][k + j];
                    t1 = A[i + 5][k + j];
                    t2 = A[i + 6][k + j];
                    t3 = A[i + 7][k + j];

                    t4 = A[i + 4][k + 4 + j];
                    t5 = A[i + 5][k + 4 + j];
                    t6 = A[i + 6][k + 4 + j];
                    t7 = A[i + 7][k + 4 + j];

                    tmp = B[k + j][i + 4];
                    B[k + j][i + 4] = t0;
                    t0 = tmp;

                    tmp = B[k + j][i + 5];
                    B[k + j][i + 5] = t1;
                    t1 = tmp;

                    tmp = B[k + j][i + 6];
                    B[k + j][i + 6] = t2;
                    t2 = tmp;

                    tmp = B[k + j][i + 7];
                    B[k + j][i + 7] = t3;
                    t3 = tmp;

                    B[k + j +4][i] = t0;
                    B[k + j +4][i + 1] = t1;
                    B[k + j +4][i + 2] = t2;
                    B[k + j +4][i + 3] = t3;

                    B[k + j +4][i + 4] = t4;
                    B[k + j +4][i + 5] = t5;
                    B[k + j +4][i + 6] = t6;
                    B[k + j +4][i + 7] = t7;

                }
            }
        }
    }
    else{
        int i, j, k, s, tmp;
        //int t0, t1, t2, t3, t4, t5, t6, t7; 
        /*
        for (i = 0; i < N; i += 8) {
            for (j = 0; j < M; j += 23) {
                if (i + 8 <= N && j + 23 <= M) {
                    for (s = j; s < j + 23; s++) {
                        t0 = A[i][s];
                        t1 = A[i + 1][s];
                        t2 = A[i + 2][s];
                        t3 = A[i + 3][s];
                        t4 = A[i + 4][s];
                        t5 = A[i + 5][s];
                        t6 = A[i + 6][s];
                        t7 = A[i + 7][s];
                        B[s][i + 0] = t0;
                        B[s][i + 1] = t1;
                        B[s][i + 2] = t2;
                        B[s][i + 3] = t3;
                        B[s][i + 4] = t4;
                        B[s][i + 5] = t5;
                        B[s][i + 6] = t6;
                        B[s][i + 7] = t7;
                    }
                } 
                else {
                    for (k = i; k < min(i + 8, N); k++) {
                        for (s = j; s < min(j + 23, M); s++) {
                            B[s][k] = A[k][s];
                        }
                    }
                }
            }
        }
        */
        for (i = 0; i < N; i+=17)
        {
            for (j = 0; j < M; j+=17)
            {
                for (k = i; k < i + 17 && k < N; k++)
                {
                    for (s = j; s < j + 17 && s < M; s++)
                    {
                        B[s][k] = A[k][s];
                    }
                }
            }
        }
    }
}

/* 
 * You can define additional transpose functions below. We've defined
 * a simple one below to help you get started. 
 */ 

/* 
 * trans - A simple baseline transpose function, not optimized for the cache.
 */
char trans_desc[] = "Simple row-wise scan transpose";
void trans(int M, int N, int A[N][M], int B[M][N])
{
    int i, j, tmp;

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; j++) {
            tmp = A[i][j];
            B[j][i] = tmp;
        }
    }    

}

/*
 * registerFunctions - This function registers your transpose
 *     functions with the driver.  At runtime, the driver will
 *     evaluate each of the registered functions and summarize their
 *     performance. This is a handy way to experiment with different
 *     transpose strategies.
 */
void registerFunctions()
{
    /* Register your solution function */
    registerTransFunction(transpose_submit, transpose_submit_desc); 

    /* Register any additional transpose functions */
    registerTransFunction(trans, trans_desc); 

}

/* 
 * is_transpose - This helper function checks if B is the transpose of
 *     A. You can check the correctness of your transpose by calling
 *     it before returning from the transpose function.
 */
int is_transpose(int M, int N, int A[N][M], int B[M][N])
{
    int i, j;

    for (i = 0; i < N; i++) {
        for (j = 0; j < M; ++j) {
            if (A[i][j] != B[j][i]) {
                return 0;
            }
        }
    }
    return 1;
}

