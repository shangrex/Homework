#include <iostream>
#include <time.h>
#include <fstream>
#include <vector>
#include <algorithm>
#include <typeinfo>
#include <bits/stdc++.h>
#include <vector>
using namespace std;
int arr[100000000];
void initial_split(FILE * file_in, int block_size, int* count_pages, vector<FILE*> *pages){
    //load to output temp file and sort
    int data;
    int num_data = 0;
    //int arr[block_size]; since global can do 10^8 size
    bool check = true;
    int cc = 0;
    int i ;
    while(check){
        //scan the input file in to block
        for(i = 0; i < block_size; i++){
            fscanf(file_in, "%d" , &arr[i]);
            if(feof(file_in) != 0){
                i++;
                check = false;
                break;
            }
        }
        

        sort(arr, arr+i);

        cout << "out_temp_" << (*count_pages)+1 << ".txt has been sorted. " << endl;
        (*count_pages) ++ ;
        //store in out_temp file
        string title = "out_temp_" + to_string(*count_pages) + ".txt";
        (*pages).resize(*count_pages);
        (*pages)[*count_pages-1] = fopen(title.c_str(), "w+");
        if((*pages)[*count_pages-1] == NULL){
            cout << "out_temp_" + to_string(*count_pages) + ".txt" << " can not open" << endl;
        }
        else {
            for(int j = 0; j < i; j++){
                fprintf((*pages)[(*count_pages)-1],"%d" ,arr[j]);
                if(j != i-1)fprintf((*pages)[(*count_pages)-1], "\n");
                cc++;
            }
            //cout << "# of fpirntf " << cc << endl; 
            if(check==false)break;
            //fclose((*pages)[(*count_pages)-1]);
        }
    }
    //turn read mode to write mode
    for(int i = 0; i < (*count_pages); i++)
        rewind((*pages)[i]);    

    cout << "finish initial split" << endl;
}
void merge_file(FILE *file_out, int block_size, int sum_pages, vector<FILE*>*pages){
    //priority_queue <int, vector<int>, greater<int> > pq(block_size); 
    bool check = true;
    int count_pages = 0; // count the null pages
    //int arr[sum_pages];
    int standard = 0; //standard to record the min key value
    int standard_pages; // record the min key index
    bool check_file[sum_pages];// check the file is empty or not
    memset(check_file, 0, sizeof(check_file));
    //initialize block 
    for(int i = 0; i < sum_pages; i++){
        int tmp;
        fscanf((*pages)[i], "%d", &tmp);
        arr[i] = tmp;
    }
    //cout << endl;
    //do selection sort
    while(count_pages != sum_pages){
        //cout << count_pages << endl;
        standard = arr[0];
        standard_pages = 0;
        //find the min key
        for(int i = 0; i < sum_pages; i++){ 
            if(standard > arr[i]){
                standard = arr[i];
                standard_pages = i;
            }
        }
        //input the min key index value
        int tmp;
        fscanf((*pages)[standard_pages], "%d", &tmp);
        arr[standard_pages] = tmp;
  
        if(feof((*pages)[standard_pages]) != 0 && check_file[standard_pages] == 0){ //the file is empty and count the # of empty file
            //cout << "out_temp_" << standard_pages << ".txt has been empty." << endl;
            check_file[standard_pages] = 1;
            fprintf(file_out, "%d\n", standard);
        }
        else if(feof((*pages)[standard_pages]) != 0 && check_file[standard_pages] == 1){
            fprintf(file_out, "%d\n", standard);
            arr[standard_pages] = INT_MAX;
            count_pages++;
        }
        else {
            fprintf(file_out, "%d\n", standard); //write file
        }
        
    }

    for(int i = 0; i < sum_pages; i++){
        string title = "out_temp_" + to_string(i+1) + ".txt";
        if (remove(title.c_str()) != 0)
            cout<<"Remove operation failed"<<endl;
        else
            //cout<< "out_temp_" << to_string(i) <<".txt has been removed."<<endl;
            ;
    }
    for(int i = 0; i < sum_pages; i++){
        fclose((*pages)[i]);
    }
    
    cout << "finish merge" << endl;
}
int main(int argc, char* argv[]){
    cout.unsetf(ios::scientific);
    FILE *file_in;
    FILE *file_out;
    clock_t start, end;
    file_in = fopen(argv[1], "r");
    file_out = fopen("output.txt", "w");
    int block_size = 100000000;
    //cin >> block_size;
    int count_pages = 0;
    start = clock();
    vector<FILE*>pages;
    if(file_in){
        initial_split(file_in, block_size, &count_pages, &pages);
        end = clock();
        cout << "split time " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;
        merge_file(file_out , block_size, count_pages, &pages);
    }
    else{
        cout << "file can not open" << endl;
    }
    end = clock();
    cout << "total execution time " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;

    fclose(file_in);
    fclose(file_out);   
    return 0;
}