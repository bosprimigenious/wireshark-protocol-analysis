# 辅助脚本

## verify_ipv4_checksum.py

根据 IPv4 首部十六进制字符串计算首部校验和，用于交叉验证 Wireshark 显示的 Header Checksum。

```bash
# 实验帧 1 示例（ICMP Echo Request 的 IP 首部）
python scripts/verify_ipv4_checksum.py 4500003ccfb50000800168200a7adb6c0a031302

# 输出应为 0x6820，与 Wireshark 一致
```

## generate_report_assets.py

（已弃用）早期用 matplotlib 生成字段摘录表。报告插图请改用下方 `capture_wireshark_screenshots.py` 截取真实 Wireshark 三栏界面。

## capture_wireshark_screenshots.py

自动启动 Wireshark GUI，按 `notes/wireshark-screenshot-guide.md` 配置过滤器与目标帧，截取 **Packet List + Detail + Bytes** 真实截图到 `report/assets/`。

```bash
# 截取全部 8 张（运行期间勿操作鼠标键盘）
python scripts/capture_wireshark_screenshots.py

# 仅重拍某几张
python scripts/capture_wireshark_screenshots.py --only ip-header.png icmp-echo.png
```

依赖：`mss`、`pillow`、`pygetwindow`、`pyautogui`、`psutil`（已随脚本安装）。

## validate_phase6.py

提交前最终检查：抓包完整性、插图、笔记占位符、IP 校验和、TCP 握手/挥手序号。

```bash
python scripts/validate_phase6.py
```
