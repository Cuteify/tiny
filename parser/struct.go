package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strings"
)

// FieldVisibility 字段可见性
type FieldVisibility int

const (
	Public    FieldVisibility = iota // 公共字段
	Private                          // 私有字段
	Protected                        // 受保护字段
)

// StructTag 结构体标签
type StructTag struct {
	Key   string
	Value string
}

// StructField 结构体字段
type StructField struct {
	Name         string          // 字段名称
	Type         typeSys.Type    // 字段类型
	DefaultValue *Expression     // 默认值
	Tags         []StructTag     // 标签
	Visibility   FieldVisibility // 可见性
	Offset       int             // 内存偏移
	Size         int             // 字段大小
	Alignment    int             // 对齐要求
	EndCursor    int             // 结束游标
	StartCursor  int             // 开始游标
}

// StructBlock 结构体定义
type StructBlock struct {
	Name        string         // 结构体名称
	Parents     []string       // 继承列表 : A + B
	Fields      []*StructField // 字段列表
	StartCursor int
	EndCursor   int
	Size        int // 结构体总大小
	Alignment   int // 对齐要求
}

// Parse 解析结构体
func (s *StructBlock) Parse(p *Parser) {
	// 解析结构体名称
	token := p.Lexer.Next()
	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "struct name required")
	}
	s.Name = token.Value

	// 验证结构体名称
	if !utils.CheckName(s.Name) {
		p.Error.MissError("Struct Error", token.Cursor, "invalid struct name: '"+s.Name+"'")
	}

	s.StartCursor = p.Lexer.Cursor

	// 检查是否有继承关系（冒号 : 表示继承）
	nextToken := p.Lexer.Next() // 获取下一个token
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == ":" {
		// 有继承关系，解析继承
		s.Parents = p.parseStructInheritance()
		// 解析完继承后，应该读取到"{"
		openBraceToken := p.Lexer.Next()
		if openBraceToken.Value != "{" {
			p.Error.MissError("Struct Error", openBraceToken.Cursor, "expected '{'")
		}
	} else {
		// 没有继承关系，检查是否是"{"
		if nextToken.Value != "{" {
			p.Error.MissError("Struct Error", nextToken.Cursor, "expected '{'")
		}
		// 游标已经在"{"位置，无需回退
	}

	// 解析字段
	p.parseStructFields(s)

	// 计算内存布局
	s.CalculateMemoryLayout()
}

// parseStructInheritance 解析结构体继承关系
func (p *Parser) parseStructInheritance() []string {
	var parents []string

	// 解析第一个父类
	token := p.Lexer.Next()
	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
	}
	parents = append(parents, token.Value)

	// 只允许用 + 分隔多个父类
	for {
		token = p.Lexer.Next()
		if token.Value != "+" {
			p.Lexer.SetCursor(token.Cursor)
			break
		}

		token = p.Lexer.Next()
		if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
			p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
		}
		parents = append(parents, token.Value)
	}

	return parents
}

// parseStructFields 解析结构体字段
func (p *Parser) parseStructFields(s *StructBlock) {
	// 解析字段直到 }
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct")
		}

		if token.Value == "}" {
			s.EndCursor = token.Cursor
			break
		}

		// 跳过分隔符（空格、换行等）
		if token.Type == lexer.SEPARATOR {
			continue
		}

		// 如果是可见性修饰符
		var visibility FieldVisibility = Public // 默认公共
		var fieldStartToken lexer.Token         // 用于存储字段名token

		if token.Type == lexer.NAME {
			vis := p.parseFieldVisibility(token)
			if vis != -1 {
				visibility = vis
				// 如果是可见性修饰符，获取下一个token作为字段名
				fieldStartToken = p.Lexer.Next()
			} else {
				// 不是可见性修饰符，这个token就是字段名
				fieldStartToken = token
			}
		} else {
			// 不是可见性修饰符，这个token就是字段名
			fieldStartToken = token
		}

		// 设置游标到字段名位置
		p.Lexer.SetCursor(fieldStartToken.Cursor)
		// 解析字段
		field := p.parseStructField()
		if field != nil {
			field.Visibility = visibility
			s.Fields = append(s.Fields, field)
		}
	}
}

// parseStructField 解析单个结构体字段
func (p *Parser) parseStructField() *StructField {
	field := &StructField{}
	field.StartCursor = p.Lexer.Cursor

	// 解析字段名称
	token := p.Lexer.Next()
	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "field name required")
	}
	field.Name = token.Value

	// 验证字段名称
	if !utils.CheckName(field.Name) {
		p.Error.MissError("Struct Error", token.Cursor, "invalid field name: '"+field.Name+"'")
	}

	// 期望 :
	token = p.Lexer.Next()
	if token.Value != ":" {
		p.Error.MissError("Struct Error", token.Cursor, "expected ':' after field name")
	}

	// 解析类型（简单实现：只支持基本类型）
	typeToken := p.Lexer.Next()
	if typeToken.Type != lexer.NAME && typeToken.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", typeToken.Cursor, "field type required")
	}
	field.Type = p.findType(typeToken.Value)

	// 检查是否有标签或默认值
	nextToken := p.Lexer.Next()
	switch nextToken.Value {
	case "`": // 标签
		p.Lexer.SetCursor(nextToken.Cursor) // 回退，让标签解析函数处理
		field.Tags = p.parseStructTags()

		// 检查是否有默认值
		nextToken = p.Lexer.Next()
		if nextToken.Value == "=" {
			field.DefaultValue = p.ParseExpression(p.FindEndCursor())
		} else {
			p.Lexer.SetCursor(nextToken.Cursor) // 回退
		}
	case "=": // 默认值
		field.DefaultValue = p.ParseExpression(p.FindEndCursor())
	case ";", "\n", "}": // 字段结束
		p.Lexer.SetCursor(nextToken.Cursor) // 回退
		return field
	default:
		p.Lexer.SetCursor(nextToken.Cursor) // 回退
		return field
	}

	return field
}

// parseFieldVisibility 解析字段可见性
func (p *Parser) parseFieldVisibility(token lexer.Token) FieldVisibility {
	switch token.Value {
	case "pub":
		return Public
	case "priv":
		return Private
	case "prot":
		return Protected
	default:
		return -1 // 不是可见性修饰符
	}
}

// parseStructTags 解析结构体标签
func (p *Parser) parseStructTags() []StructTag {
	var tags []StructTag

	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "expected '`' to close tags")
		}

		if token.Value == "`" {
			break
		}

		// 解析 key:value
		if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
			p.Error.MissError("Struct Error", token.Cursor, "tag key required")
		}
		key := token.Value

		// 期望 :
		token = p.Lexer.Next()
		if token.Value != ":" {
			p.Error.MissError("Struct Error", token.Cursor, "expected ':' after tag key")
		}

		// 解析 value（字符串或标识符）
		token = p.Lexer.Next()
		if token.Type == lexer.STRING {
			value := strings.Trim(token.Value, "\"")
			tags = append(tags, StructTag{Key: key, Value: value})
		} else if token.Type == lexer.NAME || token.Type == lexer.IDENTIFIER {
			tags = append(tags, StructTag{Key: key, Value: token.Value})
		} else {
			p.Error.MissError("Struct Error", token.Cursor, "tag value required")
		}
	}

	return tags
}

// findType 查找类型
func (p *Parser) findType(typeName string) typeSys.Type {
	switch typeName {
	case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte":
		return typeSys.GetSystemType(typeName)
	default:
		// TODO: 支持自定义类型
		return typeSys.GetSystemType("int")
	}
}

// CalculateMemoryLayout 计算结构体的内存布局
func (s *StructBlock) CalculateMemoryLayout() {
	offset := 0
	maxAlignment := 1

	for _, field := range s.Fields {
		var alignment int
		if field.Type != nil {
			size := field.Type.Size()
			if size == 0 {
				alignment = 1 // 防止除零错误
			} else {
				alignment = size
			}
		} else {
			alignment = 1 // 默认对齐
		}
		field.Alignment = alignment
		if field.Alignment > maxAlignment {
			maxAlignment = field.Alignment
		}

		// 对齐偏移
		if field.Alignment > 0 {
			padding := (field.Alignment - (offset % field.Alignment)) % field.Alignment
			offset += padding
		}
		field.Offset = offset

		// 更新偏移量
		if field.Type != nil {
			field.Size = field.Type.Size()
			if field.Size == 0 {
				field.Size = 1 // 防止大小为0
			}
		} else {
			field.Size = 1 // 默认大小
		}
		offset += field.Size
		typeStr := ""
		if field.Type != nil {
			typeStr = field.Type.Type()
		} else {
			typeStr = "unknown" // 默认类型字符串
		}
		field.EndCursor = field.StartCursor + len(field.Name) + len(typeStr) + 5 // rough estimation
	}

	s.Size = offset
	s.Alignment = maxAlignment
}

// GetFieldByName 根据名称获取字段
func (s *StructBlock) GetFieldByName(name string) *StructField {
	for _, field := range s.Fields {
		if field.Name == name {
			return field
		}
	}
	return nil
}

// HasField 检查结构体是否包含特定字段
func (s *StructBlock) HasField(name string) bool {
	return s.GetFieldByName(name) != nil
}

// GetPublicFields 获取所有公共字段
func (s *StructBlock) GetPublicFields() []*StructField {
	var publicFields []*StructField
	for _, field := range s.Fields {
		if field.Visibility == Public {
			publicFields = append(publicFields, field)
		}
	}
	return publicFields
}

// GetPrivateFields 获取所有私有字段
func (s *StructBlock) GetPrivateFields() []*StructField {
	var privateFields []*StructField
	for _, field := range s.Fields {
		if field.Visibility == Private {
			privateFields = append(privateFields, field)
		}
	}
	return privateFields
}

// GetSize 获取结构体大小
func (s *StructBlock) GetSize() int {
	return s.Size
}

// GetAlignment 获取对齐要求
func (s *StructBlock) GetAlignment() int {
	return s.Alignment
}
