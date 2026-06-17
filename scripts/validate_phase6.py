#!/usr/bin/env python3
"""Phase 6 最终检查：字段完整性、校验和、TCP 序号交叉验证。"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TSHARK = r"C:\Program Files\Wireshark\tshark.exe"
ASSETS = ROOT / "report" / "assets"
REQUIRED_ASSETS = [
    "ip-header.png",
    "ip-fragmentation.png",
    "icmp-echo.png",
    "dhcp-dora.png",
    "arp-request-reply.png",
    "tcp-handshake.png",
    "tcp-data.png",
    "tcp-teardown.png",
]
REQUIRED_CAPTURES = [
    "captures/icmp/icmp-normal.pcapng",
    "captures/icmp/icmp-large-packet-fragmentation.pcapng",
    "captures/dhcp/dhcp-dora.pcapng",
    "captures/arp/arp-request-reply.pcapng",
    "captures/tcp/tcp-https.pcapng",
]
FORBIDDEN = re.compile(r"待填|TODO|占位符|\(从 Wireshark 读\)")


def tshark(*args: str) -> str:
    cmd = [TSHARK, *args]
    return subprocess.check_output(cmd, text=True, encoding="utf-8", errors="replace").strip()


def check_notes_no_placeholders() -> list[str]:
    errors: list[str] = []
    for path in (ROOT / "notes").glob("*-analysis.md"):
        text = path.read_text(encoding="utf-8")
        if FORBIDDEN.search(text):
            errors.append(f"{path.name} 含占位符关键词")
    return errors


def check_assets() -> list[str]:
    return [name for name in REQUIRED_ASSETS if not (ASSETS / name).is_file()]


def check_captures() -> list[str]:
    return [rel for rel in REQUIRED_CAPTURES if not (ROOT / rel).is_file()]


def check_ip_checksum() -> list[str]:
    from verify_ipv4_checksum import ipv4_checksum, normalize_hex

    header = normalize_hex("4500003ccfb50000800168200a7adb6c0a031302")
    calc = ipv4_checksum(header)
    if calc != 0x6820:
        return [f"IP 校验和期望 0x6820，得到 0x{calc:04X}"]
    return []


def check_tcp_handshake() -> list[str]:
    pcap = ROOT / "captures/tcp/tcp-https.pcapng"
    rows = tshark(
        "-o",
        "tcp.relative_sequence_numbers:FALSE",
        "-r",
        str(pcap),
        "-Y",
        "frame.number>=29 && frame.number<=31",
        "-T",
        "fields",
        "-e",
        "tcp.seq_raw",
        "-e",
        "tcp.ack_raw",
    ).splitlines()
    if len(rows) < 3:
        return ["TCP 握手帧不足 3 个"]
    seq1, ack1 = rows[0].split("\t")
    seq2, ack2 = rows[1].split("\t")
    seq3, ack3 = rows[2].split("\t")
    errors: list[str] = []
    if int(ack2) != int(seq1) + 1:
        errors.append(f"握手步2 Ack={ack2} != Seq1+1={int(seq1)+1}")
    if int(ack3) != int(seq2) + 1:
        errors.append(f"握手步3 Ack={ack3} != Seq2+1={int(seq2)+1}")
    return errors


def _flag_on(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes"}


def check_tcp_teardown() -> list[str]:
    pcap = ROOT / "captures/tcp/tcp-https.pcapng"
    raw = tshark(
        "-o",
        "tcp.relative_sequence_numbers:FALSE",
        "-r",
        str(pcap),
        "-Y",
        "frame.number==55 || frame.number==56 || frame.number==58 || frame.number==59",
        "-T",
        "fields",
        "-e",
        "frame.number",
        "-e",
        "tcp.flags.reset",
        "-e",
        "tcp.flags.fin",
        "-e",
        "tcp.seq_raw",
    )
    data: dict[int, tuple[bool, bool, int]] = {}
    for line in raw.splitlines():
        num, rst, fin, seq = line.split("\t")
        data[int(num)] = (_flag_on(rst), _flag_on(fin), int(seq))
    errors: list[str] = []
    if not data.get(55, (False, False, 0))[1]:
        errors.append("帧 55 应为 FIN")
    if not data.get(59, (False, False, 0))[1]:
        errors.append("帧 59 应为 FIN")
    if not data.get(58, (False, False, 0))[0]:
        errors.append("帧 58 应为 RST（本捕获以 RST 关闭）")
    return errors


def main() -> int:
    checks = [
        ("抓包文件", check_captures),
        ("报告插图", check_assets),
        ("笔记占位符", check_notes_no_placeholders),
        ("IP 校验和", check_ip_checksum),
        ("TCP 三次握手", check_tcp_handshake),
        ("TCP 四次挥手", check_tcp_teardown),
    ]
    failed = False
    print("=== Phase 6 验证 ===")
    for name, fn in checks:
        errs = fn()
        if errs:
            failed = True
            print(f"[FAIL] {name}")
            for err in errs:
                print(f"       - {err}")
        else:
            print(f"[PASS] {name}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
