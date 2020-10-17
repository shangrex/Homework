#include <iostream>
#include <fstream>
#include <bits/stdc++.h>
#include <time.h>
using namespace std;

int main(){
    clock_t start, end;
    int thread_num;
    fstream file_in("input.txt",ios::in);
    if(file_in){
        start = clock();
        fstream file_out("output.txt", ios::out);
        file_out << "[";
        string s;
        size_t pos = 0;
        int step = -1;
        while(!file_in.eof()){
            getline(file_in, s);

            if(step != -1)file_out << ",{\n";
            else file_out << "{\n";

            step = 1;
            string token;
            while ((pos = s.find('|')) != string::npos) {
                token = s.substr(0, pos);
                file_out << "\"col_" << step << "\":" << token;
                if(step < 20)file_out << ",";
                step++;
                s.erase(0, pos + 1);
            }
            file_out << "\"col_" << step << "\":" << token;
            file_out << "}\n";
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