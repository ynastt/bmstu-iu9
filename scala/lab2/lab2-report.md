% Лабораторная работа № 2 «Введение в объектно-ориентированное программирование на языке Scala»
% 1 марта 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является изучение базовых объектно-ориентированных возможностей языка Scala.

# Индивидуальный вариант
Множество, конструируемое как множество строк, содержащих некоторую строку s. Операции: объединение («+»), 
пересечение («*»), проверка принадлежности строки множеству («in»).

# Реализация и тестирование

```scala
xxxxx
```

# Тестирование
Для тестирования необходимо в объекте ```Main``` в функции ```main``` задать значения переменной ```list```, 
связанную со списоком списков целых чисел, а также предикат длины конкатенируемых вложенных списков, 
передающийся в качестве параметра функции ```myflatten``` (это с 1 лабы осталось, надо поменять).
```scala

```

Результаты тестирования
```
---test1---
is sunny in set List(sun, sunset, sunn)? true
Set1: List(sun, sunset, sunn, sunny), formed from string "sun"
Set2: List(sunn, sunnyDays, sunny), formed from string "sunn"
Set1 + Set2: List(sun, sunny, sunnyDays, sunset, sunn), formed from string "sun"
Set1 * Set2: List(sunn, sunny), formed from string "sunn"
---test2---
Set1: List(a, ab, cad), formed from string "a"
Set2: List(b, ab, bad), formed from string "b"
Set1 + Set2: List(cad, a, b, ab, bad), formed from string "a"
Set1 * Set2: List(ab), formed from string "ab"
---test3---
Set1: List(a, aaa, caa), formed from string "a"
Set2: List(b, bbb, bbd), formed from string "b"
Set1 + Set2: List(bbd, a, caa, b, bbb, aaa), formed from string "a"
Set1 * Set2: List(), formed from string ""
```

# Вывод
читать документацию скалы :)
