#include <iostream>
#include <fstream>
#include <bits/stdc++.h>
#include <thread>
#include <time.h>
#include <mutex>
using namespace std;
mutex mu;
void consumer(int *array, int batch_pos, int batch_size, int array_size, string *s){
    cout << batch_pos << endl;
    for(int i = 0; i < batch_size/20; i+=1){
        if(batch_pos+i*20+20 > array_size)break;
        if(batch_pos != 0 || i != 0){
            *s += ",{\n";
        }
        for(int j = 0; j < 20; j++){
            
            *s +=  "\"col_" + to_string(j+1) + "\":" + to_string(array[batch_pos+i*20+j]);
            if(j < 19) *s += ",\n";
            else *s +=  "\n";
            
        }
        *s += "}\n";
    }   
    
}
int main(){
    clock_t start, end;
    int thread_num;
    cin >> thread_num;
    FILE *file_in = fopen("input.txt", "r");
    if(file_in){
        start = clock();
        fstream file_out("output.json", ios::app);
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
        string s[thread_num];
        thread producer[thread_num];
        for(int i = 0; i < thread_num; i++){
            producer[i] = thread(consumer, array, batch_size*i, batch_size, array_size, &s[i]);
        }
        for(int i = 0; i < thread_num; i++){
            producer[i].join();
        }
        for(int i = 0; i < thread_num; i++){
            file_out << s[i];
        }
        file_out << "]";
        end = clock();
        cout << "total execution time " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;
        file_out.close();
        fclose(file_in);
    }
    else {
        cout << "Error in reading input.txt" << endl;
    }
    return 0;
}