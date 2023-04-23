% Лабораторная работа № 1.1. Раскрутка самоприменимого компилятора
% 13 февраля 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является ознакомление с раскруткой самоприменимых компиляторов 
на примере модельного компилятора.

# Реализация
В варианте 15 в качестве модельного компилятора выступает компилятор P5. 
Основная зхадача - сделать так, чтобы символы в строке программы, расположенные справа от 100-й позиции, 
не учитывались (считались комментарием). Стоит отметить, что при отладке программы, в процесе обсуждения 
корректности условия с преподавателем, было решено заменить 100 на 102. 

Различие между файлами `pcom.pas` и `pcom2.pas`:

```diff
--- pcom.pas 2023-02-14 14:57:33.280533749 +0300
+++ pcom2.pas 2023-02-14 14:47:00.353069390 +0300
@@ -509,7 +509,7 @@
    kk: 1..maxids;      (*nr of chars in last identifier*)
    ch: char;           (*last character*)
    eol: boolean;       (*end of line flag*)
-
+   trash: char;        (*ADDED temp variable for symbols from 81 to eol*)

@@ -1290,8 +1290,14 @@

    procedure nextch;
-   begin if eol then
-       begin if list then writeln(output); endofline
+   begin
+   while (chcnt > 102) and (not eol) do
+   begin
+       read(input,trash);
+       eol := eoln(input)
+   end;
+   if eol then
+       begin if list then writeln(output); endofline
    end;
    if not eof(input) then
        begin eol := eoln(input); read(input,ch);
```

Различие между файлами `pcom2.pas` и `pcom3.pas`:

```diff
-- pcom2.pas 2023-02-14 14:47:00.353069390 +0300
+++ pcom3.pas 2023-02-14 14:52:32.461071017 +0300
@@ -436,7 +436,7 @@
        konst: (values: valu);
        vars:  (vkind: idkind; vlev: levrange; vaddr: addrrange);
        field: (fldaddr: addrrange);
-       proc, func: (pfaddr: addrrange; pflist: ctp; { param list }
+       proc, func: (pfaddr: addrrange; pflist: ctp; { param list}
                    case pfdeckind: declkind of
                standard: (key: 1..18);
                declared: (pflev: levrange; pfname: integer;
@@ -1757,7 +1757,8 @@
    scalar: begin write(output,'scalar':10);
                if scalkind = standard then
                    write(output,'standard':10)
-               else write(output,'declared':10,' ':4,ctptoint(*ord*)(fconst):intsize(*6*));
+               else write(output,'declared':10,' ':4,
+                           ctptoint(*ord*)(fconst):intsize(*6*));
                writeln(output)
            end;
    subrange: begin
@@ -1776,23 +1777,27 @@
                followstp(elset)
            end;
    arrays: begin
-               writeln(output,'array':10,' ':4,stptoint(*ord*)(aeltype):intsize(*6*),' ':4,
+               writeln(output,'array':10,' ':4,
+                   stptoint(*ord*)(aeltype):intsize(*6*),' ':4,
                    stptoint(*ord*)(inxtype):6);
                followstp(aeltype); followstp(inxtype)
            end;
    records: begin
-               writeln(output,'record':10,' ':4,ctptoint(*ord*)(fstfld):intsize(*6*),' ':4,
+               writeln(output,'record':10,' ':4,
+                   ctptoint(*ord*)(fstfld):intsize(*6*),' ':4,
                    stptoint(*ord*)(recvar):intsize(*6*)); followctp(fstfld);
                followstp(recvar)
            end;
    files: begin write(output,'file':10,' ':4,stptoint(*ord*)(filtype):intsize(*6*));
            followstp(filtype)
            end;
-   tagfld: begin writeln(output,'tagfld':10,' ':4,ctptoint(*ord*)(tagfieldp):intsize(*6*),
+   tagfld: begin writeln(output,'tagfld':10,' ':4,
+               ctptoint(*ord*)(tagfieldp):intsize(*6*),
                ' ':4,stptoint(*ord*)(fstvar):intsize(*6*));
                followstp(fstvar)
            end;
-   variant: begin writeln(output,'variant':10,' ':4,stptoint(*ord*)(nxtvar):intsize(*6*),
+   variant: begin writeln(output,'variant':10,' ':4,
+               stptoint(*ord*)(nxtvar):intsize(*6*),
                ' ':4,stptoint(*ord*)(subvar):intsize(*6*),varval.ival);
                followstp(nxtvar); followstp(subvar)
            end
@@ -1833,7 +1838,8 @@
            else write(output,'formal':10);
            write(output,' ':4,ctptoint(*ord*)(next):intsize(*6*),vlev,' ':4,vaddr:6 );
        end;
-   field: write(output,'field':10,' ':4,ctptoint(*ord*)(next):intsize(*6*),' ':4,fldaddr:6);
+   field: write(output,'field':10,' ':4,ctptoint(*ord*)(next):intsize(*6*),' ':4,
+           fldaddr:6);
    proc,
    func: begin
        if klass = proc then write(output,'procedure':10)
```

# Тестирование

Тестовый пример:

``` pascal
program hello(output);

begin
(* 101 symbol = C; 102 symbol = Q; *)
writeln('Hello, worldddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddCQ');
end.
```

Вывод тестового примера на `stdout`

```
P5 Pascal interpreter vs. 1.0

Assembling/loading program
Running program

Hello, worldddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddC

program complete
```

# Вывод
В ходе данной лабораторной работы было проведено ознакомление с раскруткой самоприменимых компиляторов на 
примере модельного компилятора P5, получен опыт программирования на языке Pascal и выполнена поставленная 
задача. Также были изучены особенности работы компилятора и его процесса раскрутки.
