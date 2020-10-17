---
tags: homework
---

# OS HW1

* 學號：F74072138
* 姓名：黃上睿
* 系級：資訊111
## 開發環境：
1. OS: Ubuntu 18.04
2. CPU:Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz(4 core 8 thread)
3. Ｍemory: 
    * Mem: 23935 MB
    * swap: 8000 MB
5. Programming Language(version): 
    g++ (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0
7. GPU: GTX 1060(6G)
8. cache:
    * cache size	: 6144 KB 
    * cache_alignment	: 64
    * cached read: 8804.95 MB/sec
    * L1d cache:   32K
    * L1i cache:   32K
    * L2 cache:    256K
    * L3 cache:    6144K

9. Speed of disk:
    * disk read(hdparm -Tt):89.24 MB/sec

    * [O_DIRECT](https://kknews.cc/zh-tw/code/pyz8m8j.html): 104.61 MB/sec
    * [max disk write](https://askubuntu.com/questions/87035/how-to-check-hard-disk-performance)(fio):85.9MB/s
10. the maximum number of open file descriptors(ulimit -n)
    * 1024
11. pipe buffer size: 
    * 8*512 byte


## 程式執行相關數據：

|index|memory size|sec|usr/sys|
|-|-|-|-|-|
|1|31G|2531.77|2437/94|
|2|31G|2485.05|2395/92|
|3|31G|2498.66|2410/90|
|4|31G|2438.94|2395/90
|5|31G|2490.44|2401/91

|index|CPU cycles|intstruction|insn per cycle|
|-|-|-|-|
|1|7,910,572,210,911|15,591,426,719,848|1.98  |
|2|7,861,657,350,866|15,595,532,108,222|1.98|
|3|7,861,114,989,442|15,596,188,721,322|1.98
|4|7,856,300,177,939|15,594,975,681,551|1.99
|5|7,854,750,780,116|15,595,464,636,273|1.99

* branch miss: 1.3%
* average context switch: 70,073
    
## 程式開發與使用說明：
* 請在你的程式中加入量測執行時間的程式碼，以精準的獲取此數值。
    我是使用C++的<time.h>大致流程如下
    ```clike=
    start = clock()
    end = clock()
    total_time = (double)(end-start) / CPU_PER_CLOCK
    ```
* random.cpp
    * 這次產生random的檔案一開始可以先輸入輸入一個數字，代表想要產生大約多少GB的檔案，比如前者的31G大小就是輸入30所產生的，因為1G大約是$10^9$個數字。

    * 我是使用C++寫好的[random](http://www.cplusplus.com/reference/random/)，並指定其為uniform，就可以不用考慮分佈不平均的問題(mod)，只要把範圍先寫好。
    ```
        default_random_engine generator;
        uniform_int_distribution<int> distribution(-2147483648 ,2147483647);
    ```
    * 因為輸入的數字可能會超過int大小($2 * 10^9$)，所以我的size變數要先設成long long int
* sort.cpp
    * 是使用k-way的extenal sort，並把一個檔案分成以$10^8$為單位的pages，並命名為out_temp_X.txt(X為數字)，分成pages後做類似selection sort的作用，搜尋每一個pages的頭去找最小的，把最小的寫入output.txt，直到所有pages都是空的。如下圖。
    ![](https://i.imgur.com/AXDif64.png)
    程式的流程大概是長這樣
    ![](https://i.imgur.com/u5JVMCC.png)

* 程式執行範例：
```clike=
g++ random.cpp -o random
./random
input the # of data in a block size
30
g++ -Ofast sort.cpp -o sort
./sort input.txt
```

## 效能分析報告：
* 電腦閒置資源最小化。
我利用htop觀察電腦正在跑的程序，並利用kill id把不需要的程式給刪除
* 因為時間的關係，我把input大小改回11G，又因為我一個page是1G，所以我要把全部sort完，需要10個temp.txt檔
* 1.1G 下的時間分佈
    ```
    file 0start sort time 11.9837 secs
    file 0end_t sort time 42.647 secs
    out_temp_1.txt has been sorted. 
    file 1start write temp time 42.6691 secs
    file 1end write temp time 51.0488 secs
    finish initial split
    split time 51.0489 secs
    start merge time 51.0489 secs
    end merge time 73.2152 secs
    finish merge
    total execution time 73.6183 secs

    ```
可以觀察到有超過一半(42%)的時間都在做Internal sort，merge time佔大約30%, fprintf佔12%
* 程式大概可以分生幾個部份去做分析:
    * 前半部:
    程式執行split，cpu usage和internal sort相關，context switch和disk R/W相關，Disk I/O和I/O相關，context switch和cpu相關。
    * 後半部:
    程式執行merge
* Single process    
    1. memory usage
    ![](https://i.imgur.com/GMBE8Dl.png)
    表面上看起來都沒有明顯的變化。
    3. cpu usage
    ![](https://i.imgur.com/jJogbx5.png)
    * 觀察:
        * 可以發現，前半部cpu都是有周期的波動，判斷是在執行split函式，把input.txt拆分成10個暫存檔，並做sort，經過實驗是sort吃cpu資源最多。後半部，可以發現cpu佔用比不高。且htop後發現，是系統內部的程序在使用居多。
    * 驗證：
        * 寫一個簡單的sort.cpp並利用1GB的資料去跑，top之後就可以發現cpu都在處理他，cpu佔用率可達100%
    3. python分析
        * Disk R/W![](https://i.imgur.com/eoGCMgb.png)
        前半部，可以發現read都會比write先發生，這是因為要把input.txt 先 read才能寫到$out_temp_*.txt$，可以發現剛好就是10個週期，最後一個之所以浮動較小也是因為他的資料不是$10^9$
        後半部，可以發現disk read&write剛好分開的，也就是說程式正從out_temp_*.txt讀到output.txt
         * I/O![](https://i.imgur.com/GA6Moyl.png)
         I/O其實和 Disk R/W很像，因為I/O代表就是I/O request，也就是說一有request不會多久OS就會去做讀寫的工作
        * Page I/O![](https://i.imgur.com/b4r33n8.png)
        可以很明顯的感受到在500秒後，page I/O的output明顯開始增長，因為他要開始寫入output.txt
        * CPU usage
        total![](https://i.imgur.com/Vp6dso4.png)
        可以看到前半段是有週期性的在抖動，而進入後半段之後，cpu的值呈現極端的上升和下降，可以觀察到cpu上升的地方是disk read值大的地方，因為read代表著正在做selection的動作，需要做比較大小的判斷，故cpu usage提升，仔細觀察也可以發現有10個週期(一開始不算的話，那應該是開始跑程式)，根據實驗結果，cpu高峰應是在做 interanal sort
        distribution![](https://i.imgur.com/1bN326A.png)
        可以觀察到sys&usr的浮動息息相關，而wai都會提前作上升和下降，很符合他的定義。
        core usage![](https://i.imgur.com/FcBHDhx.png)
        可以看到一個internal sort由一個thread做，後半段則頻繁的在做context switch
        * memory usage:
        ![](https://i.imgur.com/9DtCBVJ.png)
        整個程式用不太到memory，[關於linux的記憶體資料](#summary)。
        * interrupt![](https://i.imgur.com/rxEOYZ2.png)
        放大來看![](https://i.imgur.com/RhAWvA6.png)
        可以發現和之後的system interrupt很像
        * swap usage![](https://i.imgur.com/jFm5TYN.png)
        因為記憶體一值都很足夠，所以swap一直都沒有用到
        * system![](https://i.imgur.com/l1F8E30.png)
        前半部剛好可以看做是10個週期，並且context switch的高峰發生在disk R/W切換部分
        根據維基百科可以發現context switch和interrupt相關，而且由圖可知，在context switch 發生時，Interrupt也會隨之增加。而且可以由觀察發現，context switch剛好也是10個週期，和cpu的週期很類似。
        
        * process![](https://i.imgur.com/PEYTFQH.png)
        ![](https://i.imgur.com/q2ZtFC8.png)
        參照OS的流程
        因為系統是專心在處理sort.cpp所以可以看到waiting(blk)很少，系統主要都在new&run process，而且可以發彥在後半部的waiting process有比較多的waiting，可能是因為selection的時候，有些資源必須等到其他東西寫入才能做。

* multi process(4 process)
    * 前處理：
        * 因為擔心file 之間的指標互相影響，導致程式之間不是獨立的，我把input.txt分成4個input1.txt, input2.txt......，另外也去把sort.cpp的程式碼改檔案的命名。
        * 指令：
            * dstat -d -r -g -i -m -p -s --output ~/homework/os/Entity/mul_stat.csv
            * dstat -C 0,1,2,3,4,5,6,7,total --output ~/homework/os/Entity/mul_cpu.csv
    * cpu usage:
    ![](https://i.imgur.com/LcWDSvi.png)
![](https://i.imgur.com/lEvIJoO.png)
    發現當所有sort程式都進入merge狀態時，cpu使用率其實都不高，但透過htop的表現可以發現，disk read & disk write的速度其實很高，並且都很平均分佈
    ![](https://i.imgur.com/1rCV3X5.png)
    ![](https://i.imgur.com/TXNahAz.png)
    ![](https://i.imgur.com/Doxjz4v.png)
    ![](https://i.imgur.com/DOMAvDd.png)
    ![](https://i.imgur.com/d878YWY.png)
    ![](https://i.imgur.com/qTWqxEs.png)
    ![](https://i.imgur.com/u33d0rO.png)
    * memory usage:
    開始沒多久
    ![](https://i.imgur.com/wdHCuo2.png)
    結束時
    ![](https://i.imgur.com/DsAgbUY.png)
    * 觀察：
        * 在91min分鐘左右，第一個sort完成，94min第二個sort完成，總長大概花費了105 min。 可以發現總時數比單獨執行四次還要常許多。多了大概1.5倍個執行時間，那些時間都拿去做context switch & I/O的處理。
        ```
        one time 1060 sec
        1060*4=4240
        four time simultaneously 6350 sec
        ```
        * compare:
        ![](https://i.imgur.com/AJHcpoM.png)
        可以發現，其實cpu usage和memory usage之間並沒有甚麼影響
        
        |index|split time(sec)|finish time(sec)
        |-|-|-|
        |1|740|1222|
        |2|740|1180|
        |3|755|1191|
        |4|732|1197|
    * python分析
        * Disk R/W![](https://i.imgur.com/tu6ZPin.png)
        可以發現他同時執行4個sort.cpp時，會盡量同步去做IO的處理，不會是集中資源先完成一個process
        * I/O![](https://i.imgur.com/NIzx6XN.png)

        * Page I/O![](https://i.imgur.com/Zh49l0a.png)
        * cpu usage
        total![](https://i.imgur.com/CMwCYBT.png)
        可以發現cpu已經沒有明顯週期了，因為都一直在做context switch，所以比較少idl的空閒。
        core![](https://i.imgur.com/ykDmQUx.png)
        可以發現8個thread都很平均的分布，不會有一個therad負責比較多的工作。
        distribution，觀察cpu:0的細部![](https://i.imgur.com/YfGMGKG.png)
        可以發現雖然total cpu usage沒有週期，但細看的話，內部的thread還是有週期，且浮動性很像單一cpu在跑，只是interval time比較長
        * memory usage![](https://i.imgur.com/iePw1pq.png)
        OS似乎又在控制memory usage讓她呈現很平衡的狀態。
        * interrupt![](https://i.imgur.com/P8xuzI5.png)
        放大來看![](https://i.imgur.com/G9ESEBD.png)
        可以很明顯的發現，interrupt的次數遠超單一process，符合預期，因為她要不斷的做context switch
        * swap usage![](https://i.imgur.com/EbUlkir.png)
        * system![](https://i.imgur.com/X7uGAva.png)
        前半部會有小周期，可能是因為sort時，並不會做去做context switch，他會一次把她sort完
        * Process![](https://i.imgur.com/tToBffk.png)
        因為context switch頻繁，且程序眾多，所以在waiting的process也比單一process的時候多很多。



### [python code](https://github.com/shangrex/Entity/blob/anaylyze/Untitled.ipynb)


* 優化你的程式（例如：降低執行時間）。
    * compile optimization
    ```
    g++ -Ofast sort.cpp -o sort
    ```
    initial external sort cost about 760 secs
    compile optimize cost
    * code 
        * 原先在pages儲存是採用動態vector
        * 排序1.1G 平均花費 90 sec
        * 後來把所有部份改寫成array
        * 排序1.1G 平均花費 74 sec
    * read & write 寫法(mmap)


* model
    * 1
        * goal:預測context switch
        * feature:
        * average loss:




* 你開發的排序程式對硬體效能優化程度的說明與驗證。
    * pipline
    * superscalar
    * out-ot-order execution
    * L1, L2 cache
    * banch prediction

## summary
排序程式下，你對系統效能的觀察，並結論OS的設計要提供哪些優化服務。
* branch predict
    * 因為在寫入檔案是我有一個for回圈裡有一個if來判斷最後要不要換行，這部份OS有做branch prediction
* cpu migration
    * 這點也可以從system monitor清楚的看出來(每個顏色都有高低峰值)，context switch可以使電腦更流暢的運作，而降低cpu migration也是OS重要的功能(降低I/O)
* page
    * 可以發現我們在執行的過程中記憶體用量依直都很少，其實這得歸功於page，OS利用virtual memory把許多不必要的記憶體都放回disk，導致memory usage並沒有在後其寫入資料時劇烈上升。
    * 可以看到page fault數字其實是蠻多的。
* system call
    * 可以發現，程式的執行時間分成usr time & sys time，因為在做檔案的操作時，必須呼叫system call 來做open, write, read和disk的讀寫
* [sync](https://man7.org/linux/man-pages/man2/open.2.html)
![](https://i.imgur.com/CqdfJie.png)
* [linux memory](https://blog.gtwang.org/linux/linux-cache-memory-linux/) 由cache, used, free, buff組成