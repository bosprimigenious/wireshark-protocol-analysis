#!/usr/bin/env python3
"""启动 Wireshark GUI 并截取真实三栏界面截图（Packet List / Detail / Bytes）。"""

from __future__ import annotations

import argparse
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path

import psutil
import pyautogui
import pygetwindow as gw
from PIL import ImageGrab

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "report" / "assets"
WIRESHARK = Path(r"C:\Program Files\Wireshark\Wireshark.exe")

pyautogui.FAILSAFE = False
pyautogui.PAUSE = 0.08


@dataclass(frozen=True)
class ShotSpec:
    filename: str
    pcap: str
    display_filter: str
    goto: int
    expand_down: int = 2


SHOTS: tuple[ShotSpec, ...] = (
    ShotSpec(
        "ip-header.png",
        "captures/icmp/icmp-normal.pcapng",
        "icmp.type==8",
        1,
        expand_down=2,
    ),
    ShotSpec(
        "ip-fragmentation.png",
        "captures/icmp/icmp-large-packet-fragmentation.pcapng",
        "ip.id==0xcfba",
        13,
        expand_down=2,
    ),
    ShotSpec(
        "icmp-echo.png",
        "captures/icmp/icmp-normal.pcapng",
        "frame.number==1 || frame.number==2",
        1,
        expand_down=3,
    ),
    ShotSpec(
        "dhcp-dora.png",
        "captures/dhcp/dhcp-dora.pcapng",
        "dhcp.option.dhcp == 1 || dhcp.option.dhcp == 2 || dhcp.option.dhcp == 3 || dhcp.option.dhcp == 5",
        2,
        expand_down=4,
    ),
    ShotSpec(
        "arp-request-reply.png",
        "captures/arp/arp-request-reply.pcapng",
        "arp",
        1,
        expand_down=2,
    ),
    ShotSpec(
        "tcp-handshake.png",
        "captures/tcp/tcp-http.pcapng",
        "tcp.stream==0 && frame.number<=3",
        1,
        expand_down=3,
    ),
    ShotSpec(
        "tcp-data.png",
        "captures/tcp/tcp-http.pcapng",
        "tcp.stream==0 && frame.number>=4 && frame.number<=5",
        4,
        expand_down=3,
    ),
    ShotSpec(
        "tcp-teardown.png",
        "captures/tcp/tcp-http.pcapng",
        "tcp.stream==0 && (tcp.flags.fin==1 || frame.number==11)",
        9,
        expand_down=3,
    ),
)


def kill_wireshark() -> None:
    for proc in psutil.process_iter(["name", "pid"]):
        if (proc.info.get("name") or "").lower() != "wireshark.exe":
            continue
        try:
            proc.kill()
            proc.wait(timeout=5)
        except (psutil.Error, OSError):
            pass
    time.sleep(0.8)


def wireshark_pids() -> set[int]:
    pids: set[int] = set()
    for proc in psutil.process_iter(["name", "pid"]):
        if (proc.info.get("name") or "").lower() == "wireshark.exe":
            pids.add(proc.info["pid"])
    return pids


def find_wireshark_window(timeout: float = 90.0):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if not wireshark_pids():
            time.sleep(0.3)
            continue
        wins = [
            w
            for w in gw.getAllWindows()
            if w.title
            and (
                w.title.endswith(".pcapng")
                or w.title.endswith(".pcap")
                or "Wireshark" in w.title
            )
        ]
        if wins:
            win = max(wins, key=lambda w: w.width * w.height)
            if win.width > 400 and win.height > 300:
                return win
        time.sleep(0.4)
    raise TimeoutError("未找到已加载完成的 Wireshark 窗口")


def activate_window(win) -> None:
    if win.isMinimized:
        win.restore()
    try:
        win.activate()
    except Exception:
        pass
    time.sleep(0.25)
    try:
        win.maximize()
    except Exception:
        pass
    time.sleep(0.35)


def click_packet_detail(win) -> None:
    x = win.left + int(win.width * 0.33)
    y = win.top + int(win.height * 0.58)
    pyautogui.click(x, y)


def goto_packet(win, number: int) -> None:
    activate_window(win)
    pyautogui.hotkey("ctrl", "g")
    time.sleep(0.35)
    for digit in str(number):
        pyautogui.press(digit)
    pyautogui.press("enter")
    time.sleep(0.35)


def expand_protocol_tree(win, down_steps: int) -> None:
    click_packet_detail(win)
    time.sleep(0.2)
    pyautogui.press("home")
    time.sleep(0.12)
    for _ in range(down_steps):
        pyautogui.press("down")
        time.sleep(0.06)
    pyautogui.press("right")
    time.sleep(0.12)
    pyautogui.press("right")
    time.sleep(0.2)




def capture_window(win, output: Path) -> None:
    activate_window(win)
    time.sleep(0.2)
    bbox = (win.left + 4, win.top + 4, win.right - 4, win.bottom - 4)
    img = ImageGrab.grab(bbox=bbox)
    output.parent.mkdir(parents=True, exist_ok=True)
    img.save(output, format="PNG", optimize=True)


def capture_shot(spec: ShotSpec, load_wait: float = 4.0) -> Path:
    pcap = ROOT / spec.pcap
    if not pcap.exists():
        raise FileNotFoundError(f"抓包文件不存在: {pcap}")

    kill_wireshark()
    args = [str(WIRESHARK), "-r", str(pcap), "-Y", spec.display_filter, "-g", str(spec.goto)]
    subprocess.Popen(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    win = find_wireshark_window()
    time.sleep(load_wait)
    activate_window(win)
    time.sleep(0.8)
    goto_packet(win, spec.goto)
    expand_protocol_tree(win, spec.expand_down)

    output = ASSETS / spec.filename
    capture_window(win, output)
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description="截取 Wireshark 真实界面截图")
    parser.add_argument("--only", nargs="*", help="仅截取指定文件名，如 ip-header.png")
    parser.add_argument("--wait", type=float, default=4.0, help="打开后额外等待秒数")
    args = parser.parse_args()

    if not WIRESHARK.exists():
        raise SystemExit(f"未找到 Wireshark: {WIRESHARK}")

    targets = SHOTS
    if args.only:
        names = set(args.only)
        targets = tuple(s for s in SHOTS if s.filename in names)
        if not targets:
            raise SystemExit(f"未匹配截图: {args.only}")

    try:
        for spec in targets:
            print(f"Capturing {spec.filename} ...", flush=True)
            out = capture_shot(spec, load_wait=args.wait)
            size_kb = out.stat().st_size / 1024
            print(f"  -> {out} ({size_kb:.1f} KB)", flush=True)
    finally:
        kill_wireshark()

    print("Done.", flush=True)


if __name__ == "__main__":
    main()
