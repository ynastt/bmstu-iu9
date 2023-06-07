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
    def __init__(self, pos, name, ancestor):
        self.pos = pos
        self.varname = name
        self.ancestor = ancestor

    @property
    def message(self):
        return f'Наследование {self.varname} от {self.ancestor} не является ООП'


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
    @pe.ExAction
    def create(attrs, coords, res_coords):
        name, ancestorType_, varsDefs = attrs
        cname, cravn, crecord_kw, canctype, cvardefs, cend_kw, csemicolon = coords
        return TypeDef(name, cname, ancestorType_, canctype ,varsDefs)


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
        print(f'vars: {vars}\n')
        types = {}     
        for typedef in self.type_defs:
                name = typedef.name
                if name in types:
                    raise RepeatedType(typedef.name_coord, name)
                else:
                    types[name] = typedef.ancestorType
        print(f'types: {types}\n')
        for statement in self.statements:
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
            v = self.variable.varname[0]
            print(f' varname: {v}, expr: {self.expr.varname[0]}')
            if v not in vars:
                raise UnknownVar(self.variable, self.var_coord)
            
            # print("variable is known")
            self.expr.check(vars, types)

            if vars[v] == self.expr.type:
                print(f'here are  varname: {v}, expr: {self.expr.varname[0]}')
                return
            if vars[v] == BasicType.Real and self.expr.type == BasicType.Integer:
                return
            # Можно присваивать одну структуру другой структуре, если они имеют общего предка (прямо или косвенно).
            if type(vars[v]) is UserType and type(self.expr.type) is UserType:
                lf = set()
                lftype = vars[v].name
                # print(lftype)
                lf.add(lftype)
                anc = types[lftype]
                while type(anc) is UserType:
                    lf.add(anc.name) 
                    anc = types[anc.name]
                # print(f'all lf ancs: {lf}')

                rf = set()
                rftype = self.expr.type.name
                # print(rftype)
                rf.add(rftype)
                anc = types[rftype]
                while type(anc) is UserType:
                    rf.add(anc.name)
                    anc = types[anc.name]
                # print(f'all rf ancs: {rf}')
                shared = lf & rf
                # print(f'shared ancestor {shared}')
                if len(shared) == 0:
                    raise NotSharedAncestor(self.var_coord, self.variable.varname[0], self.expr.varname[0])
                else:
                    return
                
            # Можно присваивать указатель на производную структуру указателю на базовую структуру
            if type(vars[v]) is PointerType and type(self.expr.type) is PointerType:
                #  ОК, когда: указать на базовую структуру := указатель на производную структуру
                # print(vars[v], vars[v].pointerTo, vars[v].pointerTo.name)                
                # print(self.expr.type)
                rftype = self.expr.type.pointerTo.name
                anc = types[rftype]
                # print(anc)
                if type(anc) is not EmptyAncestorType:
                    if vars[v].pointerTo.name != anc.name:
                        raise PointerBadAssignment(self.var_coord, self.variable.varname[0], self.expr.varname[0])
                    else :
                        # print("ok")
                        return
                raise BinBadType(self.var_coord, vars[v], ':=', self.expr.type)    
            else:           
                raise BinBadType(self.var_coord, vars[v], ':=', self.expr.type)
        if type(self.variable) is DerefenceExpr:  # этого не было в тз
            # ОК, когда: pr^ := r; 
            # pr : POINTER TO Rectangle; r : Rectangle;
            print("DEREFENCE")
            v = self.variable.varname
            print(f' varname: {v}, expr: {self.expr}')
            vtype = vars[v.varname[0]].pointerTo.name
            print(vtype)
            extype = vars[self.expr.varname[0]].name                
            print(extype)
            if vtype != extype:
                #  Если 
                # проверим, есть ли общий предок, если нет - ошибка 
                
                lf = set()
                lf.add(vtype)
                print()
                anc = types[vtype]
                while type(anc) is UserType:
                    lf.add(anc.name) 
                    anc = types[anc.name]
                print(f'all lf ancs: {lf}')
                
                rf = set()
                rf.add(extype)
                anc = types[extype]
                while type(anc) is UserType:
                    rf.add(anc.name)
                    anc = types[anc.name]
                print(f'all rf ancs: {rf}')
                shared = lf & rf
                print(f'shared ancestor {shared}')
                if len(shared) == 0:
                    raise NotSharedAncestor(self.var_coord, v.varname[0], self.expr.varname[0])
                else:
                    print("ok")
                    return
            else :
                print("ok")
                return    
        else:
            print("fields var")
            # v = self.variable
            # print(f' varname: {v}, expr: {self.expr}')
        


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
        if self.condition.type != BasicType.Boolean:
            raise NotBoolCond(self.cond_coord, self.condition.type)
        self.then_branch.check(vars, types)
        self.else_branch.check(vars, types)


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
        if self.condition.type != BasicType.Boolean:
            raise NotBoolCond(self.cond_coord, self.condition.type)
        self.body.check(vars, types)


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
            raise UnknownVar(self.variable, self.var_coord)
        NotIntFor.check(vars[self.variable], self.var_coord)
        self.start.check(vars, types)
        NotIntFor.check(self.start.type, self.start_coord)
        self.end.check(vars, types)
        NotIntFor.check(self.end.type, self.end_coord)
        self.body.check(vars, types)


@dataclass
class StatementsBlock(Statement):
    body : list[Statement]
    def check(self, vars, types):
        for statement in self.body:
            statement.check(vars, types)


@dataclass
class EmptyStatement(Statement):
    def check(self, vars, types):
        pass


@dataclass
class DerefenceExpr(Expr):
    varname : Any 
    def check(self, vars, types):
        pass


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
        # print("he")
        v = self.varname[0]
        # print(f'varname: {v}, {type(v)}')
        try:
            self.type = vars[v]
        except KeyError:
            raise UnknownVar(self.var_coord, v)
        
       
@dataclass
class VarWithFieldsExpr(Expr):
    var: list[str]
    var_coord : pe.Position
    def create(varlist):
        @pe.ExAction
        def action(attrs, coords, res_coords):
            cvar, cdot, cfield = coords
            return VarWithFieldsExpr(varlist, cvar.start)
        return action
    def check(self, vars, types):
        pass


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
NVars |= VARNAME, ',', NVars, lambda v, vs: vs + [v]

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
NStatement |= KW_BEGIN, NStatements, KW_END, StatementsBlock
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

# NVar |= NVar, '^', DerefenceExpr
# NVar |= VARNAME, lambda var: VarWithFields([var])
# NVar |= NVar, '.', VARNAME, lambda v, f: VarWithFields([v, f])

NVar |= NVar, '^', DerefenceExpr
NVar |= VARNAME, SingleVarExpr.create
NVar |= NVar, '.', VARNAME, lambda v, f: VarWithFieldsExpr.create([v, f])
# NSingleVar |= VARNAME, SingleVarExpr.create
# NVarWithFields |= NVar, '.', VARNAME, lambda v, f: VarWithFieldsExpr.create([v, f])



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
            print('Программа корректна')
    except pe.Error as e:
        print(f'Ошибка {e.pos}: {e.message}')
    except Exception as e:
        print(e)
