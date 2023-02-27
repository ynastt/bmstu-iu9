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
