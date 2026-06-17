# 辅助脚本

## verify_ipv4_checksum.py

根据 IPv4 首部十六进制字符串计算首部校验和，用于交叉验证 Wireshark 显示的 Header Checksum。

```bash
# 实验帧 1 示例（ICMP Echo Request 的 IP 首部）
python scripts/verify_ipv4_checksum.py 4500003ccfb50000800168200a7adb6c0a031302

# 输出应为 0x6820，与 Wireshark 一致
```

## generate_report_assets.py

从 `captures/` 解析数据，生成 `report/assets/` 下的字段摘录 PNG（供 Typst 报告引用）。

```bash
python scripts/generate_report_assets.py
```

## validate_phase6.py

提交前最终检查：抓包完整性、插图、笔记占位符、IP 校验和、TCP 握手/挥手序号。

```bash
python scripts/validate_phase6.py
```
