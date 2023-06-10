% Лабораторная работа № 2.2 «Абстрактные синтаксические деревья»
% 3 мая 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является получение навыков составления грамматик и проектирования синтаксических деревьев.

# Индивидуальный вариант
Подмножество Оберона
```
TYPE  
  Point = RECORD  
    x, y : REAL;  
  END;  
  Shape = RECORD
    center : Point;
    color : INTEGER;
    next : POINTER TO Shape;
  END;
  Circle = RECORD(Shape)
    radius : REAL;
  END;
  Rectangle = RECORD(Shape)
    width, height : REAL;
  END;

VAR
  p1, p2 : Point;
  s : Shape;
  c : Circle;
  r : Rectangle;
  ps : POINTER TO Shape;
  pc : POINTER TO Circle;
  pr : POINTER TO Rectangle;
BEGIN
  p1.x := 10;
  p1.y := 3.5;
  s.center := p1;
  s.color := 100500;
  c := s;
  c.radius := 7;
  r.center.x := 5.2;
  r.center.y := 2.5;
  r.color := 500100;
  r.width := 4.5;
  r.heigh := 5.4;
  c := r;
  NEW(pr);
  pr^ := r;
  ps := pr;
  NEW(pc);
  pc^ := c;
  ps.next := pc;

  (* комментарий *)
  WHILE p1.x * p1.y < 77777 DO
    p1.x := p1.x * 1.5;
    p1.y := p1.y * 2.5;
  END;

  IF p1.x > pc.radius THEN
    p2 := p1;
    p1 := pc.center;
  ELSE
    p2 := pr.center;
  END;
END.
```
Комментарии записываются как (* … *). Идентификаторы учитывают регистр, ключевые слова 
всегда пишутся большими буквами.

Приоритет операций:
- Наивысший приоритет имеют обращения к полям.
- NOT  
- *, /, AND, DIV, MOD  
- +, -, OR  
- <, >, <=, >=, #, = — неассоциативны.  

# Реализация

## Абстрактный синтаксис  
Сформулируем абстрактный синтаксис.

Программа начинается с объявления типов, затем идет объявление переменных, за 
которым располагается последовательность операторов:
```
Program → TYPE TypeDefs VAR VarDefs BEGIN Statements END .
```
Объявления типов — это ноль и более объявлений:
```
TypeDefs → TypeDef*
```
Объявление типа состоит из имени, знака равно, ключевого слова RECORD, 
СуперТипа, тела с объявлением переменных и ключевого слова END и точки с запятой:
```
TypeDef → VARNAME = RECORD SuperType VarDefs END;
```
СуперТип заключен в круглые скобки, если он есть
```
SuperType → ( VARNAME ) | ε
```
Объявления переменных — ноль и более объявлений переменных:
```
VarDefs → VarDef*
```
Объявление переменной состоит из имен переменных данного типа и самого типа, после знака двоеточия:
```
VarDef → Vars : Type ;
```
Имен переменных одного типа может быть несколько через запятую, а может быть одно:
```
Vars → VARNAME  
Vars → VARNAME , Vars | ε
```
Тип — целый, вещественный, логический, СуперТип, указатель на тип:
```
Type → INTEGER | REAL | BOOLEAN | VARNAME | POINTER TO Type
```
Последовательность операторов — ноль или более операторов, разделённых точкой с запятой:
```
Statements → Statement ; … ; Statement | ε
```
Оператор — присваивание, создание нового указателя, ветвление, цикл с предусловием, цикл со счётчиком, последовательность операторов в операторных скобках begin … end и пустой оператор, который ничего не делает:

```
Statement → Var := Expr
	      | NEW ( VARNAME )
          | IF Expr THEN Statements ELSE Statements
          | WHILE Expr DO Statement
          | FOR Var := Expr TO Expr DO Statement
          | BEGIN Statements END
          | ε
```
Присваивание может быть для переменной, для поля переменной пользовательского типа, для  разыменованного указателя (Var^): 
```
Var → Var ^ | Var.VARNAME | VARNAME
```
Выражение — переменная, константа, двуместная операция, одноместная операция:
```
Expr → VARNAME
     | Const
     | Expr BinOp Expr
     | UnOp Expr
```
```
Const → INT_CONST | REAL_CONST | TRUE | FALSE
BinOp → + | - | * | / | ** | AND | OR | > | < | >= | <= | = | <> | DIV | MOD
UnOp → + | - | NOT
```

## Лексическая структура и конкретный синтаксис

Перейдём к конкретной грамматике:
```
Program → TYPE TypeDefs VAR VarDefs BEGIN Statements END.
TypeDefs →  ε | TypeDefs TypeDef
TypeDef → VARNAME = RECORD SuperType VarDefs END;
SuperType → ( VARNAME ) | ε
VarDefs → ε | VarDefs VarDef
VarDef → Vars : Type ;
Vars → VARNAME | VARNAME , Vars | ε
Type → INTEGER | REAL | BOOLEAN | VARNAME | POINTER TO Type

Statements → Statement | Statements ; Statement

Statement → Var := Expr
	      | NEW ( VARNAME )
          | IF Expr THEN Statements ELSE Statements END
          | WHILE Expr DO Statement END
          | FOR Var := Expr TO Expr DO Statement END
          | ε

Expr → ArithmExpr
     | ArithmExpr CmpOp ArithmExpr

CmpOp → > | < | >= | <= | = | <>

ArithmExpr → Term | + Term | - Term | ArithmExpr AddOp Term
AddOp → + | - | OR

Term → Factor | Term MulOp Factor
MulOp → * | / | DIV | MUL | AND

Factor → NOT Factor | Var | Const | ( Expr )

Var → Var ^ | Var.VARNAME | VARNAME

Const → INT_CONST | REAL_CONST | TRUE | FALSE
```
Лексическая струтктура:
```
VARNAME = [A-Za-z][A-Za-z0-9]*
INT_CONST  = [0-9]+
REAL_CONST = [0-9]+(\\.[0-9]*)?(e[-+]?[0-9]+)?
```
## Программная реализация

```python
import abc
import enum
import parser_edsl.parser_edsl as pe
import sys
import typing
from dataclasses import dataclass
from pprint import pprint
from typing import Any


class Type(abc.ABC):
    pass


class BasicType(enum.Enum):
    Integer = 'INTEGER'
    Real = 'REAL'
    Boolean = 'BOOLEAN'


@dataclass
class PointerType(Type):
    pointerTo : Type or BasicType


@dataclass
class UserType(Type):
    name: str

@dataclass
class EmptyAncestorType(Type):
    pass

@dataclass
class VarsDef:
    names : list[str]
    type : Type or BasicType


@dataclass
class TypeDef:
    name : str
    ancestorType : Type
    varsDefs: VarsDef


class Statement(abc.ABC):
    pass


@dataclass
class Program:
    type_defs: list[TypeDef]
    var_defs : list[VarsDef]
    statements : list[Statement]


class Expr(abc.ABC):
    pass


@dataclass
class DerefenceExpr(Expr):
    var : Any 


@dataclass
class AssignStatement(Statement):
    variable : Any 
    expr : Expr


@dataclass
class NewStatement(Statement):
    variable: Any 


@dataclass
class IfStatement(Statement):
    condition : Expr
    then_branch : Statement
    else_branch : Statement


@dataclass
class WhileStatement(Statement):
    condition : Expr
    body : Statement


@dataclass
class ForStatement(Statement):
    variable : Any 
    start : Expr
    end : Expr
    body : Statement


@dataclass
class EmptyStatement(Statement):
    pass


@dataclass
class SingleVar(Expr):
    varname : str


@dataclass
class VarWithFields(Expr):
    var: list[str]


@dataclass
class ConstExpr(Expr):
    value : typing.Any
    type : Type or BasicType


@dataclass
class BinOpExpr(Expr):
    left : Expr
    op : str
    right : Expr


@dataclass
class UnOpExpr(Expr):
    op : str
    expr : Expr

# лексическая структура
INTEGER = pe.Terminal('INTEGER', '[0-9]+', int, priority=7)
REAL = pe.Terminal('REAL', '[0-9]+(\\.[0-9]*)?(e[-+]?[0-9]+)?', float)
VARNAME = pe.Terminal('VARNAME', '[A-Za-z][A-Za-z0-9]*', str)

def make_keyword(image):
    return pe.Terminal(image, image, lambda name: None, priority=10)

KW_TYPE, KW_NEW, KW_VAR, KW_BEGIN, KW_END, KW_INTEGER, KW_REAL, KW_BOOLEAN = \
    map(make_keyword, 'TYPE NEW VAR BEGIN END INTEGER REAL BOOLEAN'.split())

KW_IF, KW_THEN, KW_ELSE, KW_WHILE, KW_DO, KW_FOR, KW_TO, KW_RECORD, KW_POINTER = \
    map(make_keyword, 'IF THEN ELSE WHILE DO FOR TO RECORD POINTER'.split())

KW_OR, KW_DIV, KW_MOD, KW_AND, KW_NOT, KW_TRUE, KW_FALSE = \
    map(make_keyword, 'OR DIV MOD AND NOT TRUE FALSE'.split())


NProgram, NTypeDefs, NTypeDef, NAncestorType, NVarsDefs, NVarsDef, NVars, NType, NStatements = \
    map(pe.NonTerminal, 'Program TypeDefs TypeDef AncestorType VarsDefs VarsDef Vars Type Statements'.split())

NStatement, NExpr, NCmpOp, NArithmExpr, NAddOp = \
    map(pe.NonTerminal, 'Statement Expr CmpOp ArithmOp AddOp'.split())

NTerm, NMulOp, NFactor, NVar, NSingleVar, NVarWithFields, NConst = \
    map(pe.NonTerminal, 'Term MulOp Factor Var SingleVar VarWithFields Const'.split())



# грамматика
NProgram |= KW_TYPE, NTypeDefs, KW_VAR, NVarsDefs, KW_BEGIN, NStatements, KW_END, '.', Program

NTypeDefs |= lambda: []
NTypeDefs |= NTypeDefs, NTypeDef, lambda tds, td: tds + [td]
NTypeDef |= VARNAME, '=', KW_RECORD, NAncestorType, NVarsDefs, KW_END, ';', \
    lambda varname, ancestorType, varsDefs: TypeDef(varname, ancestorType, varsDefs)
NAncestorType |= '(', VARNAME, ')', UserType
NAncestorType |= EmptyAncestorType

NVarsDefs |= lambda: []
NVarsDefs |= NVarsDefs, NVarsDef, lambda vds, vd: vds + [vd]
NVarsDef |= NVars, ':', NType, ';', VarsDef

NVars |= VARNAME, lambda v: [v]
NVars |= VARNAME, ',', NVars, lambda v, vs: [v] + vs

NType |= KW_INTEGER, lambda: BasicType.Integer
NType |= KW_REAL, lambda: BasicType.Real
NType |= KW_BOOLEAN, lambda: BasicType.Boolean
NType |= VARNAME, UserType
NType |= KW_POINTER, KW_TO, NType, lambda type: PointerType(type)

NStatements |= NStatement, lambda st: [st]
NStatements |= NStatements, ';', NStatement, lambda sts, st: sts + [st]

NStatement |= NVar, ':=', NExpr, AssignStatement
NStatement |= KW_NEW, '(', VARNAME, ')', NewStatement 
NStatement |= (
    KW_IF, NExpr, KW_THEN, NStatements, KW_ELSE, NStatements, KW_END, IfStatement
)
NStatement |= KW_WHILE, NExpr, KW_DO, NStatements, KW_END, WhileStatement
NStatement |= (
    KW_FOR, NVar, ':=', NExpr, KW_TO, NExpr, KW_DO, NStatement, KW_END, ForStatement
)
NStatement |= EmptyStatement


NExpr |= NArithmExpr
NExpr |= NArithmExpr, NCmpOp, NArithmExpr, BinOpExpr

def make_op_lambda(op):
    return lambda: op

for op in ('>', '<', '>=', '<=', '=', '<>'):
    NCmpOp |= op, make_op_lambda(op)

NArithmExpr |= NTerm
NArithmExpr |= '+', NTerm, lambda t: UnOpExpr('+', t)
NArithmExpr |= '-', NTerm, lambda t: UnOpExpr('-', t)
NArithmExpr |= NArithmExpr, NAddOp, NTerm, BinOpExpr

NAddOp |= '+', lambda: '+'
NAddOp |= '-', lambda: '-'
NAddOp |= KW_OR, lambda: 'or'

NTerm |= NFactor
NTerm |= NTerm, NMulOp, NFactor, BinOpExpr

NMulOp |= '*', lambda: '*'
NMulOp |= '/', lambda: '/'
NMulOp |= KW_DIV, lambda: 'div'
NMulOp |= KW_MOD, lambda: 'mod'
NMulOp |= KW_AND, lambda: 'and'

NFactor |= KW_NOT, NFactor, lambda p: UnOpExpr('not', p)
NFactor |= NVar
NFactor |= NConst
NFactor |= '(', NExpr, ')'

NVar |= NVar, '^', DerefenceExpr
NVar |= NSingleVar
NVar |= NVarWithFields
NSingleVar |= VARNAME, lambda var: SingleVar(var)
NVarWithFields |= NVar, '.', VARNAME, lambda v, f: VarWithFields([v, f])



NConst |= INTEGER, lambda v: ConstExpr(v, BasicType.Integer)
NConst |= REAL, lambda v: ConstExpr(v, BasicType.Real)
NConst |= KW_TRUE, lambda: ConstExpr(True, BasicType.Boolean)
NConst |= KW_FALSE, lambda: ConstExpr(False, BasicType.Boolean)


parser = pe.Parser(NProgram)
assert parser.is_lalr_one()
# parser.print_table()

# пробельные символы
parser.add_skipped_domain('\s')
# комментарии вида (* … *)
parser.add_skipped_domain('\(\*.*?\*\)')


for filename in sys.argv[1:]:
    try:
        with open(filename) as f:
            tree = parser.parse(f.read())
            pprint(tree)
    except pe.Error as e:
        print(f'Ошибка {e.pos}: {e.message}')
    except Exception as e:
        print(e)
```

# Тестирование

## Входные данные

```
TYPE
  Point = RECORD
    x, y : REAL;
  END;
  Shape = RECORD
    center : Point;
    color : INTEGER;
    next : POINTER TO Shape;
  END;
  Circle = RECORD(Shape)
    radius : REAL;
  END;
  Rectangle = RECORD(Shape)
    width, height : REAL;
  END;

VAR
  p1, p2 : Point;
  s : Shape;
  c : Circle;
  r : Rectangle;
  ps : POINTER TO Shape;
  pc : POINTER TO Circle;
  pr : POINTER TO Rectangle;
BEGIN
  p1.x := 10;
  p1.y := 3.5;
  s.center := p1;
  s.color := 100500;
  c := s;
  c.radius := 7;
  r.center.x := 5.2;
  r.center.y := 2.5;
  r.color := 500100;
  r.width := 4.5;
  r.heigh := 5.4;
  c := r;
  NEW(pr);
  pr^ := r;
  ps := pr;
  NEW(pc);
  pc^ := c;
  ps.next := pc;

  (* комментарий *)
  WHILE p1.x * p1.y < 77777 DO
    p1.x := p1.x * 1.5;
    p1.y := p1.y * 2.5;
  END;

  IF p1.x > pc.radius THEN
    p2 := p1;
    p1 := pc.center;
  ELSE
    p2 := pr.center;
  END;
END.
```

## Вывод на `stdout`

```
﻿Program(type_defs=[TypeDef(name='Point',
                           ancestorType=EmptyAncestorType(),
                           varsDefs=[VarsDef(names=['x', 'y'],
                                             type=<BasicType.Real: 'REAL'>)]),
                   TypeDef(name='Shape',
                           ancestorType=EmptyAncestorType(),
                           varsDefs=[VarsDef(names=['center'],
                                             type=UserType(name='Point')),
                                     VarsDef(names=['color'],
                                             type=<BasicType.Integer: 'INTEGER'>),
                                     VarsDef(names=['next'],
                                             type=PointerType(pointerTo=UserType(name='Shape')))]),
                   TypeDef(name='Circle',
                           ancestorType=UserType(name='Shape'),
                           varsDefs=[VarsDef(names=['radius'],
                                             type=<BasicType.Real: 'REAL'>)]),
                   TypeDef(name='Rectangle',
                           ancestorType=UserType(name='Shape'),
                           varsDefs=[VarsDef(names=['width', 'height'],
                                             type=<BasicType.Real: 'REAL'>)])],
        var_defs=[VarsDef(names=['p1', 'p2'], type=UserType(name='Point')),
                  VarsDef(names=['s'], type=UserType(name='Shape')),
                  VarsDef(names=['c'], type=UserType(name='Circle')),
                  VarsDef(names=['r'], type=UserType(name='Rectangle')),
                  VarsDef(names=['ps'],
                          type=PointerType(pointerTo=UserType(name='Shape'))),
                  VarsDef(names=['pc'],
                          type=PointerType(pointerTo=UserType(name='Circle'))),
                  VarsDef(names=['pr'],
                          type=PointerType(pointerTo=UserType(name='Rectangle')))],
        statements=[AssignStatement(variable=VarWithFields(var=[SingleVar(varname='p1'),
                                                                'x']),
                                    expr=ConstExpr(value=10,
                                                   type=<BasicType.Integer: 'INTEGER'>)),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='p1'),
                                                                'y']),
                                    expr=ConstExpr(value=3.5,
                                                   type=<BasicType.Real: 'REAL'>)),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='s'),
                                                                'center']),
                                    expr=SingleVar(varname='p1')),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='s'),
                                                                'color']),
                                    expr=ConstExpr(value=100500,
                                                   type=<BasicType.Integer: 'INTEGER'>)),
                    AssignStatement(variable=SingleVar(varname='c'),
                                    expr=SingleVar(varname='s')),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='c'),
                                                                'radius']),
                                    expr=ConstExpr(value=7,
                                                   type=<BasicType.Integer: 'INTEGER'>)),
                    AssignStatement(variable=VarWithFields(var=[VarWithFields(var=[SingleVar(varname='r'),
                                                                                   'center']),
                                                                'x']),
                                    expr=ConstExpr(value=5.2,
                                                   type=<BasicType.Real: 'REAL'>)),
                    AssignStatement(variable=VarWithFields(var=[VarWithFields(var=[SingleVar(varname='r'),
                                                                                   'center']),
                                                                'y']),
                                    expr=ConstExpr(value=2.5,
                                                   type=<BasicType.Real: 'REAL'>)),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='r'),
                                                                'color']),
                                    expr=ConstExpr(value=500100,
                                                   type=<BasicType.Integer: 'INTEGER'>)),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='r'),
                                                                'width']),
                                    expr=ConstExpr(value=4.5,
                                                   type=<BasicType.Real: 'REAL'>)),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='r'),
                                                                'heigh']),
                                    expr=ConstExpr(value=5.4,
                                                   type=<BasicType.Real: 'REAL'>)),
                    AssignStatement(variable=SingleVar(varname='c'),
                                    expr=SingleVar(varname='r')),
                    NewStatement(variable='pr'),
                    AssignStatement(variable=DerefenceExpr(var=SingleVar(varname='pr')),
                                    expr=SingleVar(varname='r')),
                    AssignStatement(variable=SingleVar(varname='ps'),
                                    expr=SingleVar(varname='pr')),
                    NewStatement(variable='pc'),
                    AssignStatement(variable=DerefenceExpr(var=SingleVar(varname='pc')),
                                    expr=SingleVar(varname='c')),
                    AssignStatement(variable=VarWithFields(var=[SingleVar(varname='ps'),
                                                                'next']),
                                    expr=SingleVar(varname='pc')),
                    WhileStatement(condition=BinOpExpr(left=BinOpExpr(left=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                              'x']),
                                                                      op='*',
                                                                      right=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                               'y'])),
                                                       op='<',
                                                       right=ConstExpr(value=77777,
                                                                       type=<BasicType.Integer: 'INTEGER'>)),
                                   body=[AssignStatement(variable=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                     'x']),
                                                         expr=BinOpExpr(left=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                                'x']),
                                                                        op='*',
                                                                        right=ConstExpr(value=1.5,
                                                                                        type=<BasicType.Real: 'REAL'>))),
                                         AssignStatement(variable=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                     'y']),
                                                         expr=BinOpExpr(left=VarWithFields(var=[SingleVar(varname='p1'),
                                                                                                'y']),
                                                                        op='*',
                                                                        right=ConstExpr(value=2.5,
                                                                                        type=<BasicType.Real: 'REAL'>))),
                                         EmptyStatement()]),
                    IfStatement(condition=BinOpExpr(left=VarWithFields(var=[SingleVar(varname='p1'),
                                                                            'x']),
                                                    op='>',
                                                    right=VarWithFields(var=[SingleVar(varname='pc'),
                                                                             'radius'])),
                                then_branch=[AssignStatement(variable=SingleVar(varname='p2'),
                                                             expr=SingleVar(varname='p1')),
                                             AssignStatement(variable=SingleVar(varname='p1'),
                                                             expr=VarWithFields(var=[SingleVar(varname='pc'),
                                                                                     'center'])),
                                             EmptyStatement()],
                                else_branch=[AssignStatement(variable=SingleVar(varname='p2'),
                                                             expr=VarWithFields(var=[SingleVar(varname='pr'),
                                                                                     'center'])),
                                             EmptyStatement()]),
                    EmptyStatement()])
```

# Вывод
В ходе данной лабораторной работы был получен навык составления грамматик и 
проектирования синтаксических деревьев.
Разработанная программа принимает на вход текст на языке Оберон, а на выходе порождает 
абстрактное синтаксическое дерево.
