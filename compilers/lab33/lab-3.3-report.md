% Лабораторная работа № 3.3 «Семантический анализ»
% 30 мая 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является получение навыков выполнения семантического анализа.

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

Семантический анализ  
- Синтаксис RECORD(‹предок›) означает объектно-ориентированное наследование.
- Можно присваивать одну структуру другой структуре, если они имеют общего предка (прямо или косвенно).
- Можно присваивать указатель на производную структуру указателю на базовую структуру.
- Правила проверки типов в арифметических и логических выражениях те же, что и в Паскале.

# Реализация

## Лексическая структура и конкретный синтаксис

Грамматика:
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
import parser_edsl_sema.parser_edsl as pe
import sys
import typing
from dataclasses import dataclass
from pprint import pprint
from typing import Any

# Классы исключений для семантических ошибок

class SemanticError(pe.Error):
    pass

class RepeatedVariable(SemanticError):
    def __init__(self, pos, varname):
        self.pos = pos
        self.varname = varname

    @property
    def message(self):
        return f'Повторная переменная {self.varname}'
    
class RepeatedType(SemanticError):
    def __init__(self, pos, name):
        self.pos = pos
        self.name = name

    @property
    def message(self):
        return f'Повторное объявление типа {self.name}'

class UnknownVar(SemanticError):
    def __init__(self, pos, varname):
        self.pos = pos
        self.varname = varname

    @property
    def message(self):
        return f'Необъявленная переменная {self.varname}'

class NotOOPInheritance(SemanticError):
    def __init__(self, pos, name):
        self.pos = pos
        self.varname = name

    @property
    def message(self):
        return f'Нарушение Объектно-Ориентированного наследования: {self.varname}'


class NotSharedAncestor(SemanticError):
    def __init__(self, pos, varname1, varname2):
        self.pos = pos
        self.varname1 = varname1
        self.varname2 = varname2

    @property
    def message(self):
        return f'Структуры {self.varname1} и {self.varname2} не имеют общего предка'


class PointerBadAssignment(SemanticError):
    def __init__(self, pos, varname1, varname2):
        self.pos = pos
        self.varname1 = varname1
        self.varname2 = varname2

    @property
    def message(self):
        return f'{self.varname2} не является производной от {self.varname1}'


class BinBadType(SemanticError):
    def __init__(self, pos, left, op, right):
        self.pos = pos
        self.left = left
        self.op = op
        self.right = right

    @property
    def message(self):
        return f'Несовместимые типы: {self.left} {self.op} {self.right}'


class UnBadType(SemanticError):
    def __init__(self, pos, op, type_):
        self.pos = pos
        self.op = op
        self.type = type_

    @property
    def message(self):
        return f'Несовместимый тип: {self.op} {self.type}'


class NotBoolCond(SemanticError):
    def __init__(self, pos, type_):
        self.pos = pos
        self.type = type_

    @property
    def message(self):
        return f'Условие имеет тип {self.type} вместо логического'


class NotIntFor(SemanticError):
    def __init__(self, pos, type_):
        self.pos = pos
        self.type = type_

    @property
    def message(self):
        return f'Ожидался целый тип, получен {self.type}'

    @staticmethod
    def check(type_, pos):
        if type_ != Type.Integer:
            raise NotIntFor(pos, type_)


# Классы узлов
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
    names_coord : pe.Position
    type : Type or BasicType
    @pe.ExAction
    def create(attrs, coords, res_coord):
        names, type_ = attrs
        cnames, ccolon, ctype, csemicolon = coords
        return VarsDef(names, cnames.start, type_)

@dataclass
class TypeDef:
    name : str
    name_coord : pe.Position
    ancestorType : Type
    ancestor_coord : pe.Position
    varsDefs: VarsDef
    possibleFields: dict
    @pe.ExAction
    def create(attrs, coords, res_coords):
        name, ancestorType_, varsDefs = attrs
        cname, cravn, crecord_kw, canctype, cvardefs, cend_kw, csemicolon = coords
        return TypeDef(name, cname, ancestorType_, canctype ,varsDefs, dict())
    
    def findPossibleFields(self, types):
        fields = {}
        ownfields = types[self.name].varsDefs
        for f in ownfields:
            for n in f.names:
                fields[n] = f.type
        anc = types[self.name].ancestorType
        while type(anc) is UserType:
            ofs = types[anc.name].varsDefs
            for f in ofs:
                for n in f.names:
                    fields[n] = f.type
            anc = types[anc.name].ancestorType    
        # print(f'all possible fields: {fields}')
        return fields  



class Statement(abc.ABC):
    @abc.abstractmethod
    def check(self, vars, types):
        pass


@dataclass
class Program:
    type_defs: list[TypeDef]
    var_defs : list[VarsDef]
    statements : list[Statement]
    def check(self):
        vars = {}
        for vardef in self.var_defs:
            for name in vardef.names:
                if name in vars:
                    raise RepeatedVariable(vardef.names_coord, name)
                else:
                    vars[name] = vardef.type   
        print(f'\nvars:')
        for v in vars: print(v, vars[v])

        types = {}     
        for typedef in self.type_defs:
                name = typedef.name
                if name in types:
                    raise RepeatedType(typedef.name_coord, name)
                else:
                    types[name] = typedef
        for typedef in self.type_defs:
            name = typedef.name
            types[name].possibleFields = types[name].findPossibleFields(types)   
        print(f'\n\ntypes:')
        for t in types: print(t, types[t].ancestorType, types[t].varsDefs, types[t].possibleFields )
        
        for statement in self.statements:
            print(f'\n\n***current statement: {statement}')
            statement.check(vars, types)

class Expr(abc.ABC):
    @abc.abstractmethod
    def check(self, vars, types):
        pass


@dataclass
class AssignStatement(Statement):
    variable : Any 
    var_coord : pe.Position
    expr : Expr
    @pe.ExAction
    def create(attrs, coords, res_coord):
        var, expr = attrs
        cvar, cass, cexpr = coords
        return AssignStatement(var, cass.start, expr)
    
    def check(self, vars, types):
        if type(self.variable) is SingleVarExpr:
            print("single")
            print(self.variable)
            v = self.variable.varname[0]
            print(f' varname: {v},\n expr: {self.expr}')
            if v not in vars:
                raise UnknownVar(self.var_coord, v)
            
            # print("variable is known")
            self.expr.check(vars, types)
            is_numeric = lambda t: t in (BasicType.Integer, BasicType.Real)
            if vars[v] == self.expr.type:
                print(f'  same type')
                return
            if is_numeric(vars[v]) and is_numeric(self.expr.type):
                return
            # Можно присваивать одну структуру другой структуре, если они имеют общего предка (прямо или косвенно).
            if type(vars[v]) is UserType and type(self.expr.type) is UserType:
                lf = set()
                lftype = vars[v].name
                # print(lftype)
                lf.add(lftype)
                anc = types[lftype].ancestorType
                while type(anc) is UserType:
                    lf.add(anc.name) 
                    anc = types[anc.name].ancestorType
                # print(f'all lf ancs: {lf}')

                rf = set()
                rftype = self.expr.type.name
                # print(rftype)
                rf.add(rftype)
                anc = types[rftype].ancestorType
                while type(anc) is UserType:
                    rf.add(anc.name)
                    anc = types[anc.name].ancestorType
                # print(f'all rf ancs: {rf}')
                shared = lf & rf
                # print(f'shared ancestor {shared}')
                if len(shared) == 0:
                    raise NotSharedAncestor(self.var_coord, self.variable.varname[0], self.expr.varname[0])
                else:
                    return
                
            # Можно присваивать указатель на производную структуру указателю на базовую структуру
            if type(vars[v]) is PointerType and type(self.expr.type) is PointerType:
                #  ОК, когда: указатель на базовую структуру := указатель на производную структуру
                rftype = self.expr.type.pointerTo.name
                anc = types[rftype].ancestorType
                # print(anc)
                if type(anc) is not EmptyAncestorType:
                    if vars[v].pointerTo.name != anc.name:
                        raise PointerBadAssignment(self.var_coord, self.variable.varname[0], self.expr.varname[0])
                    else :
                        return
                raise BinBadType(self.var_coord, vars[v], ':=', self.expr.type)    
            else:           
                raise BinBadType(self.var_coord, vars[v], ':=', self.expr.type)   
        elif type(self.variable) is DerefenceExpr:
            print("derefence var")
            v = self.variable
            ex = self.expr
            # print(f' varname: {v}, expr: {ex}')
            self.variable.check(vars, types)
            self.expr.check(vars, types)
        elif type(self.variable) is VarWithFieldsExpr:
            print("fields var")
            v = self.variable
            ex = self.expr
            print(f' varname: {v},\n expr: {ex}')
            self.variable.check(vars, types)
            self.expr.check(vars, types)
            # проверяю, соответствие типов присваимовой пееременной ex prи поля var.field переменной var, которому присваивается значение
            print("...LATER...")
            common_type = None
            is_numeric = lambda t: t in (BasicType.Integer, BasicType.Real)

            if self.variable.type == self.expr.type:
                return
            elif is_numeric(self.variable.type) and is_numeric(self.expr.type):
                return
            elif type(self.variable.type) is PointerType and type(self.expr.type) is PointerType:
                rtype = self.expr.type.pointerTo.name
                anc = types[rtype].ancestorType
                if type(anc) is not EmptyAncestorType:
                    if self.variable.type.pointerTo.name != anc.name:
                        raise PointerBadAssignment(self.var_coord, self.variable, self.expr)
                    else :
                        return
                raise BinBadType(self.var_coord, self.variable.type, ':=', self.expr.type)
            else: 
                raise BinBadType(self.var_coord, self.variable.type, ':=', self.expr.type)


@dataclass
class NewStatement(Statement):
    variable: Any
    def check(self, vars, types):
        pass 


@dataclass
class IfStatement(Statement):
    condition : Expr
    cond_coord : pe.Fragment
    then_branch : Statement
    else_branch : Statement
    @pe.ExAction
    def create(attrs, coords, res_coord):
        cond, then_branch, else_branch = attrs
        cif, ccond, cthen_kw, cthen_br, celse_kw, celse_br, cend_kw = coords
        return IfStatement(cond, ccond, then_branch, else_branch)
    def check(self, vars, types):
        self.condition.check(vars, types)
        print(f'IF CONDITION: {self.condition}')
        if self.condition.type != BasicType.Boolean:
            raise NotBoolCond(self.cond_coord, self.condition.type)
        for t in self.then_branch:
            t.check(vars, types)
        for e in self.else_branch:
            e.check(vars, types)


@dataclass
class WhileStatement(Statement):
    condition : Expr
    cond_coord : pe.Fragment
    body : Statement
    @pe.ExAction
    def create(attrs, coords, res_coord):
        cond, body = attrs
        cwhile_kw, ccond, cdo_kw, cbody, cend_kw = coords
        return WhileStatement(cond, ccond, body)
    def check(self, vars, types):
        self.condition.check(vars, types)
        print(f'WHILE CONDITION: {self.condition}')
        if self.condition.type != BasicType.Boolean:
            raise NotBoolCond(self.cond_coord, self.condition.type)
        print("here")
        for b in self.body:
            b.check(vars, types)


@dataclass
class ForStatement(Statement):
    variable : str 
    var_coord : pe.Position
    start : Expr
    start_coord : pe.Fragment
    end : Expr
    end_coord : pe.Fragment
    body : Statement
    @pe.ExAction
    def create(attrs, coords, res_coord):
        varname, start, end, body = attrs
        cfor_kw, cvar, cass, cstart, cto_kw, cend, cdo_kw, cbody, cend_kw = coords
        return ForStatement(varname, cvar, start, cstart, end, cend, body)
    def check(self, vars, types):
        if self.variable not in vars:
            raise UnknownVar(self.var_coord, self.variable)
        NotIntFor.check(vars[self.variable], self.var_coord)
        self.start.check(vars, types)
        NotIntFor.check(self.start.type, self.start_coord)
        self.end.check(vars, types)
        NotIntFor.check(self.end.type, self.end_coord)
        self.body.check(vars, types)


@dataclass
class EmptyStatement(Statement):
    def check(self, vars, types):
        pass


@dataclass
class DerefenceExpr(Expr):
    varname : Any
    var_coord : pe.Position

    @pe.ExAction
    def create(attrs, coords, res_coord):
        varname = attrs
        cvarname, cder = coords
        return DerefenceExpr(varname, cvarname)  
       
    def check(self, vars, types):
        dname = self.varname[0]
        # print(f' deref varname: {dname}')
        if type(dname) is SingleVarExpr:
            v = dname.varname[0]
            # print(f'  name: {v}')
            try:
                self.type = vars[v]
            except KeyError:
                raise UnknownVar(self.var_coord, v)
            


@dataclass
class SingleVarExpr(Expr):
    varname : str
    var_coord : pe.Position

    @pe.ExAction
    def create(attrs, coords, res_coord):
        varname = attrs
        cvarname = coords
        return SingleVarExpr(varname, cvarname)
    
    def check(self, vars, types):
        v = self.varname[0]
        print(f'  single varname: {v}, type: {vars[v]}')
        try:
            self.type = vars[v]
        except KeyError:
            raise UnknownVar(self.var_coord, v)
        
       
@dataclass
class VarWithFieldsExpr(Expr):
    var: list[str]
    field: str
    var_coord : pe.Position
    @pe.ExAction
    def create(attrs, coords, res_coord):
        var, field = attrs
        cvar, cdot, cfield = coords
        return VarWithFieldsExpr(var, field, cvar.start)
    def check(self, vars, types):
        varname = self
        varfield = self.field
        print(f'\nvar of var: {varname}\n  field: {varfield}')
        print("are fields correct?")
        # OOP?
        fields = []
        while type(varname) is VarWithFieldsExpr:
            print(f'   var: {varname}\n   field: {varfield}')
            fields.append(varfield)

            if type(varname.var) is SingleVarExpr:
                name = varname.var.varname[0]
                try:
                    typ = vars[name]
                except KeyError:
                    raise UnknownVar(self.var_coord, name)
                
                print(f'    name: {name}, field: {varfield}')
                fields =list(reversed(fields))
                print(fields)
                if type(vars[name]) is UserType:
                    typ =vars[name].name
                elif type(vars[name]) is PointerType:
                    typ =vars[name].pointerTo.name    
                print(typ)
                fds = types[typ].possibleFields
                prev = name
                for f in fields:
                    print(f'pos fields: {fds}')
                    if len(fds) != 0 and f not in fds:
                        raise NotOOPInheritance(self.var_coord, prev + "." + f)
                    t = fds[f]
                    try:
                        self.type = fds[f]
                    except KeyError:
                        raise UnknownVar(self.var_coord, f)
                    if type(t) is UserType: 
                        fds = types[t.name].possibleFields
                    if type(t) is PointerType: 
                        fds = types[t.pointerTo.name].possibleFields   
                    prev = f
                    print(fds)
                    print(self.type)
                break
            varname = varname.var
            varfield = varname.field



@dataclass
class ConstExpr(Expr):
    value : typing.Any
    type : Type or BasicType
    def check(self, vars, types):
        pass


@dataclass
class BinOpExpr(Expr):
    left : Expr
    op : str
    op_coord : pe.Position
    right : Expr

    @staticmethod
    def create():
        @pe.ExAction
        def action(attrs, coords, res_coords):
            left, op, right = attrs
            cleft, cop, cright = coords
            return BinOpExpr(left, op, cop.start, right)
        return action
    def check(self, vars, types):
        self.left.check(vars, types)
        self.right.check(vars, types)

        common_type = None
        is_numeric = lambda t: t in (BasicType.Integer, BasicType.Real)

        if self.left.type == self.right.type:
            common_type = self.left.type
        elif is_numeric(self.left.type) and is_numeric(self.right.type):
            common_type = BasicType.Real

        self.type = None
        if self.op in ('<', '>', '<=', '>=', '=', '<>'):
            if common_type != None:
                self.type = BasicType.Boolean
        elif self.op in ('and', 'or'):
            if common_type == BasicType.Boolean:
                self.type = BasicType.Boolean
        elif self.op in ('div', 'mod'):
            if common_type == BasicType.Integer:
                self.type = BasicType.Integer
        elif self.op in ('+', '-', '*', '**'):
            if is_numeric(common_type):
                self.type = common_type
        else:
            assert self.op == '/'
            if is_numeric(common_type):
                self.type = BasicType.Real

        if self.type == None:
            raise BinBadType(self.op_coord, self.left.type,
                    self.op, self.right.type)


@dataclass
class UnOpExpr(Expr):
    op : str
    op_coord : pe.Position
    expr : Expr
    @staticmethod
    def create(op):
        @pe.ExAction
        def action(attrs, coords, res_coords):
            expr, = attrs
            cop, cexpr = coords
            return UnOpExpr(op, cop.start, expr)
        return action
    def check(self, vars, types):
        self.expr.check(vars, types)
        if self.op in ('+', '-') and \
                self.expr.type not in (Type.Integer, Type.Real):
            raise UnBadType(self.op_coord, self.op, self.expr.type)
        if self.op == 'not' and self.expr.type != Type.Boolean:
            raise UnBadType(self.op_coord, self.op, self.expr.type)
        self.type = self.expr.type

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
NTypeDef |= VARNAME, '=', KW_RECORD, NAncestorType, NVarsDefs, KW_END, ';', TypeDef.create
NAncestorType |= '(', VARNAME, ')', UserType
NAncestorType |= EmptyAncestorType

NVarsDefs |= lambda: []
NVarsDefs |= NVarsDefs, NVarsDef, lambda vds, vd: vds + [vd]
NVarsDef |= NVars, ':', NType, ';' , VarsDef.create

NVars |= VARNAME, lambda v: [v]
NVars |= VARNAME, ',', NVars, lambda v, vs:  [v] + vs

NType |= KW_INTEGER, lambda: BasicType.Integer
NType |= KW_REAL, lambda: BasicType.Real
NType |= KW_BOOLEAN, lambda: BasicType.Boolean
NType |= VARNAME, UserType
NType |= KW_POINTER, KW_TO, NType, lambda type: PointerType(type)

NStatements |= NStatement, lambda st: [st]
NStatements |= NStatements, ';', NStatement, lambda sts, st: sts + [st]

NStatement |= NVar, ':=', NExpr, AssignStatement.create
NStatement |= KW_NEW, '(', VARNAME, ')', NewStatement 
NStatement |= (
    KW_IF, NExpr, KW_THEN, NStatements, KW_ELSE, NStatements, KW_END, IfStatement.create
)
NStatement |= KW_WHILE, NExpr, KW_DO, NStatements, KW_END, WhileStatement.create
NStatement |= (
    KW_FOR, NVar, ':=', NExpr, KW_TO, NExpr, KW_DO, NStatement, KW_END, ForStatement.create
)
NStatement |= EmptyStatement


NExpr |= NArithmExpr
NExpr |= NArithmExpr, NCmpOp, NArithmExpr, BinOpExpr.create()

def make_op_lambda(op):
    return lambda: op

for op in ('>', '<', '>=', '<=', '=', '<>'):
    NCmpOp |= op, make_op_lambda(op)

NArithmExpr |= NTerm
NArithmExpr |= '+', NTerm, UnOpExpr.create('+')
NArithmExpr |= '-', NTerm, UnOpExpr.create('-')
NArithmExpr |= NArithmExpr, NAddOp, NTerm, BinOpExpr.create()

NAddOp |= '+', lambda: '+'
NAddOp |= '-', lambda: '-'
NAddOp |= KW_OR, lambda: 'or'

NTerm |= NFactor
NTerm |= NTerm, NMulOp, NFactor, BinOpExpr.create()

NMulOp |= '*', lambda: '*'
NMulOp |= '/', lambda: '/'
NMulOp |= KW_DIV, lambda: 'div'
NMulOp |= KW_MOD, lambda: 'mod'
NMulOp |= KW_AND, lambda: 'and'

NFactor |= KW_NOT, NFactor, UnOpExpr.create('not')
NFactor |= NVar
NFactor |= NConst
NFactor |= '(', NExpr, ')'

NVar |= NVar, '^', DerefenceExpr.create
NVar |= VARNAME, SingleVarExpr.create
NVar |= NVar, '.', VARNAME, VarWithFieldsExpr.create

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
            # pprint(tree)
            tree.check()
            print('Correct program')
    except pe.Error as e:
        print(f'Error {e.pos}: {e.message}')
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
  r.center.x.t := 0; (*тут ошибка*)
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
Error (56, 3): Нарушение Объектно-Ориентированного наследования: x.t
```

В случае отсутствия ошибок, результат программы:
```
Correct program
```

# Вывод
В ходе данной лабораторной работы был получен навык выполнения семантического анализа 
Разработанная программа принимает на вход программу на языке Оберон, а на выходе
предоставляет информацию об ошибках (при условии их наличия) в соотвествии с индивидуальным вариантом.
