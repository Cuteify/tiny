package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
)

// ImportItem 描述一条文件级导入（Wave L）。
// Alias 为空表示使用默认别名（Go 语义：路径末段）；"_" 表示空导入
// （只为副作用加载包，不绑定名称）。
type ImportItem struct {
	Alias string
	Path  string
}

// ImportBlock 文件顶层 import 声明。
// 只做语法解析与校验：别名可见性由 package 层把别名注册进 packageInfo.Imports
// （与 package.json imports 同一通道）完成，这里不向语法树挂节点
// （防 gc 前端遇到未知顶层节点类型）。
type ImportBlock struct {
	Items []ImportItem
}

// Parse 解析 import 声明。语法与 Go 一致：
//
//	import "path"          // 默认别名 = 路径末段
//	import alias "path"    // 前缀别名
//	import _ "path"        // 空导入
//	import ( ... )         // 分组
//
// 路径一律带双引号；`.` 点导入 defer（R10）；反引号 RAW 不接受。
func (ib *ImportBlock) Parse(p *Parser) {
	// 仅允许文件顶层
	if p.ThisBlock != p.Block {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "import is only allowed at top level")
	}
	token := p.Lexer.Next()
	if token.Type == lexer.SEPARATOR && token.Value == "(" {
		ib.parseGroup(p)
		return
	}
	// 单条形式：回退后按条目解析
	p.Lexer.SetCursor(token.Cursor)
	item := parseImportItem(p)
	if item == nil {
		return
	}
	ib.Items = appendImportItem(p, ib.Items, *item)
}

// parseGroup 解析分组形式 import ( ... )：条目之间允许换行/分号。
func (ib *ImportBlock) parseGroup(p *Parser) {
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ')' in import group")
		}
		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case ")":
				return
			case "\n", "\r", ";":
				continue
			default:
				p.Error.MissError("Syntax Error", token.Cursor, "unexpected '"+token.Value+"' in import group")
			}
		}
		// 条目起始 token（别名或路径），回退后统一按条目解析
		p.Lexer.SetCursor(token.Cursor)
		item := parseImportItem(p)
		if item == nil {
			return
		}
		ib.Items = appendImportItem(p, ib.Items, *item)
	}
}

// parseImportItem 解析一条导入条目：[alias] "path"。出错时返回 nil。
func parseImportItem(p *Parser) *ImportItem {
	token := p.Lexer.Next()
	if token.Type == lexer.RAW {
		p.Error.MissError("Syntax Error", token.Cursor, "import path must be a quoted string")
	}
	if token.Type == lexer.SEPARATOR && token.Value == "." {
		// R10：`.` 点导入 defer，一期报错
		p.Error.MissError("Syntax Error", token.Cursor, "dot import is not supported yet")
	}
	if token.Type == lexer.STRING {
		// 无别名形式
		return &ImportItem{Path: token.Value}
	}
	if token.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", token.Cursor, "need import path string")
	}
	alias := token.Value
	pathToken := p.Lexer.Next()
	if pathToken.Type == lexer.RAW {
		p.Error.MissError("Syntax Error", pathToken.Cursor, "import path must be a quoted string")
	}
	if pathToken.Type != lexer.STRING {
		p.Error.MissError("Syntax Error", pathToken.Cursor, "need import path string after alias '"+alias+"'")
	}
	return &ImportItem{Alias: alias, Path: pathToken.Value}
}

// importAliasOf 取条目的有效别名（无别名时用路径末段，与 Go 一致）
func importAliasOf(item ImportItem) string {
	if item.Alias != "" {
		return item.Alias
	}
	return packageFmt.DefaultImportAlias(item.Path)
}

// appendImportItem 向列表追加条目：同别名同路径去重，同别名异路径报错。
func appendImportItem(p *Parser, list []ImportItem, item ImportItem) []ImportItem {
	name := importAliasOf(item)
	for _, prev := range list {
		prevName := importAliasOf(prev)
		if prevName != name {
			continue
		}
		if prev.Path == item.Path {
			return list
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor,
			"import alias '"+name+"' already used for '"+prev.Path+"'")
	}
	return append(list, item)
}
