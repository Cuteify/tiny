# 结构体处理实现计划（修订版 v4）

## 概述

本计划基于现有架构设计，结构体在解析阶段已生成 AST，在 Check 阶段进行后填充和类型检查。

---

## 发现的问题

### 问题 1：结构体没有添加到 AST

**文件**: `parser/parser.go`

**位置**: `processTypeToken` 方法

**修复**:
```go
case "struct":
    block := &StructBlock{}
    block.Parse(p)
    p.AddChild(&Node{Value: block})
```

### 问题 2：`findType` 不支持结构体类型

**文件**: `parser/struct.go`

需要修改 `findType` 支持结构体类型作为字段类型。

### 问题 3：没有 `Check` 方法

**文件**: `parser/struct.go`

`StructBlock` 需要添加 `Check` 方法和 `Checked` 字段。

### 问题 4：可见性和访问控制处理错误

**文件**: `parser/struct.go`

**现状**: 使用 `pub`, `priv`, `prot` 关键字修饰可见性（错误）

**正确规则**:

使用前缀符号控制字段的可见性和访问权限：

| 前缀 | 名称 | 可见性 | 读权限 | 写权限 |
|------|------|--------|--------|--------|
| 无前缀 | 公开 | 公开 | ✅ 外部可读 | ✅ 外部可写 |
| `_` 开头 | 私有 | 私有 | ❌ 不可访问 | ❌ 不可访问 |
| `!` 开头 | 保护 | 公开 | ✅ 外部可读 | ❌ 仅内部可写 |
| `?` 开头 | 只写 | 公开 | ❌ 不可读 | ✅ 外部可写 |

**示例**:
```tiny
struct User {
    name: string        // 公开可读写
    _password: string   // 私有（不可访问）
    !createdAt: int     // 保护（外部只读，内部可写）
    ?secretKey: string  // 只写（外部可写，不可读）
}
```

**说明**:
- `_` 前缀：私有字段，外部完全不可访问
- `!` 前缀：保护字段，外部可读但不可写（适合创建时间、ID等）
- `?` 前缀：只写字段，外部可写但不可读（适合密码、哈希等敏感数据）

---

## 实现步骤

### 第一步：修复 AST 添加

**文件**: `parser/parser.go`

```go
func (p *Parser) processTypeToken(code lexer.Token) {
    switch code.Value {
    case "struct":
        block := &StructBlock{}
        block.Parse(p)
        p.AddChild(&Node{Value: block})
    case "interface":
        block := &InterfaceBlock{}
        block.Parse(p)
        p.AddChild(&Node{Value: block})
    default:
        p.processDefaultToken(code)
    }
}
```

### 第二步：添加 `FindStruct` 方法

**文件**: `parser/parser.go`

```go
func (p *Parser) FindStruct(name string) *StructBlock {
    for _, child := range p.Block.Children {
        if sb, ok := child.Value.(*StructBlock); ok {
            if sb.Name == name {
                return sb
            }
        }
    }
    return nil
}
```

### 第三步：修改 `StructField` 和 `StructBlock`

**文件**: `parser/struct.go`

删除 `FieldVisibility` 常量和 `Visibility` 字段，添加访问控制字段：

```go
type FieldAccess int

const (
    AccessPublic FieldAccess = iota
    AccessPrivate
    AccessReadOnly
    AccessWriteOnly
)

type StructField struct {
    Name         string
    Type         typeSys.Type
    DefaultValue *Expression
    Tags         []StructTag
    Offset       int
    Size         int
    Alignment    int
    EndCursor    int
    StartCursor  int
    Access       FieldAccess
}

type StructBlock struct {
    Name        string
    Parents     []string
    Fields      []*StructField
    StartCursor int
    EndCursor   int
    Size        int
    Alignment   int
    Checked     bool
}

func (f *StructField) IsPrivate() bool {
    return f.Access == AccessPrivate
}

func (f *StructField) IsReadOnly() bool {
    return f.Access == AccessReadOnly
}

func (f *StructField) IsWriteOnly() bool {
    return f.Access == AccessWriteOnly
}

func (f *StructField) IsPublic() bool {
    return f.Access == AccessPublic
}

func (f *StructField) CanRead() bool {
    return f.Access == AccessPublic || f.Access == AccessReadOnly
}

func (f *StructField) CanWrite() bool {
    return f.Access == AccessPublic || f.Access == AccessWriteOnly
}
```

### 第四步：修改 `parseStructFields`

**文件**: `parser/struct.go`

```go
func (p *Parser) parseStructFields(s *StructBlock) {
    for {
        token := p.Lexer.Next()
        if token.IsEmpty() {
            p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct")
        }

        if token.Value == "}" {
            s.EndCursor = token.Cursor
            break
        }

        if token.Type == lexer.SEPARATOR {
            continue
        }

        p.Lexer.SetCursor(token.Cursor)
        field := p.parseStructField()
        if field != nil {
            s.Fields = append(s.Fields, field)
        }
    }
}
```

### 第五步：修改 `parseStructField`

**文件**: `parser/struct.go`

**重要说明**：
- `_` 下划线是字段名的一部分（如 `_password` 就是完整字段名）
- `!` 和 `?` 是访问控制标记，不属于字段名（如 `!createdAt` 的字段名是 `createdAt`）

解析流程：
1. 先检查第一个字符是否为 `!` 或 `?`
2. 如果是，记录访问控制类型，然后继续解析字段名
3. 如果不是，退格后使用 Name 函数解析完整字段名

```go
func (p *Parser) parseStructField() *StructField {
    field := &StructField{Access: AccessPublic}
    field.StartCursor = p.Lexer.Cursor

    token := p.Lexer.Next()
    
    if token.Type == lexer.SEPARATOR {
        switch token.Value {
        case "!":
            field.Access = AccessReadOnly
            token = p.Lexer.Next()
        case "?":
            field.Access = AccessWriteOnly
            token = p.Lexer.Next()
        }
    }
    
    if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
        p.Error.MissError("Struct Error", token.Cursor, "field name required")
    }
    
    p.Lexer.SetCursor(token.Cursor)
    name, _ := p.Name(false)
    fieldName := name.String()
    
    if !utils.CheckName(fieldName) {
        p.Error.MissError("Struct Error", token.Cursor, "invalid field name: '"+fieldName+"'")
    }
    
    field.Name = fieldName
    
    if len(fieldName) > 0 && fieldName[0] == '_' {
        field.Access = AccessPrivate
    }
    
    token = p.Lexer.Next()
    if token.Value != ":" {
        p.Error.MissError("Struct Error", token.Cursor, "expected ':' after field name")
    }

    typeToken := p.Lexer.Next()
    if typeToken.Type != lexer.NAME && typeToken.Type != lexer.IDENTIFIER {
        p.Error.MissError("Struct Error", typeToken.Cursor, "field type required")
    }
    field.Type = p.findType(typeToken.Value)

    nextToken := p.Lexer.Next()
    switch nextToken.Value {
    case "`":
        p.Lexer.SetCursor(nextToken.Cursor)
        field.Tags = p.parseStructTags()
        nextToken = p.Lexer.Next()
        if nextToken.Value == "=" {
            field.DefaultValue = p.ParseExpression(p.FindEndCursor())
        } else {
            p.Lexer.SetCursor(nextToken.Cursor)
        }
    case "=":
        field.DefaultValue = p.ParseExpression(p.FindEndCursor())
    case ";", "\n", "}":
        p.Lexer.SetCursor(nextToken.Cursor)
        return field
    default:
        p.Lexer.SetCursor(nextToken.Cursor)
        return field
    }

    return field
}
```

### 第六步：删除 `parseFieldVisibility` 和 `parseFieldAccess`

**文件**: `parser/struct.go`

删除这两个方法，不再需要。访问控制在 `parseStructField` 中直接处理。

### 第七步：添加 `Check` 方法

**文件**: `parser/struct.go`

```go
func (s *StructBlock) Check(p *Parser) bool {
    if s.Checked {
        return true
    }
    s.Checked = true
    
    if len(s.Parents) > 0 {
        s.processInheritance(p)
    }
    
    s.CalculateMemoryLayout()
    return true
}

func (s *StructBlock) processInheritance(p *Parser) {
    var inheritedFields []*StructField
    
    for _, parentName := range s.Parents {
        parent := p.FindStruct(parentName)
        if parent == nil {
            p.Error.MissError("Struct Error", s.StartCursor, 
                "parent struct '"+parentName+"' not found")
            continue
        }
        parent.Check(p)
        for _, field := range parent.Fields {
            newField := &StructField{
                Name:   field.Name,
                Type:   field.Type,
                Tags:   field.Tags,
                Access: field.Access,
            }
            inheritedFields = append(inheritedFields, newField)
        }
    }
    s.Fields = append(inheritedFields, s.Fields...)
}
```

### 第八步：修改 `Node.Check`

**文件**: `parser/node.go`

```go
case *StructBlock:
    structBlock := n.Value.(*StructBlock)
    return structBlock.Check(n.Parser)
```

### 第九步：修改 `findType`

**文件**: `parser/struct.go`

```go
func (p *Parser) findType(typeName string) typeSys.Type {
    switch typeName {
    case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte",
         "i32", "u32", "f32", "i16", "u16", "i8", "u8":
        return typeSys.GetSystemType(typeName)
    default:
        if sb := p.FindStruct(typeName); sb != nil {
            return createStructType(sb)
        }
        return typeSys.GetSystemType("int")
    }
}

func createStructType(sb *StructBlock) typeSys.Type {
    return &typeSys.StructType{
        RType: typeSys.RType{
            TypeName: sb.Name,
            RSize:    sb.Size,
        },
        StructFields: convertStructFields(sb.Fields),
    }
}

func convertStructFields(fields []*StructField) typeSys.StructFileds {
    var result typeSys.StructFileds
    for _, f := range fields {
        result = append(result, &typeSys.StructField{
            Name:   f.Name,
            Type:   f.Type,
            Offset: f.Offset,
        })
    }
    return result
}
```

### 第十步：完善 `checkFieldAccess`

**文件**: `parser/exp.go`

```go
func (exp *Expression) checkFieldAccess(p *Parser, left, right *Expression) bool {
    left.Check(p)
    
    if left.Type == nil {
        p.Error.MissError("Field access error", p.Lexer.Cursor, 
            "left operand of '.' must have a type")
        return false
    }
    
    structName := left.Type.Type()
    structBlock := p.FindStruct(structName)
    if structBlock == nil {
        p.Error.MissError("Field access error", p.Lexer.Cursor, 
            "type '"+structName+"' is not a struct")
        return false
    }
    
    structBlock.Check(p)
    
    if right.Var == nil {
        p.Error.MissError("Field access error", p.Lexer.Cursor, 
            "right operand of '.' must be a field name")
        return false
    }
    
    fieldName := right.Var.Name.String()
    field := structBlock.GetFieldByName(fieldName)
    if field == nil {
        p.Error.MissError("Field access error", p.Lexer.Cursor, 
            "struct '"+structName+"' has no field '"+fieldName+"'")
        return false
    }
    
    if field.IsPrivate() {
        p.Error.MissError("Field access error", p.Lexer.Cursor, 
            "field '"+fieldName+"' is private")
        return false
    }
    
    exp.Type = field.Type
    exp.Field = right
    exp.checked = true
    return true
}
```

### 第十一步：实现 `compileStructBlock`

**文件**: `compile/compiler.go`

```go
func (c *Compiler) compileStructBlock(n *parser.Node) string {
    structBlock := n.Value.(*parser.StructBlock)
    c.Ctx.AddStruct(structBlock)
    return ""
}
```

### 第十二步：添加字段访问编译

**文件**: `compile/arch/x86/exp.go`

在 `CompileExprVal` 中添加:
```go
if exp.Field != nil {
    return c.compileFieldAccess(exp)
}
```

添加方法:
```go
func (c *expCom) compileFieldAccess(exp *parser.Expression) (code, result string) {
    structName := exp.Left.Type.Type()
    structBlock, _ := c.ctx.GetStruct(structName)
    
    fieldName := exp.Field.Var.Name.String()
    field := structBlock.GetFieldByName(fieldName)
    
    var objAddr string
    if exp.Left.Var != nil {
        objAddr = genVarAddr(c.ctx, exp.Left.Var)
    }
    
    sizePrefix := GetLengthName(field.Size)
    result = fmt.Sprintf("%s [%s + %d]", sizePrefix, objAddr, field.Offset)
    return
}
```

---

## 文件修改清单

| 文件 | 修改内容 |
|------|----------|
| `parser/parser.go` | 添加 `FindStruct`，修复 `processTypeToken` |
| `parser/struct.go` | 添加 `FieldAccess`、修改 `StructField`、添加 `parseFieldAccess`、`Check` 方法 |
| `parser/node.go` | 添加 `StructBlock` case |
| `parser/exp.go` | 完善 `checkFieldAccess` |
| `compile/compiler.go` | 实现 `compileStructBlock` |
| `compile/arch/x86/exp.go` | 添加字段访问编译 |

---

## 测试用例

```tiny
struct User {
    name: string
    age: int
    _password: string
    !createdAt: int
    ?secretKey: string
}

struct Point {
    x: int
    y: int
}

struct ColorPoint : Point {
    color: int
}

fn main() {
    var u: User
    u.name = "test"
    u.age = 20
    var name: string = u.name
    var created: int = u.createdAt
    
    var p: Point
    p.x = 10
    p.y = 20
    
    var cp: ColorPoint
    cp.x = 1
    cp.y = 2
    cp.color = 255
    
    var sum: int = p.x + p.y
}
```
