package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	"cuteify/utils"
	"strings"
)

// NamePart 表示Name中的一个部分，可以是普通名称或切片
type NamePart struct {
	Name      string
	Slice     *NameSlice // nil表示非切片访问
	IsPkgPath bool
}

// NameSlice 表示切片信息
type NameSlice struct {
	Start *Expression
	End   *Expression
	Step  *Expression
}

// Name 表示一个完整的名称路径
type Name []NamePart

// String 返回名称的点分连接形式（NASM 安全格式）
func (n Name) String() string {
	parts := make([]string, len(n))
	for i, part := range n {
		if part.Slice != nil {
			sliceStr := part.Slice.String()
			parts[i] = part.Name + sliceStr
		} else {
			parts[i] = part.Name
		}
	}
	return strings.Join(parts, ".")
}

func (n Name) NASM() string {
	return utils.ToNASMName(n.String())
}

func (n Name) Length() int {
	return len(n)
}

// String 将切片指示器转换为字符串表示
func (s *NameSlice) String() string {
	if s == nil {
		return ""
	}

	parts := []string{"["}

	if s.Start != nil {
		parts = append(parts, s.Start.String())
	}

	if s.End != nil || s.Step != nil {
		parts = append(parts, ":")
		if s.End != nil {
			parts = append(parts, "<expr>")
		}
	}

	if s.Step != nil {
		parts = append(parts, ":")
		parts = append(parts, "<expr>")
	}

	parts = append(parts, "]")
	return strings.Join(parts, "")
}

// Path 返回名称的路径部分（除最后一部分外的点分连接）
func (n Name) Path() string {
	if len(n) <= 1 {
		return ""
	}
	parts := make([]string, len(n)-1)
	for i, part := range n[:len(n)-1] {
		if part.Slice != nil {
			parts[i] = part.Name + part.Slice.String()
		} else {
			parts[i] = part.Name
		}
	}
	return utils.ToNASMName(strings.Join(parts, "."))
}

// Last 返回名称的最后一部分的名称
func (n Name) Last() string {
	if len(n) == 0 {
		return ""
	}
	return n[len(n)-1].Name
}

// First 返回名称的第一部分的名称
func (n Name) First() string {
	if len(n) == 0 {
		return ""
	}
	parts := make([]string, len(n))
	i := 0
	for ; i < len(n); i++ {
		part := n[i]
		parts[i] = part.Name
		if !part.IsPkgPath {
			break
		}
	}
	return strings.Join(parts[:i+1], ".")
}

// IsPrivate 判断名称是否包含以下划线开头的私有部分
func (n Name) IsPrivate() bool {
	for _, part := range n {
		if part.Name != "" && part.Name[0] == '_' {
			return true
		}
	}
	return false
}

// Eq 判断两个名称是否完全相等
func (n Name) Eq(other Name) bool {
	if len(n) != len(other) {
		return false
	}
	for i := 0; i < len(n); i++ {
		if n[i].Name != other[i].Name {
			return false
		}
		// 检查切片指示器是否相等
		if n[i].Slice == nil && other[i].Slice != nil {
			return false
		}
		if n[i].Slice != nil && other[i].Slice == nil {
			return false
		}
	}
	return true
}

// Match 返回两个名称的公共前缀长度
func (n Name) Match(other Name) int {
	if len(n) == 0 || len(other) == 0 {
		return 0
	}
	for i := 0; i < len(n) && i < len(other); i++ {
		if n[i].Name != other[i].Name {
			return i - 1
		}
	}
	if len(n) == len(other) {
		return len(n)
	}
	return len(other)
}

// // IsEmpty 判断名称是否为空
func (n Name) IsEmpty() bool {
	return len(n) == 0
}

// IsPath 判断名称是否为多段路径
func (n Name) IsPath() bool {
	return len(n) > 1
}

// HasSlice 判断名称中任意位置是否存在切片指示器
func (n Name) HasSlice() bool {
	for _, part := range n {
		if part.Slice != nil {
			return true
		}
	}
	return false
}

// GetSlice 获取指定位置的切片指示器
func (n Name) GetSlice(index int) *NameSlice {
	if index < 0 || index >= len(n) {
		return nil
	}
	return n[index].Slice
}

// SetSlice 在指定位置设置切片指示器
func (n *Name) SetSlice(index int, start, end, step *Expression) {
	if index < 0 || index >= len(*n) {
		return
	}
	(*n)[index].Slice = &NameSlice{
		Start: start,
		End:   end,
		Step:  step,
	}
}

// Check 检查名称各部分是否均为有效标识符
func (n Name) Check() bool {
	ok := !n.IsEmpty()
	for _, part := range n {
		if part.Name != "" {
			ok = ok && utils.CheckName(part.Name)
		}
		if part.Name == "" {
			ok = ok && part.Slice != nil
		}
		if part.Slice != nil {
			ok = ok && part.Name == ""
		}
	}
	return ok
}

// ReadFromToken 从词法 Token 中读取名称部分
func (n *Name) ReadFromToken(t lexer.Token) bool {
	if t.Type == lexer.NAME {
		*n = append(*n, NamePart{Name: t.Value})
		return true
	}
	return false
}

// Fork 创建名称的深拷贝
func (n Name) Fork() Name {
	nn := make(Name, len(n))
	for i, part := range n {
		nn[i] = NamePart{
			Name:  part.Name,
			Slice: part.Slice, // 注意：这里是浅拷贝，如需深拷贝需要额外处理
		}
	}
	return nn
}

// FixPath 将名称的第一段替换为包导入的实际路径
func (n Name) FixPath(pkg *packageFmt.Info) bool {
	if !n.IsPath() {
		return false
	}
	importName := n[0].Name
	pkgRealPath := packageFmt.FixPathName(pkg.Imports[importName])
	n[0].Name = pkgRealPath
	n[0].IsPkgPath = true
	return true
}

// SetPkgPath 在名称前添加包路径前缀
func (n Name) SetPkgPath(pkgPath string) {
	newPart := NamePart{Name: packageFmt.FixPathName(pkgPath)}
	newPart.IsPkgPath = true
	n = append([]NamePart{newPart}, n...)
}

// Join 向名称追加更多段
func (n *Name) Join(other ...string) {
	for _, name := range other {
		*n = append(*n, NamePart{Name: name})
	}
}

// ForkJoin 创建名称拷贝后追加更多段
func (n Name) ForkJoin(other ...string) Name {
	nn := n.Fork()
	nn.Join(other...)
	return nn
}

// NewName 从字符串列表创建 Name
func NewName(parts ...string) Name {
	name := make(Name, len(parts))
	for i, part := range parts {
		name[i] = NamePart{Name: part}
	}
	return name
}

func (p *Parser) ParseName(wait bool) (name Name, cursor int) {
	if wait {
		// 等待名称
		for {
			oldCursor := p.Lexer.Cursor
			code := p.Lexer.Next()
			if code.IsEmpty() {
				// 语法错误：需要名称
				p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
			}
			if code.Value == "\n" || code.Value == "\r" || code.Value == ";" {
				// 语法错误：需要名称
				p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
			}
			if code.Type == lexer.NAME {
				// 退格，获取完整名称
				p.Lexer.SetCursor(oldCursor)
				break
			}
		}
	}

	// 记录名称起始位置
	cursor = p.Lexer.Cursor
	lastIsSep := true // 初始状态为分割符

	for {
		code := p.Lexer.Next()
		switch code.Type {
		case lexer.NAME:
			if !lastIsSep {
				p.Lexer.SetCursor(code.Cursor)
				goto end
			}
			lastIsSep = false
			name = append(name, NamePart{Name: code.Value})
		case lexer.SEPARATOR:
			if len(code.Value) != 1 || lastIsSep {
				p.Lexer.SetCursor(code.Cursor)
				goto end
			}
			switch code.Value {
			case ".":
			case "[":
				// Peek ahead: if next is "]", this is list type syntax, not a slice
				peek := p.Lexer.Next()
				if peek.Type == lexer.SEPARATOR && peek.Value == "]" {
					// This is []type (list type), not a name slice
					// Set cursor back to "[" so parseTypeAnnotation can handle it
					p.Lexer.SetCursor(code.Cursor)
					goto end
				}
				// For expression indices (like list[0], list[len(list)-1]), stop parsing name
				// and let ParseExp handle the index
				p.Lexer.SetCursor(code.Cursor)
				slice := p.parseNameSlice()
				if slice != nil {
					name = append(name, NamePart{Slice: slice})
				}
				goto end
			case "_":
				name[len(name)-1].Name += "_"
			default:
				p.Lexer.SetCursor(code.Cursor)
				goto end
			}
			lastIsSep = true
		default:
			p.Lexer.SetCursor(code.Cursor)
			goto end
		}
	}
end:
	// 对名称完整性检查
	if !name.Check() {
		// 语法错误：名称包含无效字符
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "name contains invalid characters")
	}
	return name, cursor
}

// parseNameSlice 解析名称中的切片部分 [start:end:step]
func (p *Parser) parseNameSlice() *NameSlice {
	token := p.Lexer.Next()
	if token.Type != lexer.SEPARATOR || token.Value != "[" {
		return nil
	}

	slice := &NameSlice{}
	state := 0 // 0=start, 1=end, 2=step
	bracketDepth := 1
	startCursor := p.Lexer.Cursor

	for bracketDepth > 0 {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected ']'")
			return nil
		}

		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case "[":
				bracketDepth++
				continue
			case "]":
				bracketDepth--
				if bracketDepth == 0 {
					// 解析最后一个表达式（如果有）
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							switch state {
							case 0:
								slice.Start = exp
							case 1:
								slice.End = exp
							case 2:
								slice.Step = exp
							}
						}
						p.Lexer.SetCursor(token.EndCursor)
					}
					return slice
				}
				continue
			case ":":
				if bracketDepth == 1 {
					// 解析 : 之前的表达式
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							switch state {
							case 0:
								slice.Start = exp
							case 1:
								slice.End = exp
							case 2:
								slice.Step = exp
							}
						}
						p.Lexer.SetCursor(token.EndCursor)
					}
					state++
					if state > 2 {
						p.Error.MissError("Expression Error", p.Lexer.Cursor, "too many ':' in index")
						return nil
					}
					startCursor = p.Lexer.Cursor
					continue
				}
			}
		}
	}

	return slice
}

// SetFirst 设置名称的第一个部分
func (n *Name) SetFirst(name Name) {
	// 设置名称的第一个部分, 如果是PkgPath就继续知道第一个不是PkgPath的部分
	if len(name) == 0 {
		return
	}

	// 分别找到两者First的截止位置
	firstEnd := 0
	for i := 0; i < len(*n); i++ {
		if !(*n)[i].IsPkgPath {
			firstEnd = i
			break
		}
	}
	newFirstEnd := 0
	for i := 0; i < len(name); i++ {
		if !name[i].IsPkgPath {
			newFirstEnd = i
			break
		}
	}
	*n = append((*n)[:firstEnd], name[:newFirstEnd]...)
}
