% Лабораторная работа № 2.4 «Множества FIRST для РБНФ»
% 25 апреля 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является изучение алгоритма построения множеств FIRST для расширенной формы Бэкуса-Наура.

# Индивидуальный вариант
```
<E    <T {<
            <+>
            <->
          > T}>>
<T    <F {< 
            <*> 
            </>
          > F}>>
<F    <n>
      <- F>
      <( E )>>
```

# Реализация

## Неформальное описание синтаксиса входного языка
В качестве входного языка выступает язык представления правил грамматики, 
лексика и синтаксис которого восстанавливаются из примера в индивидуальном варианте.
Грамматика представляет собой последовательность определений (правил).  
`S    ::= Rule {Rule} | ε `  
Отметим, что каждое определение грамматики заключено в угловых скобках и выражает собой  правило 
переписывания нетерминала. То есть оно выглядит как нетерминальный символ, за которым следует правая
часть правила в виде перечисления альтернатив
Таким образом, имеем:  
`Rule ::= OPEN NTERM Alt {Alt} CLOSE`  
где OPEN и CLOSE - угловые скобк, Alt - альтернатива правой части правила 
(во что может переписываться нетерминал, альтернатив может быть несколько).
Альтернатива представляет собой выражение, заключенное в угловых скобках:  
`Alt  ::= OPEN Body CLOSE | ε `  
Выражение из альтернативы может содержать:
- нетерминалы,  
`Body ::= NTERM {Body}`
- терминалы,  
`Body ::= TERM {Body}`
- выражения в фигурных скобках,  
`Body ::= STAROPEN Body STARCLOSE {Body}`
- выражения в угловых скобках, внутри которых содержатся выражения в угловых скобках (как альтернативы).  
`Body ::= OPEN Ins CLOSE {Body}`   
`Inst  ::= OPEN Body CLOSE {Inst} | ε `

Таким образом,  
`Body ::= NTERM {Body} | TERM {Body}| OPEN Inst CLOSE {Body} | STAROPEN Body STARCLOSE {Body} | ε `  
`Inst  ::= OPEN Body CLOSE {Ins} | ε `

Токены следующие:
- Терминал (имя с маленькой буквы или знак арифметической операции или круглые скобки);
- Нетерминал (имя с заглавной буквы);
- Открывающие и закрывающие фигурные скобки;
- Открывающие и закрывающие угловые скобки.

## Лексическая структура
StartBrace ::= '<'  
EndBrace   ::= '>'  
STAROPEN   ::= '{'  
STARCLOSE  ::= '}'  
TERM       ::= 'a' | 'b' | ... | 'z' | '+' | '*' | '-' | '/' | '(' | ')'  
NTERM      ::= 'A' | 'B' | ... | 'Z'  

## Грамматика языка
S    ::= Rule {Rule} | $\varepsilon$  
Rule ::= OPEN NTERM Alt {Alt} CLOSE  
Alt  ::= OPEN Body CLOSE {OPEN Body CLOSE} | $\varepsilon$  
Body ::= NTERM {Body} | TERM {Body}| OPEN Inst CLOSE {Body} | STAROPEN Body STARCLOSE {Body} | $\varepsilon$  
Inst  ::= OPEN Body CLOSE {Inst} | $\varepsilon$  


### Пример разбора правила по грамматике
Рассмотрим правило из индивидуального варианта
`<E    <T {<
            <+>
            <->
          > T}>>`
          
```
Rule -> OPEN  NTERM Alt {Alt} CLOSE
<E <T {<<+><->> T}>>    -->	  '<'  'E'  Alt  '>'

Alt -> OPEN Body CLOSE {OPEN Body CLOSE} | eps
<T {<<+><->> T}>    -->	   '<'  Body  '>'

Body -> NTERM {Body}
T {< <+> <-> > T}   -->	   'T'  Body 
	 
Body -> STAROPEN Body STARCLOSE {Body}
{< <+> <-> > T}     -->	   '{'  Body  '}'

Body -> OPEN Inst CLOSE {Body} 
< <+> <-> > T       -->	   '<'  Inst  '>'  Body

Inst -> OPEN Body CLOSE {Inst}                       Body -> NTERM {Body}
<+> <->    -->	  '<'  Body  '>'  Inst               T     -->  'T'

Body -> TERM {Body}     Inst -> OPEN Body CLOSE {I}
+    -->   '+'          <->   -->   '<'  Body  '>'

                        Body -> TERM {Body}
                        -      -->   '-'
```

## Программная реализация

Класс Main
```kotlin
import java.io.File

fun main() {
    val file = File("test1.txt")
    val lexer = Lexer(file.readText())
    val tokens = mutableListOf<Token>()
    do {
        val token = lexer.nextToken()
        tokens += token
    } while (token.tag != DomainTag.EOP)
    println("tokens:")
    tokens.forEach{
        println(it)
    }
    println()
    val parser = Parser(tokens)
    parser.parse()
    val rules = parser.rules
    val first = First(rules)
    first.print()
}
```

Класс DomainTag
```kotlin
enum class DomainTag {
    NTERM,
    TERM,
    OPEN,
    CLOSE,
    STAROPEN,
    STARCLOSE,
    UNKNOWN,
    EOP
}
```

Класс Lexer
```kotlin
import kotlin.system.exitProcess

class Lexer(program: String) {
    private var position = Position(program)

    fun nextToken(): Token {
        while (!position.isEOF()) {
            while (position.isWhiteSpace())
                position = position.next()

            if (position.isEOF())
                break

            val token = when (position.getCode().toChar()) {
                '<', '>', '{', '}'                          -> getOpenOrCloseToken(position)
                in 'a'..'z',  '*', '/', '+', '-', '(', ')'  -> getTerm(position)
                in 'A'..'Z'                                 -> getNTerm(position)
                else                                        -> getError(position)
            }
            position = token.coords.following

            return token
        }
        return Token(DomainTag.EOP, Fragment(position, position), "")
    }

    private fun getTerm(position: Position): Token {
        return Token(DomainTag.TERM, Fragment(position, position.next()), 
            position.getCurrentSymbol().toString())
    }

    private fun getNTerm(position: Position): Token {
        return Token(DomainTag.NTERM, Fragment(position, position.next()),
            position.getCurrentSymbol().toString())
    }

    private fun getOpenOrCloseToken(position: Position): Token {
        val tag = when (position.getCurrentSymbol()) {
            '<' -> DomainTag.OPEN
            '>' -> DomainTag.CLOSE
            '{' -> DomainTag.STAROPEN
            '}' -> DomainTag.STARCLOSE
            else -> DomainTag.UNKNOWN
        }
        return Token(tag, Fragment(position, position.next()), 
            position.getCurrentSymbol().toString())
    }

    private fun getError(position: Position): Token  {
        println("ERROR ${Fragment(position, position)}: unknown token")
        exitProcess(0)
    }
}
```

Класс Parser
```kotlin
import kotlin.system.exitProcess

class Parser(private val tokens: List<Token>) {
    private var leftNTerms = HashSet<String>()
    private var rightNTerms = HashSet<String>()
    var rules = HashMap<String, Rule>()
    private var curState = ""
    private var states = mutableListOf<String>()
    private var curToken = tokens.first()

    private fun nextToken() {
        val index = tokens.indexOf(curToken)
        curToken = tokens[index + 1]
    }

    fun parse() {
        parseS()
        if (!leftNTerms.containsAll(rightNTerms)) {
            print("undetermined nonterminals: $rightNTerms - $leftNTerms")
            exit()
        }
    }

    // S ::= Rule {Rule} | eps
    private fun parseS() {
        states.add("S")
        while (curToken.tag == DomainTag.OPEN) {
            parseRule()
        }
        if (curToken.tag != DomainTag.EOP) exit()
    }

    // Rule ::= OPEN NTERM Alt {Alt} CLOSE
    private fun parseRule() {
        states.add("Rule")

        if (curToken.tag != DomainTag.OPEN) exit()
        nextToken()

        if (curToken.tag != DomainTag.NTERM) exit()

        val left = curToken
        val rule = Rule(RuleTag.Token, null)
        leftNTerms.add(left.value)
        nextToken()
        parseAlt(rule)
        while (curToken.tag == DomainTag.OPEN) {
            rule.addAlternatives()
            parseAlt(rule)
        }
        rules[left.value] = rule
        if (curToken.tag != DomainTag.CLOSE) exit()
        nextToken()
    }

    // Alt ::= OPEN Body CLOSE {OPEN Body CLOSE} | eps
    private fun parseAlt(rule: Rule) {
        curState = "Alt"
        states.add(curState)

        if (curToken.tag != DomainTag.OPEN) exit()
        nextToken()

        val newRule = Rule(RuleTag.Bracket, null)
        newRule.addAlternatives()
        if (curToken.tag == DomainTag.STAROPEN){
            newRule.tag = RuleTag.Star
        }
        parseBody(newRule, false)

        if (curToken.tag != DomainTag.CLOSE) exit()
        nextToken()
        rule.addAlternatives()
        rule.addRule(newRule)

        while (curToken.tag == DomainTag.OPEN) {
            nextToken()
            val newRule = Rule(RuleTag.Bracket, null)
            if (curToken.tag == DomainTag.STAROPEN){
                newRule.tag = RuleTag.Star
            }
            newRule.addAlternatives()
            parseBody(newRule, false)
            if (curToken.tag != DomainTag.CLOSE) exit()
            nextToken()
            rule.addAlternatives()
            rule.addRule(newRule)
        }
    }

    // Body ::= NTERM {Body} | TERM {Body}| OPEN Inst CLOSE {Body} | STAROPEN Body STARCLOSE {Body} | eps
    private fun parseBody(rule: Rule, star: Boolean) {
        curState = "Body"
        states.add(curState)

        when (curToken.tag) {
            DomainTag.NTERM, DomainTag.TERM -> {
                val token = curToken
                if (curToken.tag == DomainTag.NTERM) {
                    rightNTerms.add(token.value)
                }
                rule.addRule(Rule(RuleTag.Token, token))
                nextToken()
                parseBody(rule, false)
            }
            DomainTag.OPEN -> {
                nextToken()
                parseInst(rule, star)
                if (curToken.tag != DomainTag.CLOSE) exit()
                nextToken()
                parseBody(rule, false)
            }
            DomainTag.STAROPEN -> {
                nextToken()
                val iRule = Rule(RuleTag.Star, null)
                iRule.addAlternatives()
                parseBody(iRule, true)
                if (curToken.tag != DomainTag.STARCLOSE) exit()
                nextToken()
                rule.addRule(iRule)
                parseBody(rule, false)
            }
            DomainTag.EOP -> return
            else -> {}
        }
    }

    // Inst  ::= OPEN Body CLOSE {Inst} | eps
    private fun parseInst(rule: Rule, star: Boolean) {
        curState = "Inst"
        states.add(curState)

        when (curToken.tag) {
            DomainTag.EOP -> return
            DomainTag.OPEN -> {
                nextToken()
                rule.addAlternatives()
                parseBody(rule, star)
                if (curToken.tag != DomainTag.CLOSE) exit()
                nextToken()
                parseInst(rule, star)
            }
            DomainTag.TERM, DomainTag.NTERM -> {
                nextToken()
                parseBody(rule, star)
            }

            else -> {}
        }
    }

    private fun exit() {
        println("ERROR")
        println("On token: $curToken")
        println("current rule: $curState")
        println("passed rules: $states")
        exitProcess(0)
    }
}
```

Класс Token
```kotlin
class Token(val tag: DomainTag, val coords: Fragment, val value: String) {

    override fun toString(): String = "$tag $coords: $value"
}
```

Классы RuleTag, Rule
```kotlin
enum class RuleTag {
    Token,
    TokenStar,
    Bracket,
    Star,
}

class Rule(var tag: RuleTag, val token: Token?) {
    var alternatives = ArrayList<ArrayList<Rule>>()
    var elems = ArrayList<Rule>()

    fun addRule(rule: Rule) {
        elems.add(rule)
    }

    fun addAlternatives() {
        elems = ArrayList<Rule>()
        alternatives.add(elems)
    }

    override fun toString(): String {
        val (start, end) = when (tag) {
            RuleTag.Bracket     -> "<" to ">"
            RuleTag.Token       -> ""  to ""
            RuleTag.TokenStar   -> ""  to ""
            RuleTag.Star        -> "{"  to "}"
        }

        var result = start

        if (token != null) {
            result = result.plus(token.value)
        }
        alternatives.forEach {
            it.forEach {
                result = result.plus(it.toString() + " ")
            }
        }
        return result.removeSuffix(" ") + end
    }
}
```

Класс First
```kotlin
class First(val rules: HashMap<String, Rule>) {
    var first = HashMap<String, HashSet<String>>()

    fun f(rule: Rule): HashSet<String> {
        var altSet: HashSet<String>?
        val set = HashSet<String>()
        for (ruleList in rule.alternatives) {
            altSet = HashSet<String>()
            var hashSet: HashSet<String>? = HashSet<String>()
            altSet.add("ε")
            for (item in ruleList) {
                if (!altSet.contains("ε"))
                    break
                if (item.token?.tag == DomainTag.NTERM && item.tag == RuleTag.Token)
                    hashSet = first[item.token.value]?.clone() as HashSet<String>
                else if (item.token?.tag == DomainTag.NTERM && item.tag == RuleTag.TokenStar) {
                    hashSet = first[item.token.value]?.clone() as HashSet<String>
                    hashSet.add("ε")
                }
                else if (item.token?.tag == DomainTag.TERM && item.tag == RuleTag.Token) {
                    hashSet?.clear()
                    hashSet?.add(item.token.value)
                } else if (item.token?.tag == DomainTag.TERM && item.tag == RuleTag.TokenStar) {
                    hashSet?.clear()
                    hashSet?.add(item.token.value)
                    hashSet?.add("ε")
                }
                else if (item.tag == RuleTag.Bracket)
                    hashSet = f(item)
                else if (item.tag == RuleTag.Star) {
                    hashSet = f(item)
                    hashSet?.add("ε")
                }
                altSet.remove("ε")
                hashSet?.forEach { altSet?.add(it) }
            }
            altSet.forEach { set.add(it) }
        }
        return set
    }

    fun setFirst() {
        rules.forEach { key, _ -> first.put(key, HashSet<String>()) }
        var isChanged = true
        var hs: HashSet<String>? = null
        while (isChanged) {
            isChanged = false
            rules.forEach { key, value ->
                hs = HashSet<String>()
                hs = f(value)
                val len = first[key]?.size
                first[key] = hs?.clone() as HashSet<String>
                if (len != first[key]?.size)
                    isChanged = true
            }
        }
    }

    fun print() {
        setFirst()
        first.forEach { (key, value) ->
            print("FIRST($key): {  ")
            var s = ""
            value.forEach {
                s = s.plus("$it, ")
            }
            print(s.removeSuffix(", "))
            print("  }\n")
        }
    }
}
```

Классы Position, Fragment
```kotlin
class Position {
    private var text: String? = null
    private var line = 1
    private var pos = 1
    private var index = 0

    constructor(text: String) {
        this.text = text
    }

    constructor(p: Position) {
        this.text = p.text
        this.line = p.line
        this.pos = p.pos
        this.index = p.index
    }

    fun isEOF(): Boolean = index == text?.length

    fun getCode(): Int = if (isEOF()) -1 else text?.codePointAt(index) as Int

    fun isWhiteSpace(): Boolean = !isEOF() && Character.isWhitespace(getCode())

    fun getCurrentSymbol(): Char? = text?.get(index)

    override fun toString(): String = "($line, $pos)"
    
    fun isNewLine(): Boolean {
        if (isEOF())
            return true
        if (text?.get(index) ==  '\r' && index + 1 < text?.length as Int) {
            return text?.get(index + 1) == '\n'
        }
        return text?.get(index) == '\n'
    }

    fun next(): Position {
        val pos = Position(this)
        if (!pos.isEOF()) {
            if (pos.isNewLine()) {
                if (pos.text?.get(pos.index) == '\r')
                    pos.index++
                pos.line++
                pos.pos = 1
            } else {
                if (Character.isHighSurrogate(pos.text?.get(pos.index) as Char))
                    pos.index++
                pos.pos++
            }
            pos.index++
        }
        return pos
    }
}

data class Fragment(val starting: Position, val following: Position) {
    override fun toString(): String = "$starting - $following"
}
```

# Тестирование

Входные данные

```
<A  < x (B)> >
<B <y> <u>>
<F <n>
     <- F>
       <( E ) > >

<E
<z>>
```

Вывод на `stdout`

```
FIRST(A): {  x  }
FIRST(B): {  u, y  }
FIRST(E): {  z  }
FIRST(F): {  (, -, n  }
```

# Вывод
В ходе данной лабораторной работы был изучен алгоритм построения множеств FIRST для расширенной 
формы Бэкуса-Наура. Разработанная программа принимает на вход текст на входном языке в 
соответствии с индивидуальным вариантом, а на выходе порождает множества FIRST для каждого правила 
грамматики входного текста.
