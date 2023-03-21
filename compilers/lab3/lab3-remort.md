% Лабораторная работа № 1.2. «Лексический анализатор
  на основе регулярных выражений»
% 14 марта 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является приобретение навыка разработки простейших лексических анализаторов, работающих 
на основе поиска в тексте по образцу, заданному регулярным выражением.

# Индивидуальный вариант
Регулярные выражения: ограничены знаками «/», не могут пересекать границы текста, 
содержат escape-последовательности "\n", "\/", "\\". Строковые литералы: ограничены тремя кавычками («"""»), могут 
занимать несколько строчек текста, не могут содержать внутри более двух 
кавычек подряд.

# Реализация

```go
package main

import (
	"bufio"
	"errors"
	"fmt"
	"log"
	"os"
	"regexp"
)

var strRegexp *regexp.Regexp = regexp.MustCompile(`"""([^"]"|[^"]""|[^"]|\r\n|\n|\r)*"""`)
var strStartRegexp *regexp.Regexp = regexp.MustCompile(`^"""([^"]"|[^"]""|[^"]|\r\n|\n|\r)*`)
var strEndRegexp *regexp.Regexp = regexp.MustCompile(`([^"]"|[^"]""|[^"]|\r\n|\n|\r)*"""$`)
var regRegexp *regexp.Regexp = regexp.MustCompile(`^/(.|\n|\/|\\)*/`)


var shiftRem, lineRem =  0, 0
var startRem, middleStr string

type Token struct {
	Tag  string
	Line  []int
	Shift int
	Value string
}

type Lexer interface {
	NextToken() (Token, error)
	HasNext() bool
}

type litLexer struct {
	text  []string
	pos   int
	shift int
}

func NewLexer(text []string) Lexer {
	var l Lexer = &litLexer{
		text: text,
		pos: 0,
		shift: 0,
	}
	return l
}

func (l litLexer) HasNext() bool {
	for l.pos < len(l.text) && l.text[l.pos] == "" {
		l.pos += 1
	}
	return l.pos < len(l.text)
}

func (l *litLexer) NextToken() (tok Token, err error) {
	if l.text[l.pos] == "" {
		l.pos += 1
		l.shift = 0
	}
	if l.pos >= len(l.text) {
		return Token{}, errors.New("ERROR")
	}

	line := l.text[l.pos]

	for line[0] == ' ' || line[0] == '\t'{
		line = line[1:]
		l.shift += 1
	}

	strStart := strStartRegexp.FindStringIndex(line)
	strEnd := strEndRegexp.FindStringIndex(line)
	strPos := strRegexp.FindStringIndex(line)
	regPos := regRegexp.FindStringIndex(line)

	if strStart == nil && regPos == nil && len(startRem) == 0 {
		tok := Token{
			Tag:  "err",
			Line:  []int{l.pos},
			Shift: l.shift,
		}
		for len(line) > 0 && line[0] != ' ' {
			line = line[1:]
			l.shift += 1
			l.text[l.pos] = line
		}
		return tok, nil
	}

	if regPos == nil {
		if strPos != nil {
			tok := Token{
				Tag:  "String",
				Line:  []int{l.pos},
				Shift: l.shift,
				Value: line[strPos[0]:strPos[1]],
			}
			l.shift += len(line[strPos[0]:strPos[1]])
			l.text[l.pos] = line[strPos[1]:]
			return tok, nil
		}
		if strStart != nil && strEnd == nil {
			startRem = line[strStart[0]:strStart[1]]
			shiftRem = l.shift
			lineRem = l.pos	
			l.shift += len(line[strStart[0]:strStart[1]])
			l.text[l.pos] = line[strStart[1]:]
			return Token{Tag: "c", Line: nil,	Shift: 0, Value: "",}, nil
		}
		if strStart == nil && strEnd != nil {
			tok := Token{
				Tag:  "String",
				Line:  []int{lineRem, l.pos},
				Shift: shiftRem,
				Value: startRem + middleStr + line[strEnd[0]:strEnd[1]],
			}
			l.shift += len(startRem + middleStr + line[strEnd[0]:strEnd[1]])
			l.text[l.pos] = line[strEnd[1]:]
			return tok, nil
		}
		if strStart == nil && strEnd == nil {
			middleStr += line
			l.shift += len(line)
			l.text[l.pos] = line[len(line):]
			return Token{Tag: "c", Line: nil,	Shift: 0, Value: "",}, nil
		}
	}

	if strStart == nil {
		tok := Token{
			Tag:  "RegExp",
			Line:  []int{l.pos},
			Shift: l.shift,
			Value: line[regPos[0]:regPos[1]],
		}
		l.shift += len(line[regPos[0]:regPos[1]])
		l.text[l.pos] = line[regPos[1]:]
		return tok, nil
	}

	return Token{}, errors.New("ERROR")
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("ERROR - usage must be: go run main.go <fileTag.txt>\n")
	}
	filePath := os.Args[1]

	file, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err.Error())
	}
	defer file.Close()

	// input reading
	var text []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		text = append(text, scanner.Text())
	}
	if scanner.Err() != nil {
		log.Fatal(scanner.Err().Error())
	}
	
	if len(text) == 0 {
		err = errors.New("ERROR - empty text")
		log.Fatal(err.Error())
	}
	
	// lexical analysis
	lexer := NewLexer(text)
	for lexer.HasNext() {
		tok, err := lexer.NextToken()
		if err != nil {
			log.Fatal(err.Error())
		}
		if tok.Tag == "c" {
			continue
		}
		if tok.Tag != "err" {
			fmt.Printf("%s (%d, %d): %s\n", tok.Tag, tok.Line, tok.Shift, tok.Value)
		} else {
			fmt.Printf("syntax error (%d, %d)\n", tok.Line, tok.Shift)
		}
		
	}
}
```

# Тестирование

Входные данные

```
hello """world"""
/[ab]\n/ """3"4"""
z """abc
d
e"""
/av*\/abc/
```

Вывод на `stdout` 

```
syntax error ([0], 0)
String ([0], 6): """world"""
RegExp ([1], 0): /[ab]\n/
String ([1], 9): """3"4"""
syntax error ([2], 0)
String ([2 4], 2): """abcde"""
RegExp ([5], 0): /av*\/abc/
```

# Вывод
В ходе данной лабораторной работы было получен навык разработки простейшего лексического анализатора, 
работающего на основе поиска в тексте по образцу, заданному регулярным выражением. Также в  соответствии с 
индивидуальным вариантом были написаны регулярные выражения, отвечающие 
заданным условиям. 
Необходимые первые фазы стадии анализа (чтение входного потока и лексических анализ) были реализованы на Go.
