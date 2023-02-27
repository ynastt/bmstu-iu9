ynastt@ynastt-VirtualBox:~/go/src/compilers/lab2$ ./astprint demo/test/test.go
     0  *ast.File {
     1  .  Doc: nil
     2  .  Package: demo/test/test.go:1:1
     3  .  Name: *ast.Ident {
     4  .  .  NamePos: demo/test/test.go:1:9
     5  .  .  Name: "main"
     6  .  .  Obj: nil
     7  .  }
     8  .  Decls: []ast.Decl (len = 3) {
     9  .  .  0: *ast.GenDecl {
    10  .  .  .  Doc: nil
    11  .  .  .  TokPos: demo/test/test.go:3:1
    12  .  .  .  Tok: import
    13  .  .  .  Lparen: -
    14  .  .  .  Specs: []ast.Spec (len = 1) {
    15  .  .  .  .  0: *ast.ImportSpec {
    16  .  .  .  .  .  Doc: nil
    17  .  .  .  .  .  Name: nil
    18  .  .  .  .  .  Path: *ast.BasicLit {
    19  .  .  .  .  .  .  ValuePos: demo/test/test.go:3:8
    20  .  .  .  .  .  .  Kind: STRING
    21  .  .  .  .  .  .  Value: "\"fmt\""
    22  .  .  .  .  .  }
    23  .  .  .  .  .  Comment: nil
    24  .  .  .  .  .  EndPos: -
    25  .  .  .  .  }
    26  .  .  .  }
    27  .  .  .  Rparen: -
    28  .  .  }
    29  .  .  1: *ast.GenDecl {
    30  .  .  .  Doc: nil
    31  .  .  .  TokPos: demo/test/test.go:5:1
    32  .  .  .  Tok: var
    33  .  .  .  Lparen: -
    34  .  .  .  Specs: []ast.Spec (len = 1) {
    35  .  .  .  .  0: *ast.ValueSpec {
    36  .  .  .  .  .  Doc: nil
    37  .  .  .  .  .  Names: []*ast.Ident (len = 1) {
    38  .  .  .  .  .  .  0: *ast.Ident {
    39  .  .  .  .  .  .  .  NamePos: demo/test/test.go:5:5
    40  .  .  .  .  .  .  .  Name: "s"
    41  .  .  .  .  .  .  .  Obj: *ast.Object {
    42  .  .  .  .  .  .  .  .  Kind: var
    43  .  .  .  .  .  .  .  .  Name: "s"
    44  .  .  .  .  .  .  .  .  Decl: *(obj @ 35)
    45  .  .  .  .  .  .  .  .  Data: 0
    46  .  .  .  .  .  .  .  .  Type: nil
    47  .  .  .  .  .  .  .  }
    48  .  .  .  .  .  .  }
    49  .  .  .  .  .  }
    50  .  .  .  .  .  Type: *ast.Ident {
    51  .  .  .  .  .  .  NamePos: demo/test/test.go:5:7
    52  .  .  .  .  .  .  Name: "string"
    53  .  .  .  .  .  .  Obj: nil
    54  .  .  .  .  .  }
    55  .  .  .  .  .  Values: []ast.Expr (len = 1) {
    56  .  .  .  .  .  .  0: *ast.BasicLit {
    57  .  .  .  .  .  .  .  ValuePos: demo/test/test.go:5:16
    58  .  .  .  .  .  .  .  Kind: STRING
    59  .  .  .  .  .  .  .  Value: "\"tt\""
    60  .  .  .  .  .  .  }
    61  .  .  .  .  .  }
    62  .  .  .  .  .  Comment: nil
    63  .  .  .  .  }
    64  .  .  .  }
    65  .  .  .  Rparen: -
    66  .  .  }
    67  .  .  2: *ast.FuncDecl {
    68  .  .  .  Doc: nil
    69  .  .  .  Recv: nil
    70  .  .  .  Name: *ast.Ident {
    71  .  .  .  .  NamePos: demo/test/test.go:7:6
    72  .  .  .  .  Name: "main"
    73  .  .  .  .  Obj: *ast.Object {
    74  .  .  .  .  .  Kind: func
    75  .  .  .  .  .  Name: "main"
    76  .  .  .  .  .  Decl: *(obj @ 67)
    77  .  .  .  .  .  Data: nil
    78  .  .  .  .  .  Type: nil
    79  .  .  .  .  }
    80  .  .  .  }
    81  .  .  .  Type: *ast.FuncType {
    82  .  .  .  .  Func: demo/test/test.go:7:1
    83  .  .  .  .  TypeParams: nil
    84  .  .  .  .  Params: *ast.FieldList {
    85  .  .  .  .  .  Opening: demo/test/test.go:7:10
    86  .  .  .  .  .  List: nil
    87  .  .  .  .  .  Closing: demo/test/test.go:7:11
    88  .  .  .  .  }
    89  .  .  .  .  Results: nil
    90  .  .  .  }
    91  .  .  .  Body: *ast.BlockStmt {
    92  .  .  .  .  Lbrace: demo/test/test.go:7:13
    93  .  .  .  .  List: []ast.Stmt (len = 5) {
    94  .  .  .  .  .  0: *ast.ExprStmt {
    95  .  .  .  .  .  .  X: *ast.CallExpr {
    96  .  .  .  .  .  .  .  Fun: *ast.SelectorExpr {
    97  .  .  .  .  .  .  .  .  X: *ast.Ident {
    98  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:8:2
    99  .  .  .  .  .  .  .  .  .  Name: "fmt"
   100  .  .  .  .  .  .  .  .  .  Obj: nil
   101  .  .  .  .  .  .  .  .  }
   102  .  .  .  .  .  .  .  .  Sel: *ast.Ident {
   103  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:8:6
   104  .  .  .  .  .  .  .  .  .  Name: "Println"
   105  .  .  .  .  .  .  .  .  .  Obj: nil
   106  .  .  .  .  .  .  .  .  }
   107  .  .  .  .  .  .  .  }
   108  .  .  .  .  .  .  .  Lparen: demo/test/test.go:8:13
   109  .  .  .  .  .  .  .  Args: []ast.Expr (len = 1) {
   110  .  .  .  .  .  .  .  .  0: *ast.Ident {
   111  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:8:14
   112  .  .  .  .  .  .  .  .  .  Name: "s"
   113  .  .  .  .  .  .  .  .  .  Obj: *(obj @ 41)
   114  .  .  .  .  .  .  .  .  }
   115  .  .  .  .  .  .  .  }
   116  .  .  .  .  .  .  .  Ellipsis: -
   117  .  .  .  .  .  .  .  Rparen: demo/test/test.go:8:15
   118  .  .  .  .  .  .  }
   119  .  .  .  .  .  }
   120  .  .  .  .  .  1: *ast.ExprStmt {
   121  .  .  .  .  .  .  X: *ast.CallExpr {
   122  .  .  .  .  .  .  .  Fun: *ast.SelectorExpr {
   123  .  .  .  .  .  .  .  .  X: *ast.Ident {
   124  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:9:2
   125  .  .  .  .  .  .  .  .  .  Name: "fmt"
   126  .  .  .  .  .  .  .  .  .  Obj: nil
   127  .  .  .  .  .  .  .  .  }
   128  .  .  .  .  .  .  .  .  Sel: *ast.Ident {
   129  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:9:6
   130  .  .  .  .  .  .  .  .  .  Name: "Println"
   131  .  .  .  .  .  .  .  .  .  Obj: nil
   132  .  .  .  .  .  .  .  .  }
   133  .  .  .  .  .  .  .  }
   134  .  .  .  .  .  .  .  Lparen: demo/test/test.go:9:13
   135  .  .  .  .  .  .  .  Args: []ast.Expr (len = 1) {
   136  .  .  .  .  .  .  .  .  0: *ast.BasicLit {
   137  .  .  .  .  .  .  .  .  .  ValuePos: demo/test/test.go:9:14
   138  .  .  .  .  .  .  .  .  .  Kind: STRING
   139  .  .  .  .  .  .  .  .  .  Value: "\"Hello,\""
   140  .  .  .  .  .  .  .  .  }
   141  .  .  .  .  .  .  .  }
   142  .  .  .  .  .  .  .  Ellipsis: -
   143  .  .  .  .  .  .  .  Rparen: demo/test/test.go:9:22
   144  .  .  .  .  .  .  }
   145  .  .  .  .  .  }
   146  .  .  .  .  .  2: *ast.ExprStmt {
   147  .  .  .  .  .  .  X: *ast.CallExpr {
   148  .  .  .  .  .  .  .  Fun: *ast.SelectorExpr {
   149  .  .  .  .  .  .  .  .  X: *ast.Ident {
   150  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:10:2
   151  .  .  .  .  .  .  .  .  .  Name: "fmt"
   152  .  .  .  .  .  .  .  .  .  Obj: nil
   153  .  .  .  .  .  .  .  .  }
   154  .  .  .  .  .  .  .  .  Sel: *ast.Ident {
   155  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:10:6
   156  .  .  .  .  .  .  .  .  .  Name: "Println"
   157  .  .  .  .  .  .  .  .  .  Obj: nil
   158  .  .  .  .  .  .  .  .  }
   159  .  .  .  .  .  .  .  }
   160  .  .  .  .  .  .  .  Lparen: demo/test/test.go:10:13
   161  .  .  .  .  .  .  .  Args: []ast.Expr (len = 1) {
   162  .  .  .  .  .  .  .  .  0: *ast.BasicLit {
   163  .  .  .  .  .  .  .  .  .  ValuePos: demo/test/test.go:10:14
   164  .  .  .  .  .  .  .  .  .  Kind: STRING
   165  .  .  .  .  .  .  .  .  .  Value: "\"World!\""
   166  .  .  .  .  .  .  .  .  }
   167  .  .  .  .  .  .  .  }
   168  .  .  .  .  .  .  .  Ellipsis: -
   169  .  .  .  .  .  .  .  Rparen: demo/test/test.go:10:22
   170  .  .  .  .  .  .  }
   171  .  .  .  .  .  }
   172  .  .  .  .  .  3: *ast.DeclStmt {
   173  .  .  .  .  .  .  Decl: *ast.GenDecl {
   174  .  .  .  .  .  .  .  Doc: nil
   175  .  .  .  .  .  .  .  TokPos: demo/test/test.go:12:2
   176  .  .  .  .  .  .  .  Tok: var
   177  .  .  .  .  .  .  .  Lparen: -
   178  .  .  .  .  .  .  .  Specs: []ast.Spec (len = 1) {
   179  .  .  .  .  .  .  .  .  0: *ast.ValueSpec {
   180  .  .  .  .  .  .  .  .  .  Doc: nil
   181  .  .  .  .  .  .  .  .  .  Names: []*ast.Ident (len = 1) {
   182  .  .  .  .  .  .  .  .  .  .  0: *ast.Ident {
   183  .  .  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:12:6
   184  .  .  .  .  .  .  .  .  .  .  .  Name: "x"
   185  .  .  .  .  .  .  .  .  .  .  .  Obj: *ast.Object {
   186  .  .  .  .  .  .  .  .  .  .  .  .  Kind: var
   187  .  .  .  .  .  .  .  .  .  .  .  .  Name: "x"
   188  .  .  .  .  .  .  .  .  .  .  .  .  Decl: *(obj @ 179)
   189  .  .  .  .  .  .  .  .  .  .  .  .  Data: 0
   190  .  .  .  .  .  .  .  .  .  .  .  .  Type: nil
   191  .  .  .  .  .  .  .  .  .  .  .  }
   192  .  .  .  .  .  .  .  .  .  .  }
   193  .  .  .  .  .  .  .  .  .  }
   194  .  .  .  .  .  .  .  .  .  Type: *ast.Ident {
   195  .  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:12:8
   196  .  .  .  .  .  .  .  .  .  .  Name: "string"
   197  .  .  .  .  .  .  .  .  .  .  Obj: nil
   198  .  .  .  .  .  .  .  .  .  }
   199  .  .  .  .  .  .  .  .  .  Values: []ast.Expr (len = 1) {
   200  .  .  .  .  .  .  .  .  .  .  0: *ast.BasicLit {
   201  .  .  .  .  .  .  .  .  .  .  .  ValuePos: demo/test/test.go:12:17
   202  .  .  .  .  .  .  .  .  .  .  .  Kind: STRING
   203  .  .  .  .  .  .  .  .  .  .  .  Value: "\"Goodbye!\""
   204  .  .  .  .  .  .  .  .  .  .  }
   205  .  .  .  .  .  .  .  .  .  }
   206  .  .  .  .  .  .  .  .  .  Comment: nil
   207  .  .  .  .  .  .  .  .  }
   208  .  .  .  .  .  .  .  }
   209  .  .  .  .  .  .  .  Rparen: -
   210  .  .  .  .  .  .  }
   211  .  .  .  .  .  }
   212  .  .  .  .  .  4: *ast.ExprStmt {
   213  .  .  .  .  .  .  X: *ast.CallExpr {
   214  .  .  .  .  .  .  .  Fun: *ast.SelectorExpr {
   215  .  .  .  .  .  .  .  .  X: *ast.Ident {
   216  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:13:2
   217  .  .  .  .  .  .  .  .  .  Name: "fmt"
   218  .  .  .  .  .  .  .  .  .  Obj: nil
   219  .  .  .  .  .  .  .  .  }
   220  .  .  .  .  .  .  .  .  Sel: *ast.Ident {
   221  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:13:6
   222  .  .  .  .  .  .  .  .  .  Name: "Println"
   223  .  .  .  .  .  .  .  .  .  Obj: nil
   224  .  .  .  .  .  .  .  .  }
   225  .  .  .  .  .  .  .  }
   226  .  .  .  .  .  .  .  Lparen: demo/test/test.go:13:13
   227  .  .  .  .  .  .  .  Args: []ast.Expr (len = 1) {
   228  .  .  .  .  .  .  .  .  0: *ast.Ident {
   229  .  .  .  .  .  .  .  .  .  NamePos: demo/test/test.go:13:14
   230  .  .  .  .  .  .  .  .  .  Name: "x"
   231  .  .  .  .  .  .  .  .  .  Obj: *(obj @ 185)
   232  .  .  .  .  .  .  .  .  }
   233  .  .  .  .  .  .  .  }
   234  .  .  .  .  .  .  .  Ellipsis: -
   235  .  .  .  .  .  .  .  Rparen: demo/test/test.go:13:15
   236  .  .  .  .  .  .  }
   237  .  .  .  .  .  }
   238  .  .  .  .  }
   239  .  .  .  .  Rbrace: demo/test/test.go:14:1
   240  .  .  .  }
   241  .  .  }
   242  .  }
   243  .  Scope: *ast.Scope {
   244  .  .  Outer: nil
   245  .  .  Objects: map[string]*ast.Object (len = 2) {
   246  .  .  .  "s": *(obj @ 41)
   247  .  .  .  "main": *(obj @ 73)
   248  .  .  }
   249  .  }
   250  .  Imports: []*ast.ImportSpec (len = 1) {
   251  .  .  0: *(obj @ 15)
   252  .  }
   253  .  Unresolved: []*ast.Ident (len = 6) {
   254  .  .  0: *(obj @ 50)
   255  .  .  1: *(obj @ 97)
   256  .  .  2: *(obj @ 123)
   257  .  .  3: *(obj @ 149)
   258  .  .  4: *(obj @ 194)
   259  .  .  5: *(obj @ 215)
   260  .  }
   261  .  Comments: nil
   262  }
