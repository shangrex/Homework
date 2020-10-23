#include <iostream>
#include <fstream>
#include <bits/stdc++.h>
#include <thread>
#include <time.h>
#include <mutex>
using namespace std;
mutex mu;
void consumer(int *array, int batch_pos, int batch_size, fstream&file_out, int array_size){
    cout << batch_pos << endl;
    for(int i = 0; i < batch_size/20; i+=1){
        if(batch_pos+i*20+20 > array_size)break;
        if(batch_pos != 0 || i != 0){
            file_out << ",{\n";
        }
        for(int j = 0; j < 20; j++){
            file_out << "\"col_" << j+1 << "\":" << array[batch_pos+i*20+j];
            if(j < 19) file_out << ",\n";
            else file_out << "\n";
        }
        file_out << "}\n";
    }
    
}
int main(int argc, char *argv[]){
    clock_t start, end;
    int thread_num;
    thread_num = stoi(argv[1]);
    FILE *file_in = fopen("input.csv", "r");
    if(file_in){
        start = clock();
        fstream file_out("output.txt", ios::app);
        file_out << "[";
        file_out << "{\n";

        
        int *array = NULL;
        int array_size = 0;
        
        for(int i = 0;!feof(file_in); i++){
            //resize the size of array
            array = (int*)realloc(array, sizeof(int) * (array_size+20));
            //input data
            fscanf(file_in, "%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d"
            ,&array[0+array_size],&array[1+array_size],&array[2+array_size],&array[3+array_size],&array[4+array_size],&array[5+array_size],&array[6+array_size],&array[7+array_size],&array[8+array_size],&array[9+array_size]
            ,&array[10+array_size],&array[11+array_size],&array[12+array_size],&array[13+array_size],&array[14+array_size],&array[15+array_size],&array[16+array_size],&array[17+array_size]
            ,&array[18+array_size],&array[19+array_size]);
            
            //array size + 20
            array_size += 20;
            
        }
        cout << "array_size is " << array_size << endl;
        //determine the size of thread can do 
        int batch_size = array_size/thread_num + 20 - (array_size/thread_num)%20;
        cout << "batch size is " << batch_size << endl;
        char *json=NULL;
        thread producer[thread_num];
        for(int i = 0; i < thread_num; i++){
            producer[i] = thread(consumer, array, batch_size*i, batch_size, ref(file_out), array_size);
            producer[i].join();
        }
        file_out << "]";
        end = clock();
        cout << "total execution time " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;

    }
    else {
        cout << "Error in reading input.txt" << endl;
    }
    return 0;
}
