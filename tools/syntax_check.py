#!/usr/bin/env python3
"""
语法/语义检查：用 clang(libclang) + 桩头文件把工程按 iOS ObjC 目标解析一遍。

用途：
  Windows / Linux 上没有 iOS SDK 时，也能在提交前抓出
  「未声明方法、类型不匹配、缺 import、ARC 桥接错误」这类问题。

依赖：
  pip install libclang

用法：
  python tools/syntax_check.py
  # 也可以指定文件
  python tools/syntax_check.py ZDHHFavoriteBar.m

退出码：有 error 返回 1。
"""

import os
import sys

try:
    import clang.cindex as ci
except ImportError:
    print("缺少 libclang，请先执行: pip install libclang")
    sys.exit(2)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STUB = os.path.join(ROOT, "_tmp-stub")

DEFAULT_TARGETS = [
    "ZDHHCommon.m",
    "ZDHHFavoriteBar.m",
    "ZDHHSettingsViewController.m",
    "ZDHHMembersViewController.m",
    "Tweak.xm",
]

ARGS = [
    "-x", "objective-c",
    "-std=gnu11",
    "-fobjc-arc",
    "-fblocks",
    "-target", "arm64-apple-ios14.0",
    "-I", STUB,
    "-F", STUB,
    "-ferror-limit=0",
    "-Wno-everything",
    # Theos 默认把警告当错误，这里把最容易在真机编译时炸的几类单独打开
    "-Warc-retain-cycles",
    "-Warc-unsafe-retained-assign",
    "-Wobjc-interface-ivars",
]

SEVERITY = {0: "IGN", 1: "NOTE", 2: "WARN", 3: "ERR", 4: "FATAL"}

# Theos 会把这些当 error，本地先按 error 对待
PROMOTED_WARNINGS = ("retain cycle", "arc", "incompatible pointer")


def check(path):
    index = ci.Index.create()
    tu = index.parse(path, args=ARGS,
                     options=ci.TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD)
    diags = list(tu.diagnostics)
    errors = [d for d in diags if d.severity >= ci.Diagnostic.Error]
    promoted = [d for d in diags
                if d.severity == ci.Diagnostic.Warning
                and any(k in d.spelling.lower() for k in PROMOTED_WARNINGS)]

    name = os.path.basename(path)
    print(f"=== {name}: diag={len(diags)} errors={len(errors)} promoted={len(promoted)}")

    seen = set()
    for d in errors + promoted:
        key = (str(d.location.file), d.location.line, d.spelling)
        if key in seen:
            continue
        seen.add(key)
        tag = "ERR" if d.severity >= ci.Diagnostic.Error else "ERR(theos)"
        f = os.path.basename(str(d.location.file)) if d.location.file else "?"
        print(f"   [{tag}] {f}:{d.location.line} {d.spelling}")
        if len(seen) >= 15:
            print("   ... (truncated)")
            break
    return len(errors) + len(promoted)


def main():
    if not os.path.isdir(STUB):
        print(f"桩目录不存在: {STUB}")
        return 2

    targets = sys.argv[1:] or DEFAULT_TARGETS
    total = 0
    for t in targets:
        path = t if os.path.isabs(t) else os.path.join(ROOT, t)
        if not os.path.isfile(path):
            print(f"=== {t}: MISSING")
            total += 1
            continue
        total += check(path)

    print(f"\nTOTAL ERRORS: {total}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
