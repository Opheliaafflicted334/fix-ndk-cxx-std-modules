-- @script 这是一个xmake脚本

-- @pragma cxx_link_mode runtimes的类型，必须为字符串，static shared二选一
function fix_ndk_std_modules(cxx_Link_mode)
        cxx_Link_mode = cxx_Link_mode or "static"
        if type(cxx_Link_mode) ~= "string" then
                error("cxx_link_mode必须为string类型")
        end
        if cxx_Link_mode ~= "static" and cxx_Link_mode ~= "shared" then
                error("cxx_link_mode必须为static或shared")
        end


        --[[
        xmake在处理modules时会发疯找不到std模块
        目前只能手动设置runtimes才能解决
        具体值是 c++_static 或 c++_shared 无所谓
        ]]
        set_runtimes("c++_" .. cxx_Link_mode)

        --[[
        说明
        这是android ndk在c++20模块下的特定问题

        安卓使用Bionic作为C库，其中的ctype函数（如isdigit等）被定义为：
        __BIONIC_CTYPE_INLINE int isdigit(int ch) { ... }
        在默认实现中，__BIONIC_CTYPE_INLINE被定义为"static __inline"

        问题：
        在C++20模块中，当模块接口单元使用(或导出)这些函数时，
        与static导致函数具有的内部链接属性冲突，违反ODR，
        因为每个导入该模块的编译单元都会创建自己的函数副本。

        解决方案：
        __BIONIC_CTYPE_INLINE的完整定义为
        #if !defined(__BIONIC_CTYPE_INLINE)
        #define __BIONIC_CTYPE_INLINE static __inline
        #endif
        只需要提前定义__BIONIC_CTYPE_INLINE就能不使用默认值
        所以提前定义__BIONIC_CTYPE_INLINE为inline即可解决

        风险:
        1. 移除static的影响：
        - 原行为：每个编译单元独立拥有函数副本
        - 现行为：全局共享一份函数实现
        - 影响: 理论不会导致性能下降，甚至有可能更优
        - 如果用户定义了同名函数，可能导致重定义错误，但这属于编码问题

        2. 修改__inlinr为inline的影响：
        - 在ndk使用的clang编译器中，__inline和inline完全等效
        - 现代编译器中，inline主要影响链接规则而非强制内联
        - 所以完全无影响
        
        结果:
        对于Bionic中声明为__BIONIC_CTYPE_INLINE的函数，
        无论__BIONIC_CTYPE_INLINE是static __inline还是inline，
        它们的命运一般都会是被LTO合并(或直接完全内联)，在编译后无差别
        
        测试环境
        Android NDK r29 (29.0.14206865)
        ]]
        add_defines("__BIONIC_CTYPE_INLINE=inline")
end
