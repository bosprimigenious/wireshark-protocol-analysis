#!/usr/bin/env python3
"""IPv4 首部校验和计算与验证。

用法:
    python verify_ipv4_checksum.py 4500003ccfb50000800168200a7adb6c0a031302
    python verify_ipv4_checksum.py  # 使用实验默认示例首部

算法:
    1. 将校验和字段（字节 10-11）置零
    2. 按 16 bit 大端分组求和，溢出回卷
    3. 按位取反得到校验和
"""

from __future__ import annotations

import re
import sys


def normalize_hex(hex_str: str) -> bytes:
    cleaned = re.sub(r"[^0-9a-fA-F]", "", hex_str)
    if len(cleaned) != 40:
        raise ValueError(f"需要 20 字节（40 个十六进制字符），当前 {len(cleaned)} 个")
    return bytes.fromhex(cleaned)


def ipv4_checksum(header: bytes, *, show_steps: bool = False) -> int:
    if len(header) != 20:
        raise ValueError("仅支持 20 字节标准 IPv4 首部（无选项）")

    data = bytearray(header)
    data[10] = 0
    data[11] = 0

    groups = [(data[i] << 8) + data[i + 1] for i in range(0, 20, 2)]
    total = 0

    if show_steps:
        print("16 bit 分组（校验和已置零）:")
        for idx, value in enumerate(groups, 1):
            print(f"  {idx:2d}. 0x{value:04X}")

    for value in groups:
        total += value
        while total > 0xFFFF:
            total = (total & 0xFFFF) + (total >> 16)
        if show_steps:
            print(f"  -> 累计 0x{total:04X}")

    checksum = (~total) & 0xFFFF
    if show_steps:
        print(f"取反结果: 0x{checksum:04X}")
    return checksum


def main() -> None:
    default = "4500003ccfb50000800168200a7adb6c0a031302"
    hex_input = sys.argv[1] if len(sys.argv) > 1 else default
    header = normalize_hex(hex_input)

    print(f"输入首部: {header.hex()}")
    print(f"原校验和字段: 0x{(header[10] << 8) | header[11]:04X}")
    print()

    result = ipv4_checksum(header, show_steps=True)
    print()
    print(f"计算校验和: 0x{result:04X}")


if __name__ == "__main__":
    main()
