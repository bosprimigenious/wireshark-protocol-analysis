# 实验要求摘要

> 依据《计算机网络实验二指导书》第 9 节整理。

## 报告必含章节

1. **实验目的** — 掌握协议捕获与解析方法  
2. **实验环境** — OS、Wireshark 版本、网络环境、本机/网关 IP  
3. **实验内容和步骤** — ICMP、DHCP、ARP、TCP 四类捕获步骤  
4. **IP 协议分析** — 首部字段表、校验和验证、分片分析  
5. **ICMP 协议分析** — Echo Request / Reply 字段对比  
6. **DHCP 协议分析** — DORA 过程、ACK 配置参数、序列图  
7. **ARP 协议分析** — Request / Reply、广播/单播  
8. **TCP 协议分析** — 首部字段、三次握手、数据传输、四次挥手  
9. **问题与解决方案** — 至少 2 条真实踩坑  
10. **实验心得**

## 评分与验收关注点

- 所有字段值必须来自 **真实抓包**，附 Wireshark 截图（Packet List + Detail + Bytes）  
- **IPv4 首部校验和**须手工计算并与 Wireshark 显示值一致  
- **IP 分片**：同一 Identification 多分片对比  
- **DHCP**：Transaction ID 相同的 DORA 四包  
- **TCP**：三次握手 Ack = Seq + 1；数据传输 Ack = Seq + Len；四次挥手序号关系正确  
- 文字用自己的话表述，不照抄指导书

## 本仓库交付物

| 路径 | 说明 |
|---|---|
| `captures/` | 原始 `.pcapng` |
| `notes/` | 协议分析笔记 |
| `diagrams/` | Mermaid 时序图 |
| `report/lab2-report.pdf` | Typst 编译的最终报告 |
| `report/assets/` | 报告插图（Wireshark 截图） |
| `scripts/validate_phase6.py` | 提交前自动校验 |
