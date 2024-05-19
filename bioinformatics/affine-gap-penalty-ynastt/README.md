[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/BrjuW67c)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=12868164&assignment_repo_type=AssignmentRepo)
# bioinf_assignment4
Задача - реализовать модификацию алгоритма NW с аффинным штрафом за пропуски.

Инсерция или делеция - это существенно более редкое эволюционное событие, чем замена нуклеотида. При этом за одно такое событие может быть вставлен или удален протяженный участок ДНК. Поэтому последовательные гэпы, т.е. вставки или делеции, имеет смысл штрафовать с учетом того, что это одна мутация, а не несколько.

Поэтому в отличие от базового алгоритма Нидлмана-Вунша, в котором используется фиксированное значение штрафа за гэп, здесь функция принимает вид:
```python
gap = open + (length - 1) * extend
```
где open - штраф за открытие (первый гэп), length - число последовательных гэпов в одной строке, extend - штраф за продолжение гэпа (со второго до последнего).

Пример:

пусть за совпадение нуклеодитов мы получаем +5, за открытие гэпа -10, за продолжнение -1.
Тогда оптимальным будет следующее выравнивание:
```
ACG---T
ACGGCTT
4 * (+5) + 1 * (-10) + 2 * (-1) = 8
```
но не, например, такое:
```
AC-G-T-
ACGGCTT
4 * (+5) + 3 * (-10) + 0 * (-1) = -10
```

Для решения используем матрицы, соответствующие случаям (A, A), (A, -) и (-, A).

Инициализируем:
```
M(0,0) = 0
I(0, 0) = D(0, 0) = infinity
M(i, 0) = infinity
I(i, 0) = open + (i - 1) * extend
D(i, 0) = infinity
M(0, j) = infinity
I(0, j) = infinity
D(0, j) = open + (j - 1) * extend
infinity >= 2 * open + (n + m) * extend + 1
```

Заполняем:
```
Match/Mismatch (две буквы):    
M(i, j) = max(M(i - 1, j - 1) + score(i, j), 
              I(i - 1, j - 1) + score(i, j), 
              D(i - 1, j - 1) + score(i, j))

Insertion (буква и гэп):    
I(i, j) = max(I(i, j - 1) + extend, 
              M(i, j - 1) + open)

Deletion (гэп и буква):    
D(i, j) = max(D(i - 1, j) + extend, 
              M(i - 1, j) + open)
              
Result(i, j) = max(M(i, j), I(i, j), D(i, j))
```

Восстанавливаем выравнивание по указателям или рассчитывая его по пути от Result[-1][-1] к Result[0][0].
