package errorUtil

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"strings"
	"unsafe"
)

var Errors = map[string]*Error{}

func NewError(path string, text string, linefeed string) *Error {
	err := &Error{
		Text:     text,
		Path:     path,
		LineFeed: linefeed,
	}
	Errors[path] = err
	return err
}

type Error struct {
	Text     string
	Path     string
	LineFeed string
}

func (e *Error) GetErrPos(start int, end int) string {
	if start < 0 || start >= len(e.Text) {
		start = 0 // 默认从开始位置
		end = start + 1
		if end > len(e.Text) {
			end = len(e.Text)
		}
	}

	cursor := start
	tmp := unsafe.Slice(unsafe.StringData(e.Text), len(e.Text))
	lines := bytes.Split(tmp[:start], []byte(e.LineFeed))
	line := len(lines)

	// 修复边界情况
	if len(lines) == 0 {
		// 如果没有分割出任何行，说明在第1行
		line = 1
		// 找到整个文本的第一行
		allLines := bytes.Split(tmp, []byte(e.LineFeed))
		if len(allLines) > 0 {
			var beforeLastLine []byte = allLines[0]
			if len(allLines) > 1 && start >= len(allLines[0])+1 && string(tmp[start]) == e.LineFeed[len(e.LineFeed)-1:] {
				// 如果当前字符是换行符，且在行尾
				line = 1 // 这种情况需要特殊处理
			}
			col := start // 在第一行中的列位置
			if start > len(beforeLastLine) {
				col = len(beforeLastLine)
			}
			lineText := beforeLastLine
			if len(bytes.Split(tmp[start:], []byte(e.LineFeed))) > 0 {
				lineText = append(beforeLastLine, bytes.Split(tmp[start:], []byte(e.LineFeed))[0]...)
			}
			text := strconv.Itoa(line) + " | " + strings.TrimLeft(string(lineText), " \n\r\t") + "\n"
			for i := 0; i < len(strconv.Itoa(line)+" | "+strings.TrimLeft(string(beforeLastLine)[:col], " \n\r\t"))-1; i++ {
				text += "—"
			}
			text += "\033[31m"
			for i := 0; i < end-start; i++ {
				text += "^"
			}
			text += "\033[0m"
			text += "\n" + e.Path + ":" + strconv.Itoa(line) + ":" + strconv.Itoa(col) + ":\n"
			return text
		}
	}

	// 原来的逻辑，但现在要检查边界
	if string(tmp[cursor]) == e.LineFeed[len(e.LineFeed)-1:] {
		line--
	}

	// 确保line不小于1
	if line <= 0 {
		line = 1
	}

	// 检查lines[line-1]是否存在
	if line > len(lines) {
		line = len(lines)
	}

	if line <= 0 || line > len(lines) {
		// 如果仍然超出范围，使用整个文本的第一行
		allLines := bytes.Split(tmp, []byte(e.LineFeed))
		var beforeLastLine []byte
		if len(allLines) > 0 {
			beforeLastLine = allLines[0]
		} else {
			beforeLastLine = []byte("")
		}
		col := 0
		if start < len(beforeLastLine) {
			col = start
		} else {
			col = len(beforeLastLine)
		}
		lineText := beforeLastLine
		remainingLines := bytes.Split(tmp[start:], []byte(e.LineFeed))
		if len(remainingLines) > 0 {
			lineText = append(beforeLastLine, remainingLines[0]...)
		}
		text := strconv.Itoa(1) + " | " + strings.TrimLeft(string(lineText), " \n\r\t") + "\n"
		for i := 0; i < len("1 | "+strings.TrimLeft(string(beforeLastLine)[:col], " \n\r\t")); i++ {
			text += "—"
		}
		text += "\033[31m"
		for i := 0; i < end-start; i++ {
			text += "^"
		}
		text += "\033[0m"
		text += "\n" + e.Path + ":" + strconv.Itoa(1) + ":" + strconv.Itoa(col) + ":\n"
		return text
	}

	beforeLastLine := lines[line-1]
	col := len(beforeLastLine)
	lineText := beforeLastLine
	lineText = append(lineText, bytes.Split(tmp[start:], []byte(e.LineFeed))[0]...)
	text := strconv.Itoa(line) + " | " + strings.TrimLeft(string(lineText), " \n\r\t") + "\n"
	for i := 0; i < len(strconv.Itoa(line)+" | "+strings.TrimLeft(string(beforeLastLine), " \n\r\t"))-1; i++ {
		text += "—"
	}
	if string(tmp[cursor]) == e.LineFeed[len(e.LineFeed)-1:] {
		text += "—"
		col++
	}
	text += "\033[31m"
	for i := 0; i < end-start; i++ {
		text += "^"
	}
	text += "\033[0m"
	text += "\n" + e.Path + ":" + strconv.Itoa(line) + ":" + strconv.Itoa(col) + ":\n"
	return text
}

func (e *Error) MissError(errType string, cursor int, msg string) {
	fmt.Println(e.GetErrPos(cursor, cursor+1) + "\033[31m" + errType + ":\033[0m " + msg)
	panic("")
	os.Exit(1)
}

func (e *Error) MissErrors(errType string, start int, end int, msg string) {
	fmt.Println(e.GetErrPos(start, end) + "\033[31m" + errType + ":\033[0m " + msg)
	panic("")
	os.Exit(1)
}

func (e *Error) STOP() {
	e.MissError("Unknow Error", 0, "Stop")
}

func (e *Error) Warning(msg string) {
	fmt.Println("\033[33mWarning:\033[0m " + msg)
}
