# Wireshark 报告截图指南

> 按老师要求，每张图须包含 **Packet List + Packet Detail（协议树展开）+ Packet Bytes** 三栏。  
> 保存到 `report/assets/`，**覆盖**同名 PNG 后执行 `typst compile report/lab2-report.typ`。

## 通用操作

1. 用 Wireshark 打开 `captures/` 下对应 `.pcapng`
2. 在顶部 **Display Filter** 栏输入过滤器，回车
3. 在 Packet List 选中目标包（可多选 `Ctrl+点击`）
4. 在 Packet Detail 展开对应协议层（点击左侧三角）
5. `Win + Shift + S` 框选整个 Wireshark 主窗口三栏区域
6. 保存为下表指定文件名

---

## 8 张截图清单

| 文件名 | 抓包文件 | Display Filter | 操作要点 |
|---|---|---|---|
| `ip-header.png` | `icmp/icmp-normal.pcapng` | `icmp.type==8` | 选 1 个 Echo Request，展开 **Internet Protocol Version 4** |
| `ip-fragmentation.png` | `icmp/icmp-large-packet-fragmentation.pcapng` | `ip.id==0xcfba` | 选中 6 个分片，展开 IP 层 |
| `icmp-echo.png` | `icmp/icmp-normal.pcapng` | `icmp` | 选 Request + Reply（帧 1、2），展开 **ICMP** |
| `dhcp-dora.png` | `dhcp/dhcp-dora.pcapng` | `dhcp.option.dhcp == 1 \|\| 2 \|\| 3 \|\| 5` | 选 DORA 四包，展开 **DHCP** |
| `arp-request-reply.png` | `arp/arp-request-reply.pcapng` | `arp` | 选 Request + Reply，展开 **ARP** |
| `tcp-handshake.png` | `tcp/tcp-http.pcapng` | `tcp.stream==0 && frame.number<=3` | 帧 1–3，展开 **TCP** |
| `tcp-data.png` | `tcp/tcp-http.pcapng` | `tcp.stream==0 && frame.number>=4 && frame.number<=5` | 帧 4–5，看清 Seq/Ack/Len/Window |
| `tcp-teardown.png` | `tcp/tcp-http.pcapng` | `tcp.stream==0 && tcp.flags.fin==1 \|\| (frame.number==11)` | 帧 9–11，展开 **TCP** |

## 编译 PDF

```powershell
cd report
typst compile lab2-report.typ lab2-report.pdf
```

## 验收

截图替换后，图中字段值应与 `notes/` 分析笔记一致。
