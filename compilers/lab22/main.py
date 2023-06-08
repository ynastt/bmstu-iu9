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

# NVar |= NVar, '^', DerefenceExpr
# NVar |= VARNAME, lambda var: VarWithFields([var])
# NVar |= NVar, '.', VARNAME, lambda v, f: VarWithFields([v, f])

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
