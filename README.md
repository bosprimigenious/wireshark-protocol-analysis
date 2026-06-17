# BUPT Computer Network Experiment 2

北京邮电大学计算机网络实验二：协议数据的捕获和解析。

使用 Wireshark 捕获并分析 IP、ICMP、DHCP、ARP、TCP 五类协议数据，完成协议字段分析、IP 分片验证、TCP 连接过程分析和 DHCP 地址分配过程分析。

## 个人信息

| 项目 | 内容 |
|---|---|
| 姓名 | 张恒基 |
| 学号 | 2024210926 |
| 班级 | 2024211301 |

## 实验环境

- **OS**: Windows 11
- **Tool**: Wireshark + Npcap
- **Network**: 校园 Wi-Fi（WLAN）
- **本机 IP**: `10.122.219.108`（以 `ipconfig` 为准）
- **网关 IP**: `10.122.192.1`

## 协议清单

| 协议 | 分析重点 |
|---|---|
| IP | 首部字段表、校验和验证、分片验证 |
| ICMP | Echo Request / Reply、报文格式 |
| DHCP | Discover/Offer/Request/ACK、时序图、配置参数 |
| ARP | Request / Reply、字段说明、地址解析原理 |
| TCP | 首部字段表、三次握手、数据传输、四次挥手、MSS/窗口分析 |

## 目录结构

```
wireshark-protocol-analysis/
├── README.md                      仓库说明（本文件）
├── tasks.md                       详细任务清单（Cursor 逐条执行）
├── 计算机网络实验二指导书.pdf
│
├── captures/                      原始抓包数据
│   ├── icmp/                      ICMP + IP 分片
│   ├── dhcp/                      DHCP DORA
│   ├── arp/                       ARP Request/Reply
│   └── tcp/                       TCP 全流程
│
├── notes/                         协议分析笔记
│   ├── experiment-steps.md        抓包操作步骤
│   ├── wireshark-filters.md       过滤器参考
│   ├── ip-analysis.md
│   ├── icmp-analysis.md
│   ├── dhcp-analysis.md
│   ├── arp-analysis.md
│   └── tcp-analysis.md
│
├── diagrams/                      时序图源码（Mermaid）
├── scripts/                       辅助验证脚本（可选）
├── docs/                          参考资料
└── report/                        最终实验报告
    ├── lab2-report.md
    └── assets/                    报告插图
```

## 捕获过滤器速查

| 协议 | Capture Filter | Display Filter |
|---|---|---|
| ICMP | `icmp` | `icmp` |
| DHCP | `udp port 67` | `bootp` 或 `udp.port==67` |
| ARP | `arp` | `arp` |
| TCP | `tcp port 80` 或 `tcp port 443` | `tcp.port==80` 或 `tcp.port==443` |

详细说明见 [`notes/wireshark-filters.md`](notes/wireshark-filters.md)。

## 复现步骤

1. 安装 Wireshark，确认 Npcap 已安装
2. 阅读 [`notes/wireshark-filters.md`](notes/wireshark-filters.md) 设置过滤器
3. 按 [`notes/experiment-steps.md`](notes/experiment-steps.md) 逐步抓包
4. 将 `.pcapng` 文件保存到 `captures/` 对应子目录
5. 执行 `tasks.md` Phase 2–5，撰写分析笔记和报告

## 实验报告结构（指导书第 9 节）

最终报告 `report/lab2-report.md` 须包含以下章节：

| 章节 | 内容 |
|---|---|
| 一、实验目的 | 理解协议捕获与解析方法 |
| 二、实验环境 | OS、Wireshark 版本、网络环境、本机/网关 IP |
| 三、实验内容和实验步骤 | ICMP / DHCP / ARP / TCP 捕获步骤 |
| 四、IP 协议分析 | 首部字段、校验和验证、分片分析 |
| 五、ICMP 协议分析 | Echo Request/Reply 字段对比 |
| 六、DHCP 协议分析 | DORA 过程、配置参数、序列图 |
| 七、ARP 协议分析 | Request/Reply 字段、广播/单播 |
| 八、TCP 协议分析 | 首部字段、三次握手、数据传输、四次挥手 |
| 九、遇到的问题和解决方案 | 至少 2 个真实踩坑记录 |
| 十、实验心得 | 对 TCP/IP 协议栈的理解总结 |

## 任务执行顺序

```
Phase 0  目录初始化          ✅ 已完成
Phase 1  基础文档            ✅ experiment-steps + wireshark-filters
Phase 2  协议分析笔记        ✅ 5 份 notes 已填真实字段
Phase 3  Mermaid 时序图      ✅ diagrams/*.mmd
Phase 4  Python 校验脚本     ✅ verify_ipv4_checksum.py
Phase 5  合成实验报告        ✅ lab2-report.typ + PDF
Phase 6  最终检查与提交      ✅ validate_phase6.py 全通过
```

详见 [`tasks.md`](tasks.md)。
