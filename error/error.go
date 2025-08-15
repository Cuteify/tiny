package errorUtil

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"strings"
	"unsafe"
)

type Error struct {
	Text     string
	Path     string
	LineFeed string
}

func (e *Error) GetErrPos(start int, end int) string {
	cursor := start
	tmp := unsafe.Slice(unsafe.StringData(e.Text), len(e.Text))
	lines := bytes.Split(tmp[:start], []byte(e.LineFeed))
	line := len(lines)
	if string(tmp[cursor]) == e.LineFeed[len(e.LineFeed)-1:] {
		line--
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
