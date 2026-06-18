#!/usr/bin/env python3
"""
patch_smali.py
==============
Sửa file smali của com/android/provision/Utils:
  Trong method setGmsAppEnabledStateForCn,
  sau cụm:
      invoke-virtual ... PackageManager;->getApplicationEnabledSetting(...)I
      move-result vY
  đổi if-eq -> if-ne

Usage:
    python patch_smali.py <Utils.smali>
    python patch_smali.py <Utils.smali> <output.smali>
"""

import sys, re, os

TARGET_METHOD = "setGmsAppEnabledStateForCn"
PAT_INVOKE    = re.compile(
    r"invoke-virtual\s+\{[^}]+\},\s*"
    r"Landroid/content/pm/PackageManager;->getApplicationEnabledSetting\(Ljava/lang/String;\)I"
)
PAT_MOVE      = re.compile(r"move-result\s+\w+")
PAT_IFEQ      = re.compile(r"(if-eq)(\s+)")

# ----------------------------------------------------------------

def patch(lines):
    # 1. Locate method boundaries
    in_method = False
    method_start = method_end = -1
    for i, line in enumerate(lines):
        s = line.strip()
        if s.startswith(".method") and TARGET_METHOD in s:
            in_method = True
            method_start = i
        if in_method and s == ".end method":
            method_end = i
            break

    if method_start == -1:
        raise RuntimeError(f"Method '{TARGET_METHOD}' not found.")

    scope = lines[method_start:method_end + 1]
    patched = 0

    i = 0
    while i < len(scope):
        if PAT_INVOKE.search(scope[i]):
            # look for move-result right after (allow blank/comment lines)
            j = i + 1
            while j < len(scope) and scope[j].strip() in ("", ):
                j += 1
            if j < len(scope) and PAT_MOVE.search(scope[j]):
                # look for if-eq right after
                k = j + 1
                while k < len(scope) and scope[k].strip() == "":
                    k += 1
                if k < len(scope) and PAT_IFEQ.search(scope[k]):
                    old = scope[k]
                    scope[k] = PAT_IFEQ.sub(r"if-ne\2", old, count=1)
                    print(f"  [PATCH] line {method_start+k+1}")
                    print(f"    - {old.rstrip()}")
                    print(f"    + {scope[k].rstrip()}")
                    patched += 1
        i += 1

    lines[method_start:method_end + 1] = scope
    return lines, patched


def main():
    if len(sys.argv) < 2:
        print("Usage: python patch_smali.py <Utils.smali>")
        sys.exit(1)

    src = sys.argv[1]

    with open(src, "r", encoding="utf-8") as f:
        lines = f.readlines()

    print(f"Patching: {src}")
    lines, count = patch(lines)

    if count == 0:
        print("WARNING: pattern not found — no changes made.")
    else:
        with open(src, "w", encoding="utf-8") as f:
            f.writelines(lines)
        print(f"Done. {count} patch(es) applied directly to: {src}")


if __name__ == "__main__":
    main()
