package typeSys

import "testing"

// []T 的值携带 data 堆指针，必须参与引用管理。
//
// 回归点：ListType 内嵌 RType，若没有显式实现 IsOwning，方法会被提升到
// 内嵌的 *RType，r.Kind() 返回 "unknown"，list 被漏判为非 owning。
func TestListTypeIsOwning(t *testing.T) {
	l := NewList(GetSystemType("int"))
	if !l.IsOwning() {
		t.Fatal("[]int 应判定为 owning（携带 data 堆指针）")
	}
	if got := l.Kind(); got != "list" {
		t.Fatalf("Kind() = %q，期望 list", got)
	}
}
