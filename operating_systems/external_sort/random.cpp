#include <time.h>
#include <iostream>
#include <random>
#include <stdlib.h>
#include <fstream>
using namespace std;

int main(){
    clock_t start, end;
    cout << "input the # of bilion random number(GB)";
    long long int size;
    cin >> size;
    size *= 100000000;
    //size *= 10000;
    FILE * file;
    file  = fopen("input.txt", "w");
    start = clock();
    if(file){
        default_random_engine generator;
        uniform_int_distribution<int> distribution(-2147483648 ,2147483647);
        for(long long int i = 0;  i < size ; i++){
            int dice_roll = distribution(generator);
            fprintf(file, "%d", dice_roll);
            if(i != size-1)fprintf(file, "\n");
        }
        end = clock();
        cout << "the execution time is " << ((double) (end - start)) / CLOCKS_PER_SEC << " secs" << endl; 
        fclose(file);
    }
    else {
        cout << "file not open" << endl;
        fclose(file);
    }
    return 0;
}