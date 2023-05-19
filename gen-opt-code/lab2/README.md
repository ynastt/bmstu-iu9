zavisimosti  
```sudo apt install llvm```  
```sudo apt install clang```  
zapusk  
```clang++ lab2.cpp `llvm-config --cxxflags --ldflags --system-libs --libs engine interpreter` -lffi```  
```./a.out```
