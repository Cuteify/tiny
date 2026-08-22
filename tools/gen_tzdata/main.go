// gen_tzdata：从 IANA tzdata 编译的 TZif 文件生成 cuteify 时区数据。
//
// 用法：
//   1. 下载并编译最新 tzdata（示例，zic 版本需与 tzdata 匹配）：
//        curl -sL -o tzdata.tar.gz https://data.iana.org/time-zones/releases/tzdata2026c.tar.gz
//        mkdir -p zoneinfo && cd zoneinfo && tar xzf ../tzdata.tar.gz && cd ..
//        zic -d zoneinfo asia europe etcetera australasia africa northamerica southamerica backward
//   2. go run ./tools/gen_tzdata -dir /tmp/opencode/tzwork/zoneinfo -out pkg/time/tzdata.cute
//
// TZif 中例行 DST 转换被压缩到文件尾部的 POSIX TZ 字符串（如 "EST5EDT,M3.2.0,M11.1.0"），
// 本工具解析该字符串并把例行转换展开到 2037 年底，与显式 transition 表合并输出。
package main

import (
	"encoding/binary"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var zones = []string{
	"UTC",
	"Asia/Shanghai",
	"Asia/Hong_Kong",
	"Asia/Taipei",
	"Asia/Tokyo",
	"Asia/Seoul",
	"Asia/Singapore",
	"Asia/Kolkata",
	"Asia/Dubai",
	"Europe/London",
	"Europe/Paris",
	"Europe/Moscow",
	"Europe/Berlin",
	"America/New_York",
	"America/Chicago",
	"America/Denver",
	"America/Los_Angeles",
	"America/Sao_Paulo",
	"Australia/Sydney",
}

// transition 是 TZif 中的一个时间变更点。
type transition struct {
	time   int64
	offset int32
	abbr   string
}

// parseTZif 解析 TZif v2/v3 格式，返回 64 位数据块中的显式 transition 表。
func parseTZif(path string) ([]transition, string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, "", err
	}
	if len(data) < 44 || string(data[:4]) != "TZif" {
		return nil, "", fmt.Errorf("%s: not a TZif file", path)
	}
	countsOff := 20
	cnt := func(o int) int { return int(binary.BigEndian.Uint32(data[o:])) }
	leapcnt := cnt(countsOff + 8)
	timecnt := cnt(countsOff + 12)
	typecnt := cnt(countsOff + 16)
	charcnt := cnt(countsOff + 20)

	// 跳过 v1（32 位）数据块
	off := countsOff + 24
	off += timecnt*4 + timecnt + typecnt*6 + charcnt + leapcnt*8

	// v2+ 头（magic 在 off），6 个计数位于头后 20 字节
	if off+44 > len(data) {
		return nil, "", fmt.Errorf("%s: no 64-bit block", path)
	}
	timecnt = cnt(off + 20 + 12)
	typecnt = cnt(off + 20 + 16)
	charcnt = cnt(off + 20 + 20)
	off += 44

	times := make([]int64, timecnt)
	for i := 0; i < timecnt; i++ {
		times[i] = int64(binary.BigEndian.Uint64(data[off:]))
		off += 8
	}
	typeIdx := make([]int, timecnt)
	for i := 0; i < timecnt; i++ {
		typeIdx[i] = int(data[off])
		off++
	}
	var toff []int32
	var tabbr []int
	for i := 0; i < typecnt; i++ {
		toff = append(toff, int32(binary.BigEndian.Uint32(data[off:])))
		tabbr = append(tabbr, int(data[off+5])) // 6 字节 ttinfo: utoff(4)+isdst(1)+abbrind(1)
		off += 6
	}
	abbr := string(data[off : off+charcnt])
	off += charcnt
	posix := readPOSIX(data)

	var out []transition
	for i := 0; i < timecnt; i++ {
		ti := typeIdx[i]
		if ti >= typecnt {
			continue
		}
		a := abbr[tabbr[ti]:]
		if j := strings.IndexByte(a, 0); j >= 0 {
			a = a[:j]
		}
		out = append(out, transition{time: times[i], offset: toff[ti], abbr: a})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].time < out[j].time })
	return out, posix, nil
}

// readPOSIX 从文件末尾提取 POSIX TZ 字符串（zic 输出以 \nPOSIX串\n 结尾）。
func readPOSIX(data []byte) string {
	s := string(data)
	if i := strings.LastIndexByte(s, '\n'); i >= 0 {
		if j := strings.LastIndexByte(s[:i], '\n'); j >= 0 {
			return s[j+1 : i]
		}
	}
	return ""
}

// ---------------------------------------------------------------------------
// POSIX TZ 解析与例行转换展开（RFC 8536 §3.3）

// parsePOSIX 解析 "STD[offset][DST[offset][,start,end]]"，返回标准/DST 偏移与缩写。
func parsePOSIX(s string) (stdOff, dstOff int32, stdAbbr, dstAbbr string, hasDST bool, ok bool) {
	name := func(i int) (string, int) {
		if i >= len(s) || s[i] < 'A' || s[i] > 'Z' {
			return "", i
		}
		j := i + 1
		for j < len(s) && s[j] >= 'A' && s[j] <= 'Z' {
			j++
		}
		return s[i:j], j
	}
	off := func(i int) (int32, int, bool) {
		neg := false
		if i < len(s) && (s[i] == '+' || s[i] == '-') {
			neg = s[i] == '-'
			i++
		}
		v := 0
		for i < len(s) && s[i] >= '0' && s[i] <= '9' {
			v = v*10 + int(s[i]-'0')
			i++
		}
		h, m, sec := v, 0, 0
		if i < len(s) && s[i] == ':' {
			i++
			for i < len(s) && s[i] >= '0' && s[i] <= '9' {
				m = m*10 + int(s[i]-'0')
				i++
			}
			if i < len(s) && s[i] == ':' {
				i++
				for i < len(s) && s[i] >= '0' && s[i] <= '9' {
					sec = sec*10 + int(s[i]-'0')
					i++
				}
			}
		}
		total := h*3600 + m*60 + sec
		if neg {
			total = -total
		}
		// POSIX 偏移符号与常规相反：EST5 = UTC-5，CST-8 = UTC+8
		return int32(-total), i, true
	}
	a, i := name(0)
	if a == "" {
		return 0, 0, "", "", false, false
	}
	o, i, ok := off(i)
	if !ok {
		return 0, 0, "", "", false, false
	}
	stdOff, stdAbbr = o, a
	if i >= len(s) || s[i] == ',' {
		return stdOff, stdOff, stdAbbr, stdAbbr, false, true
	}
	b, j := name(i)
	if b == "" {
		return stdOff, stdOff, stdAbbr, stdAbbr, false, true
	}
	dstAbbr = b
	dstOff = stdOff + 3600
	i = j
	if i < len(s) && (s[i] == '+' || s[i] == '-' || (s[i] >= '0' && s[i] <= '9')) {
		if o2, k, ok2 := off(i); ok2 {
			dstOff = o2
			i = k
		}
	}
	if i < len(s) && s[i] == ',' {
		return stdOff, dstOff, stdAbbr, dstAbbr, true, true
	}
	return stdOff, dstOff, stdAbbr, dstAbbr, true, true
}

// 规则：kind 0=M 月.周.日；1=Jn（不含闰日）；2=n（含闰日，0 为 1 月 1 日）
type rule struct {
	kind int
	m    int // M 用
	w    int
	d    int
	n    int // Jn/n 用
	t    int64
}

// parseRulePart 解析单个规则段（"Mm.w.d[/time]"、"Jn[/time]"、"n[/time]"）。
func parseRulePart(s string) (r rule, rest string, ok bool) {
	r.t = 2 * 3600
	i := 0
	switch {
	case s[0] == 'M':
		r.kind = 0
		p := 1
		for p < len(s) && s[p] >= '0' && s[p] <= '9' {
			r.m = r.m*10 + int(s[p]-'0')
			p++
		}
		if p < len(s) && s[p] == '.' {
			p++
			for p < len(s) && s[p] >= '0' && s[p] <= '9' {
				r.w = r.w*10 + int(s[p]-'0')
				p++
			}
		}
		if p < len(s) && s[p] == '.' {
			p++
			for p < len(s) && s[p] >= '0' && s[p] <= '9' {
				r.d = r.d*10 + int(s[p]-'0')
				p++
			}
		}
		i = p
	case s[0] == 'J':
		r.kind = 1
		p := 1
		for p < len(s) && s[p] >= '0' && s[p] <= '9' {
			r.n = r.n*10 + int(s[p]-'0')
			p++
		}
		i = p
	default:
		r.kind = 2
		for i < len(s) && s[i] >= '0' && s[i] <= '9' {
			r.n = r.n*10 + int(s[i]-'0')
			i++
		}
	}
	if i < len(s) && s[i] == '/' {
		hh, mm := 0, 0
		i++
		for i < len(s) && s[i] >= '0' && s[i] <= '9' {
			hh = hh*10 + int(s[i]-'0')
			i++
		}
		if i < len(s) && s[i] == ':' {
			i++
			for i < len(s) && s[i] >= '0' && s[i] <= '9' {
				mm = mm*10 + int(s[i]-'0')
				i++
			}
		}
		r.t = int64(hh)*3600 + int64(mm)*60
	}
	rest = s[i:]
	ok = true
	return
}

// 年/月/日 → 天（Howard Hinnant days_from_civil）
func daysFromCivil(y, m, d int) int64 {
	yy := int64(y)
	if m <= 2 {
		yy--
	}
	era := yy / 400
	if yy < 0 {
		era = (yy - 399) / 400
	}
	yoe := yy - era*400
	mp := int64(m)
	if m > 2 {
		mp -= 3
	} else {
		mp += 9
	}
	doy := (153*mp+2)/5 + int64(d) - 1
	doe := yoe*365 + yoe/4 - yoe/100 + doy
	return era*146097 + doe - 719468
}

// 天 → 年/月/日（civil_from_days）
func civilFromDays(z int64) (int, int, int) {
	z += 719468
	era := z / 146097
	if z < 0 {
		era = (z - 146096) / 146097
	}
	doe := z - era*146097
	yoe := (doe - doe/1460 + doe/36524 - doe/146096) / 365
	y := int(yoe) + int(era)*400
	doy := doe - (365*yoe + yoe/4 - yoe/100)
	mp := (5*doy + 2) / 153
	d := int(doy-(153*mp+2)/5) + 1
	m := int(mp) + 3
	if m > 12 {
		m -= 12
		y++
	}
	return y, m, d
}

func isLeap(y int) bool {
	return y%4 == 0 && (y%100 != 0 || y%400 == 0)
}

// nthWeekday 返回月 m 第 w 个星期 d（0=周日）的日期；w=5 表示最后一个。
func nthWeekday(year, m, w, d int) int {
	first := int(daysFromCivil(year, m, 1)%7 + 7) % 7
	delta := (d - first + 7) % 7
	day := 1 + delta + (w-1)*7
	daysIn := 31
	switch m {
	case 4, 6, 9, 11:
		daysIn = 30
	case 2:
		daysIn = 28
		if isLeap(year) {
			daysIn = 29
		}
	}
	if w == 5 {
		for day > daysIn {
			day -= 7
		}
	}
	return day
}

// ruleDay 返回某年规则对应的（月, 日）。
func ruleDay(year int, r rule) (int, int) {
	switch r.kind {
	case 0:
		return r.m, nthWeekday(year, r.m, r.w, r.d)
	case 1:
		n := r.n
		if n > 59 && isLeap(year) {
			n++
		}
		_, m, d := civilFromDays(daysFromCivil(year, 1, 1) + int64(n) - 1)
		return m, d
	default:
		_, m, d := civilFromDays(daysFromCivil(year, 1, 1) + int64(r.n))
		return m, d
	}
}

// ruleUTC 计算某年规则的 UTC 时间戳；offBefore 为转换发生前的当地偏移。
func ruleUTC(year int, r rule, offBefore int32) int64 {
	m, d := ruleDay(year, r)
	return daysFromCivil(year, m, d)*86400 + r.t - int64(offBefore)
}

// expandPosix 把例行 DST 转换展开到 2037 年底，与显式表合并。
func expandPosix(trs []transition, posix string) []transition {
	stdOff, dstOff, stdAbbr, dstAbbr, hasDST, ok := parsePOSIX(posix)
	if !ok || !hasDST {
		// 无 DST 规则：若最后一条显式转换早于 2037 且只有固定偏移，补一条到 2037 的兜底
		return trs
	}
	parts := strings.Split(posix, ",")
	if len(parts) < 3 {
		return trs
	}
	start, _, ok1 := parseRulePart(parts[1])
	end, _, ok2 := parseRulePart(parts[2])
	if !ok1 || !ok2 {
		return trs
	}
	last := trs[len(trs)-1]
	lastYear, _, _ := civilFromDays(last.time / 86400)
	var out []transition
	out = append(out, trs...)
	for y := lastYear; y <= 2037; y++ {
		st := ruleUTC(y, start, stdOff)
		if st > last.time {
			out = append(out, transition{time: st, offset: dstOff, abbr: dstAbbr})
		}
		et := ruleUTC(y, end, dstOff)
		if et > last.time {
			out = append(out, transition{time: et, offset: stdOff, abbr: stdAbbr})
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].time < out[j].time })
	return out
}

// ---------------------------------------------------------------------------

func main() {
	dir := flag.String("dir", "", "zic 编译产出的 zoneinfo 目录")
	out := flag.String("out", "pkg/time/tzdata.cute", "输出文件")
	ver := flag.String("ver", "2026c", "tzdata 版本号（写进注释）")
	flag.Parse()

	var b strings.Builder
	b.WriteString("// 时区数据：由 tools/gen_tzdata/main.go 从 IANA tzdata " + *ver + " 编译生成（勿手改）\n")
	b.WriteString("// 每行格式: zoneName|unix秒,偏移秒,缩写|unix秒,偏移秒,缩写|...（升序，秒为 UTC 纪元）\n")
	b.WriteString("// 通过 time.cute 的 zoneOffset/zoneAbbr 查询；该文本不含转义，单行存储。\n\n")

	type zoneData struct {
		name string
		str  string
	}
	var built []zoneData
	for _, z := range zones {
		if z == "UTC" {
			built = append(built, zoneData{z, "UTC|0,0,UTC"})
			continue
		}
		trs, posix, err := parseTZif(filepath.Join(*dir, z))
		if err != nil {
			fmt.Fprintf(os.Stderr, "warn: %s: %v\n", z, err)
			continue
		}
		trs = expandPosix(trs, posix)
		// 去重相邻相同 offset+abbr
		var kept []transition
		for _, t := range trs {
			if len(kept) > 0 && kept[len(kept)-1].offset == t.offset && kept[len(kept)-1].abbr == t.abbr {
				continue
			}
			kept = append(kept, t)
		}
		var sb strings.Builder
		sb.WriteString(z + "|")
		for i, t := range kept {
			if i > 0 {
				sb.WriteString("|")
			}
			fmt.Fprintf(&sb, "%d,%d,%s", t.time, t.offset, t.abbr)
		}
		built = append(built, zoneData{z, sb.String()})
	}

	var consts []string
	for _, zd := range built {
		varName := "tz" + strings.ReplaceAll(zd.name, "/", "_")
		consts = append(consts, fmt.Sprintf("var %s: string = \"%s\"", varName, zd.str))
	}
	b.WriteString(strings.Join(consts, "\n") + "\n\n")

	b.WriteString("// 名称 → 数据常量 分发（由生成工具输出，勿手改）\n")
	b.WriteString("fn findZoneData(name string) string {\n")
	for _, zd := range built {
		varName := "tz" + strings.ReplaceAll(zd.name, "/", "_")
		fmt.Fprintf(&b, "    if strings.eq(name, \"%s\") {\n        ret %s\n    }\n", zd.name, varName)
	}
	b.WriteString("    ret tzUTC\n}\n")

	if err := os.MkdirAll(filepath.Dir(*out), 0o755); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := os.WriteFile(*out, []byte(b.String()), 0o644); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("written %s (%d zones, %d bytes)\n", *out, len(built), b.Len())
}