# PLAN: useful 计数器 DCE + stdlib 规范化

## 任务 1：提交当前内容 + 标准库批量规范化

### 1A. 提交当前内容
- 仅提交 Go 侧和本次 stdlib/脚本改动；不提交 selfhost 用户改动与产物。
- 候选提交范围（按 git status 实际确认）：
  - Go: `compile/exp/exp.go`, `gc/analyze.go`, `gc/llr.go`, `gc/pred.go`, `parser/exp_check.go`, `parser/switch.go`, `parser/var.go`
  - stdlib/scripts: `pkg/strings/strings_common.cute`, `pkg/strings/strings_x86.cute`, `pkg/strings/strings_x86_64.cute`, `pkg/slices/slice_x86.cute`, `pkg/slices/slice_x86_64.cute`, `scripts/cutebuild.sh`
  - 若有测试基线需确认：`pkg/strings/test/gc_llr.txt`, `pkg/strings/test/gc_summary.json`
- 明确排除：`selfhost/**` 用户改动、`_main.asm`、`parsedump`、`cuteify2`、`.tmp/`、`test/**` 临时产物。

### 1B. 标准库批量修改
- 目标：标准库函数参数统一为 `name: type` 写法。
- 扫描 `pkg/**/*.cute`（不含 selfhost 用户文件）。
- 机械改写参数声明中的 `name type` -> `name: type`，排除注释/字符串/误报。
- 验证：`go build`、`./test_run.sh test/complexTest x86_64`、`./test_run.sh test/sliceTest x86_64`、`pkg/strings/test`。
- 模块提交：`stdlib: 统一函数参数为 name:type 语法`。

## 任务 2：Useful bool -> 计数器 DCE

### 用户确认的算法
- `Useful` 从 bool 改为计数器。
- 当 check/处理过程中发现某函数计数减到 0：沿该函数体内所有 call 指向的函数依次减 1；若被减函数也变成 0，则继续传播并禁用。
- 不需要处理引用环（暂不做解环）。
- 计数为 0 的函数后端编译自动跳过，无需额外删除结构。

### 实现步骤

1. **字段改型**
   - `parser/func.go`: `Useful bool` -> `Useful int`。
   - 全仓替换使用点：`= true` -> `++` 或 `=1`（按语义）；`= false` -> `=0`；`!fb.Useful` -> `fb.Useful <= 0`；`fb.Useful` 条件判断改 `> 0`。

2. **建立 callee 引用计数**
   - 在 call 解析/函数值引用处，对目标函数 `Useful++`（保持现有发现点）。
   - 需要记录“谁引用了谁”或在禁用时扫描函数体调用并减计数。按用户要求，采用传播式减计数：
     - 给 FuncBlock 增加记录/扫描能力：获取其直接 callee FuncBlock 集合。
     - 当某 FuncBlock 变为 0 时，遍历其直接 callee，`callee.Useful--`；若 `callee.Useful==0` 递归/队列传播。
   - 为避免重复减计数，callee 列表按边去重或按 (caller,callee) 计一次。

3. **禁用传播触发点**
   - 在编译前 DCE pass 或在引用关系变化后触发传播。
   - 简单实现：编译顶层 pre-pass 中，构建初始计数后，对 `Useful<=0` 且非 root 的函数执行传播禁用；传播时只处理首次到 0。
   - root 不因减到 0 被禁用：`main`、必要 runtime helper、build link provider、export 等现有根。

4. **callee 收集**
   - 扫描 FuncBlock 对应 Node/AST：CallBlock.Func、函数值引用 Define->FuncBlock、方法调用绑定 Func。
   - 可在 FuncBlock 上缓存 `Callees []*FuncBlock`，在 Check/compile 前填充；或按需扫描。

5. **编译器跳过**
   - `compile/compiler.go` 现有 `!v.Useful && name!="main"` 改为 `v.Useful <= 0 && name!="main"`。

6. **验证**
   - `go build -o ./cuteify2 .`
   - `./test_run.sh test/complexTest x86_64`
   - `./test_run.sh test/sliceTest x86_64`
   - 选取样例对比 `_main.asm` 大小/函数符号数量，确认死引用链不再打包。
   - `selfhost/cmd/parsedump` 冒烟编译（不改 selfhost）。

### 风险
- 重复计数/重复减计数：需边去重。
- monomorphize 后新增函数：需纳入计数和传播。
- 间接调用/函数指针：已通过函数值引用覆盖；保守不足时优先不误删。
- 接口方法当前保守 useful；先保持保守，避免误删。
