# 负例：非左值接收者

`makeVec()[0]` 的接收者是函数返回值，不能作为方法接收者 lowering。
预期编译失败，错误信息包含：

    operator receiver of type Vec must be an lvalue

该目录不会被父目录的 `test_run.sh test/operatorOverload` 编译（包加载器跳过子目录），
需要单独执行：

    CUTE_ROOT=$PWD CUTE_ARCH=x86_64 /tmp/opencode/cuteify2 -S test/operatorOverload/neg_nonlvalue
