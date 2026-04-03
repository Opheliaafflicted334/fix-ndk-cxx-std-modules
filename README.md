# Android NDK C++20 模块修复方案

## 项目概述

这是一个专门用于解决 Android NDK 中使用 C++20 模块时编译问题的 xmake 配置文件。该方案解决了 NDK 中 Bionic C 库与 C++20 模块标准之间的兼容性问题。

## 问题背景

1. C++20 模块支持问题

在使用 Android NDK 编译 C++20 模块项目时，xmake 无法正确处理标准库模块的链接，导致编译失败。

2. Bionic 库的兼容性问题

Android 的 Bionic C 库中的字符处理函数（如 isdigit、isalpha 等）使用 static __inline 定义，导致：

- 在 C++20 模块中产生内部链接
- 违反单一定义规则（ODR）
- 模块导入时产生重复定义错误

## 解决方案

核心修复代码

```lua
function fix_ndk_std_modules(cxx_Link_mode)
    cxx_Link_mode = cxx_Link_mode or "static"
    
    -- 1. 修复 xmake 的模块查找问题
    set_runtimes("c++_" .. cxx_Link_mode)
    
    -- 2. 修复 Bionic 库的 static 定义问题
    add_defines("__BIONIC_CTYPE_INLINE=inline")
end
```

**对于非xmake项目，只需要定义全局宏 `"__BIONIC_CTYPE_INLINE=inline"` 即可**

## 使用方法

1. 基本使用

下载本项目的 `xmake.lua` 到本地为 `fix_ndk_std_modules.xmake.lua`

在你的 xmake.lua 文件中：

```lua
-- 包含修复脚本
include("path/to/fix_ndk_std_modules.xmake.lua")
-- 应用修复（使用 static 链接）
fix_ndk_std_modules("static")

target("your_target")
    set_kind("binary")
    add_files("src/*.cpp")
```

## 参数说明

参数 类型 默认值 说明
cxx_Link_mode string "static" C++ 运行时库链接方式，可选 "static" 或 "shared"

## 问题分析, 修复原理

详见 [xmake.lua](xmake.lua)

## 测试环境

- NDK 版本：r29 (29.0.14206865)
- 编译器：Clang++ (NDK 内置)
- 构建系统：xmake v3.0.7+HEAD.77d94ad
- C++ 标准：C++23


## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个修复方案。请确保：

1. 描述清楚问题和解决方案
2. 提供测试环境和重现步骤
3. 保持代码简洁，添加必要注释
4. 更新相关文档

## 许可证

无

## 参考链接

- https://quadnucyard.github.io/posts/cpp/clang-std-modules.html

> 本文档由AI编写并经过修改
