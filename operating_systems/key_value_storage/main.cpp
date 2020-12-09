#include <bits/stdc++.h>
#include <time.h>
using namespace std;
string cache_l[9999][9999];
string cache_h[9999][9999]; 

int main(int argc, char *argv[]){
    fstream file_in(argv[1], ios::in);
    string s = argv[1];   
    string out_file;
    s = s.substr(s.find_last_of("/")+1);
    cout << s << endl;
    out_file = s.substr(0, s.find("."));
    cout << out_file << endl;
    fstream file_out(out_file + ".output", ios::out);
    clock_t start, end;
    unordered_map<long long int, string> umap;
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