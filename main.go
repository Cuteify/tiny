package main

import (
	"cuteify/compile"
	"cuteify/compile/gc"
	packageSys "cuteify/package"
	"cuteify/parser"
	"flag"
	"fmt"
	"os"
	"reflect"
	"strings"
	"time"
)

func main() {
	startTime := time.Now()

	// 定义命令行参数
	genAST := flag.Bool("ast", false, "生成 AST 文本表示")
	gcDump := flag.Bool("gc-dump", false, "输出 GC 函数摘要")
	asmOnly := flag.Bool("S", false, "仅编译生成汇编文件，不进行汇编和链接")
	asmOnlyLong := flag.Bool("asm", false, "仅编译生成汇编文件（同 -S）")
	objOnly := flag.Bool("c", false, "编译并汇编生成目标文件，不进行链接")
	objOnlyLong := flag.Bool("obj", false, "编译并汇编生成目标文件（同 -c）")
	output := flag.String("o", "", "指定输出文件路径")
	flag.Parse()

	// 获取路径参数
	path := "./test"
	if flag.NArg() > 0 {
		path = flag.Arg(0)
	}

	tmp, err := packageSys.GetPackage(path, true)
	if err != nil {
		panic(err)
	}

	// GC 摘要分析：包合并 + Check 重试完成后、代码生成之前执行
	gc.Build(tmp.AST.(*parser.Node))
	if *gcDump {
		fmt.Println("\n=== GC 函数摘要 ===")
		if err := gc.DumpAll(os.Stdout); err != nil {
			panic(err)
		}
		fmt.Println("\n=== GC 出口释放计划 ===")
		fmt.Print(gc.DumpFrees())
		fmt.Println("\n=== GC LLR 分析 ===")
		fmt.Print(gc.DumpLLRs())
	}

	// AST 模式
	if *genAST {
		fmt.Println("\n=== Text AST ===")
		pr(tmp.AST.(*parser.Node), 0)
		return
	}

	// 编译
	co := &compile.Compiler{}
	code := co.Compile(tmp.AST.(*parser.Node))

	// 获取当前工作目录
	workDir, err := os.Getwd()
	if err != nil {
		panic(err)
	}

	// 确定输出模式
	genAsm := *asmOnly || *asmOnlyLong
	genObj := *objOnly || *objOnlyLong

	var asmPath string
	if *output != "" {
		asmPath = *output
	} else if genAsm {
		asmPath = workDir + "/_main.asm"
	} else if genObj {
		asmPath = workDir + "/_main.o"
	} else {
		asmPath = workDir + "/_main.asm"
	}

	// 汇编模式：直接输出汇编文件
	if genAsm {
		os.WriteFile(asmPath, []byte(code), 0644)
		fmt.Println("\033[32mOK\033[0m: Compile completed in", time.Since(startTime))
		fmt.Println("\033[32mOK\033[0m: Generated assembly file", asmPath)
		return
	}

	// 目标文件模式：编译 + 汇编（需要 nasm）
	if genObj {
		// 先写临时汇编文件
		tmpAsm := workDir + "/_tmp.asm"
		os.WriteFile(tmpAsm, []byte(code), 0644)

		// 使用 nasm 汇编
		objFormat := "elf32" // 默认 x86 32位 ELF
		//  TODO: 根据架构选择不同的格式
		cmd := fmt.Sprintf("nasm -f %s -o %s %s", objFormat, asmPath, tmpAsm)
		fmt.Println("Running:", cmd)
		//  TODO: 实际执行汇编命令

		os.Remove(tmpAsm)
		fmt.Println("\033[32mOK\033[0m: Compile + assemble completed in", time.Since(startTime))
		fmt.Println("\033[32mOK\033[0m: Generated object file", asmPath)
		return
	}

	// 默认模式：完整编译（当前只到汇编）
	os.WriteFile(asmPath, []byte(code), 0644)
	fmt.Println("\033[32mOK\033[0m: Compile completed in", time.Since(startTime))
	fmt.Println("\033[32mOK\033[0m: Generated", asmPath)
}

func pr(block *parser.Node, tabnum int) {
	/*if block.Ignore {
		return
	}*/
	fmt.Println(strings.Repeat("\t", tabnum), reflect.TypeOf(block.Value), block.Value)
	/*TODO：
	if sb, ok := block.Value.(*parser.StructBlock); ok {
		fmt.Printf("\n=== Struct: %s ===\n", sb.Name)
		fmt.Println("Fields:")
		for _, f := range sb.Fields {
			accessStr := "public"
			if f.Access == parser.AccessReadOnly {
				accessStr = "readonly"
			} else if f.Access == parser.AccessWriteOnly {
				accessStr = "writeonly"
			} else if f.Access == parser.AccessPrivate {
				accessStr = "private"
			}
			defaultStr := ""
			if f.DefaultValue != nil {
				defaultStr = fmt.Sprintf(" (default: %v)", f.DefaultValue)
			}
			tagStr := ""
			if len(f.Tags) > 0 {
				var tagParts []string
				for _, t := range f.Tags {
					tagParts = append(tagParts, t.Key+":"+t.Value)
				}
				tagStr = fmt.Sprintf(" (tags: %v)", tagParts)
			}
			fmt.Printf("  - %s: %v (access: %s)%s%s\n", f.Name, f.Type, accessStr, defaultStr, tagStr)
		}
		fmt.Println("Methods:")
		for _, m := range sb.Methods {
			fmt.Printf("  - %s\n", m.Name.String())
		}
		fmt.Println("=====================\n")
	}*/

	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}
