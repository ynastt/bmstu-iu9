## ТЗ  Lab #2

Написать простейший "компилятор" на базе LLVM, который ничего на вход не берёт. Генерирует LLVM код для функции

int main()
{
     return 353 + 48;
}

Простейший компилятор должен печатать LLVM-код на консоль


## Зависимости 
```sudo apt install llvm```  
```sudo apt install clang```  

## Запуск
```clang++ lab2.cpp `llvm-config --cxxflags --ldflags --system-libs --libs engine interpreter` -lffi```  
```./a.out```
