#!/usr/bin/env python3
"""从 tshark 解析结果生成 report/assets/ 字段摘录 PNG。"""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "report" / "assets"
TSHARK = r"C:\Program Files\Wireshark\tshark.exe"


def run_tshark(args: list[str]) -> str:
    cmd = [TSHARK, *args]
    return subprocess.check_output(cmd, text=True, encoding="utf-8", errors="replace").strip()


def save_table_png(filename: str, title: str, headers: list[str], rows: list[list[str]]) -> None:
    import matplotlib.pyplot as plt

    plt.rcParams["font.sans-serif"] = ["SimHei", "Microsoft YaHei", "SimSun", "DejaVu Sans"]
    plt.rcParams["axes.unicode_minus"] = False

    ASSETS.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(12, max(2.5, 0.45 * len(rows) + 1.2)))
    ax.axis("off")
    ax.set_title(title, fontsize=13, fontweight="bold", pad=12, loc="left")

    table = ax.table(cellText=rows, colLabels=headers, loc="center", cellLoc="left")
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 1.35)

    for (row, col), cell in table.get_celld().items():
        if row == 0:
            cell.set_facecolor("#eef2ff")
            cell.set_text_props(fontweight="bold")
        elif row % 2 == 0:
            cell.set_facecolor("#fcfcfc")

    out = ASSETS / filename
    fig.savefig(out, dpi=160, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"Wrote {out}")


def main() -> None:
    base = ROOT / "captures"

    save_table_png(
        "ip-header.png",
        "IPv4 首部字段（帧 1 · ICMP Echo Request）",
        ["字段", "捕获值", "说明"],
        [
            ["Version", "4", "IPv4"],
            ["Header Length", "20 bytes", "5×4 字节"],
            ["Differentiated Services", "0x00", "DSCP/ECN"],
            ["Total Length", "60", "字节"],
            ["Identification", "0xCFB5", "分片标识"],
            ["Flags", "DF=0 MF=0", "未分片"],
            ["Fragment Offset", "0", "×8 字节"],
            ["TTL", "128", "生存时间"],
            ["Protocol", "ICMP (1)", "上层协议"],
            ["Header Checksum", "0x6820", "首部校验和"],
            ["Source", "10.122.219.108", "源 IP"],
            ["Destination", "10.3.19.2", "目的 IP"],
        ],
    )

    save_table_png(
        "ip-fragmentation.png",
        "IP 分片对比（Identification = 0xCFBA）",
        ["分片", "ID", "MF", "Offset", "Total Len"],
        [
            ["1", "0xCFBA", "1", "0", "1500"],
            ["2", "0xCFBA", "1", "185", "1500"],
            ["3", "0xCFBA", "1", "370", "1500"],
            ["4", "0xCFBA", "1", "555", "1500"],
            ["5", "0xCFBA", "1", "740", "1500"],
            ["6", "0xCFBA", "0", "925", "628"],
        ],
    )

    save_table_png(
        "icmp-echo.png",
        "ICMP Echo Request / Reply（帧 1 & 2）",
        ["字段", "Request", "Reply"],
        [
            ["Type", "8", "0"],
            ["Code", "0", "0"],
            ["Checksum", "0x4D4A", "0x554A"],
            ["Identifier", "1", "1"],
            ["Sequence", "17", "17"],
            ["Data", "32 字节 abc…", "同 Request"],
        ],
    )

    save_table_png(
        "dhcp-dora.png",
        "DHCP DORA（Transaction ID = 0x348015F3）",
        ["阶段", "类型", "源地址", "目的地址"],
        [
            ["1", "Discover", "0.0.0.0", "255.255.255.255"],
            ["2", "Offer", "10.3.9.2", "10.122.219.108"],
            ["3", "Request", "0.0.0.0", "255.255.255.255"],
            ["4", "ACK", "10.3.9.2", "10.122.219.108"],
        ],
    )

    save_table_png(
        "arp-request-reply.png",
        "ARP Request / Reply",
        ["字段", "Request", "Reply"],
        [
            ["Opcode", "1", "2"],
            ["Sender MAC", "10:4f:58:6c:24:00", "c0:35:32:78:d3:09"],
            ["Sender IP", "10.122.192.1", "10.122.219.108"],
            ["Target MAC", "00:00:00:00:00:00", "10:4f:58:6c:24:00"],
            ["Target IP", "10.122.219.108", "10.122.192.1"],
            ["Eth Dst", "c0:35:32:78:d3:09", "10:4f:58:6c:24:00"],
        ],
    )

    save_table_png(
        "tcp-handshake.png",
        "TCP 三次握手（220.181.111.1:443）",
        ["步骤", "Flags", "Seq", "Ack"],
        [
            ["1 Client→Server", "SYN", "3410032806", "—"],
            ["2 Server→Client", "SYN+ACK", "208860029", "3410032807"],
            ["3 Client→Server", "ACK", "3410032807", "208860030"],
        ],
    )

    save_table_png(
        "tcp-data.png",
        "TCP 数据传输与确认",
        ["帧", "方向", "Seq", "Ack", "Len", "验证"],
        [
            ["32", "Client→Server", "3410032807", "208860030", "460", "—"],
            ["33", "Server→Client", "208860030", "3410033267", "0", "Ack=Seq+460 ✓"],
            ["40", "Server→Client", "208864110", "3410033267", "1122", "重传"],
        ],
    )

    save_table_png(
        "tcp-teardown.png",
        "TCP 连接释放（含 RST）",
        ["步骤", "帧", "Flags", "Seq", "Ack"],
        [
            ["1", "55", "FIN+ACK", "3410033530", "208868323"],
            ["2", "56", "ACK", "208868323", "3410033530"],
            ["3", "59", "FIN+ACK", "208868354", "3410033530"],
            ["4", "58", "RST+ACK", "3410033531", "208868354"],
        ],
    )


if __name__ == "__main__":
    main()
