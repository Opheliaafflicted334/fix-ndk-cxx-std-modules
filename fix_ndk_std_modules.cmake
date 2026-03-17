# CMake 示例，对于 import std 的问题仍需解决
# 本示例仅解决Android NDK内 Bionic 与 std.cppm 的问题

add_definitions(-D__BIONIC_CTYPE_INLINE=inline)
