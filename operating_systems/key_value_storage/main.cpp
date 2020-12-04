#include <bits/stdc++.h>
#include <time.h>
using namespace std;
int main(int argc, char *argv[]){
    fstream file_in(argv[1], ios::in);
    clock_t start, end;
    string s;
    start = clock();
    while(file_in >> s){
        string key, value;
        if(s == "PUT"){
            file_in >> key;
            file_in >> value;
        }
        else if(s == "GET"){
            file_in >> key;    
        }
        else if(s == "SCAN"){
            string l_sc, r_sc;
            file_in >> l_sc;
            cout << l_sc << endl;
            file_in >> r_sc;
            cout << r_sc << endl;
        }
    }
    end = clock();
    cout << "total execution time: " << ((double) (end - start)) / CLOCKS_PER_SEC  << " secs" << endl;
    cout << end - start << endl;
    return 0;
}