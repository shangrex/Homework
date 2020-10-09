import json
import numpy as np 
import time
import pandas as pd
import threading
from threading import Thread


def job():
    with open("input.txt") as file_in:
        s = []
        for i in range(1,21):
            col_name = "col_"+str(i)
            s.append(col_name)
            #print(col_name)
        start = time.time()
        df = pd.read_csv(file_in, names=s, delimiter='|')
        ans_json = df.to_json()
        print("csv to json time ",time.time()-start)
        print(ans_json)
    file = open("output.json", "w")
    file.write(ans_json)
    file.close()
if __name__ == "__main__":
    start = time.time()
    t = threading.Thread(target = job)
    t.start()
    t.join()
    print("total execute time ",time.time()-start)
