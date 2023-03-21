% Лабораторная работа № 2.1. Синтаксические деревья
% 21 февраля 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является изучение представления синтаксических деревьев 
в памяти компилятора и приобретение навыков преобразования синтаксических деревьев.

# Постановка задачи
Необходимо реализовать преобразование синтаксического дерева так, чтобы каждое вхождение строкового литерала 
в текст программы было заменено идентификатором константы, добавленной в начало программы 
и имеющей соответствующее значение (при этом значения добавляемых констант не должны дублироваться).

## Особенности реализации

## Работа со строковыми литералами
Для решения поставленной задачи необходимо найти узлы синтаксического дерева, 
в которых присутствуют строковые литералы. Результат анализа дерева демонстрационной программы показал, что 
всего три типа узлов, содержащих 
строковые литералы: 
- узлы, образованные при инициализации глобальных строковых переменных вне функции main
- узлы, образованные при вызове методов или функций с аргументом-строкой внутри main
- узлы, образованные при инициализации локальных строковых переменных внутри функции  main

При обходе синтаксического дерева надо предусмотреть все рассмотренные варианты. Обход синтаксического дерева 
реализован в функции`replaceStringLitWithConst`. 

## Работа с идентификаторами констант
Для вставки идентификаторов констант, добавленных в начало программы и имеющих  значения соответствующих 
строковых литералов, решено реализовать отдельную функцию `insertStringConst`, которая будет 
вызываться для каждого строкового литерала, найденного в тексте программы при обходе синтаксического дерева.
Для отсутствия констант с дублирующимися значениями решено использовать дополнительную проверку 
с помощью хэш-таблицы (тип map в Go)

# Реализация

Демонстрационная программа:

```go
package main

import "fmt"

var s string = "tt"

func main() {
    fmt.Println(s)
    fmt.Println("Hello,")
    fmt.Println("World!")

    var x string = "Goodbye!"
    fmt.Println(x)
}
```

Программа, осуществляющая преобразование синтаксического дерева:

```go
package main

import (
    "fmt"
    "go/ast"
    "go/format"
    "go/parser"
    "go/token"
    "os"
    "strings"
    "unicode"
)

func insertStringConst(file *ast.File, name string, value string, exist map[string]bool) {
    var before, after []ast.Decl
    // constant value -> constant name
    if len(file.Decls) > 0 {
	hasImport := false
	if genDecl, ok := file.Decls[0].(*ast.GenDecl); ok {
	    hasImport = genDecl.Tok == token.IMPORT
	}

	if hasImport {
	    before, after = []ast.Decl{file.Decls[0]}, file.Decls[1:]
	} else {
	    after = file.Decls
	}
    }

    if _, ok := exist[value]; !ok {
	file.Decls = append(before,
	    &ast.GenDecl{
	        Tok: token.CONST,
		Specs: []ast.Spec{
		    &ast.ValueSpec{
			Names: []*ast.Ident{ast.NewIdent(name)},
			Type:  ast.NewIdent("string"),
			Values: []ast.Expr{
			    &ast.BasicLit{
				Kind:  token.STRING,
				Value: value,
			    },
			},
		    },
		},
	   },
	)
	exist[value] = true
	file.Decls = append(file.Decls, after...)
    }
}

func removeExtraSymInConst(str string) string {
    if (!unicode.IsLetter(rune(str[len(str) - 1]))) {
	return str[:len(str) - 1]
    }
    return str
}

func replaceStringLitWithConst(file *ast.File, exist map[string]bool) {
    ast.Inspect(file, func(n ast.Node) bool {
	for _, x := range file.Decls {
	    if genDecl, ok := x.(*ast.GenDecl); ok {
		if genDecl.Tok == token.VAR {
		    for _, spec := range genDecl.Specs {
			valueSpec := spec.(*ast.ValueSpec)
			if valueSpec.Type.(*ast.Ident).Name == "string" {
			    for i := range valueSpec.Values {
			        if _, err := valueSpec.Values[i].(*ast.BasicLit); err {
				    rightVal := valueSpec.Values[i].(*ast.BasicLit)
				    if rightVal.Kind == token.STRING {
					ll := len(rightVal.Value)
					cst := strings.ToLower(removeExtraSymInConst(rightVal.Value[1:ll-1]))
					insertStringConst(file, cst, rightVal.Value, exist)
					changeValue := []ast.Expr{
				            &ast.BasicLit{
						ValuePos: rightVal.ValuePos,
						Kind:     token.IDENT,
						Value:    cst,
					    },
					}
					valueSpec.Values = changeValue
				    }
				}
			    }
			}
		    }
		}
	    }
			
	    if funcDecl, ok := x.(*ast.FuncDecl); ok {
		body := funcDecl.Body
		for _, bodyList := range body.List {
		    if exprStmt, err := bodyList.(*ast.ExprStmt); err {
			for i := range exprStmt.X.(*ast.CallExpr).Args {
			    if _, err := exprStmt.X.(*ast.CallExpr).Args[i].(*ast.BasicLit); err {
				argsVal := exprStmt.X.(*ast.CallExpr).Args[i].(*ast.BasicLit)
				if argsVal.Kind == token.STRING {
				    ll := len(argsVal.Value)
				    cst := strings.ToLower(removeExtraSymInConst(argsVal.Value[1:ll-1]))
				    insertStringConst(file, cst, argsVal.Value, exist)
				    changeValue := []ast.Expr{
					&ast.BasicLit{
					    ValuePos: argsVal.ValuePos,
					    Kind:     token.IDENT,
					    Value:    cst,
					},
				    }
				    exprStmt.X.(*ast.CallExpr).Args = changeValue	
				}
			    }
			}
		    }
		    if declSt, err := bodyList.(*ast.DeclStmt); err {
			declStmt := declSt.Decl.(*ast.GenDecl)
			for _, spec := range declStmt.Specs {
			    valueSpec := spec.(*ast.ValueSpec)
			    for i := range valueSpec.Values {
				if _, err := valueSpec.Values[i].(*ast.BasicLit); err {
				    rightVal := valueSpec.Values[i].(*ast.BasicLit)
				    if rightVal.Kind == token.STRING {
					ll := len(rightVal.Value)
					cst := strings.ToLower(removeExtraSymInConst(rightVal.Value[1:ll-1]))
					insertStringConst(file, cst, rightVal.Value, exist)
					changeValue := []ast.Expr{
					    &ast.BasicLit{
						ValuePos: rightVal.ValuePos,
						Kind:     token.IDENT,
						Value:    cst,
					    },
					}
				        valueSpec.Values = changeValue
				    }
				}
			    }
			}
		    }
		}
	    }
	}	
	return true
    })
}

func main() {
    exist := make(map[string]bool)

    if len(os.Args) != 2 {
	return
    }

    fset := token.NewFileSet()
    if file, err := parser.ParseFile(fset, os.Args[1], nil, parser.ParseComments); err == nil {
		
	replaceStringLitWithConst(file, exist)

	if format.Node(os.Stdout, fset, file) != nil {
	    fmt.Printf("Formatter error: %v\n", err)
	}
    } else {
	fmt.Printf("Errors in %s\n", os.Args[1])
    }
}
```

# Тестирование

Результат трансформации демонстрационной программы:

```go
package main

import "fmt"

const goodbye string = "Goodbye!"
const world string = "World!"
const hello string = "Hello,"
const tt string = "tt"

var s string = tt

func main() {
    fmt.Println(s)
    fmt.Println(hello)
    fmt.Println(world)

    var x string = goodbye
    fmt.Println(x)
}
```

# Вывод
В ходе данной лабораторной работы было изучено представление синтаксических деревьев в памяти компилятора. 
Также были приобретены навыки преобразования синтаксических деревьев. В 
процессе работы была реализована 
программа, осуществляющая необходимое преобразование синтаксического дерева 
и порождение по нему новой программы.
