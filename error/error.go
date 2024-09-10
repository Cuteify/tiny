package errorUtil

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

type Error struct {
	File     *os.File
	LineFeed string
}

func (e *Error) GetErrPos(start int, end int) string {
	wd, err := os.Getwd()
	if err != nil {
		wd = "."
	}
	filename := filepath.Join(wd, e.File.Name())
	e.File.Seek(0, io.SeekStart)
	cursor := start
	tmp := []byte{}
	if tmp, err = io.ReadAll(e.File); err != nil {
		panic(err)
	}
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
	text += "\n" + filename + ":" + strconv.Itoa(line) + ":" + strconv.Itoa(col) + ":\n"
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