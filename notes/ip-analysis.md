# IP 协议分析

> 抓包文件：`captures/icmp/icmp-normal.pcapng`（Echo Request，帧 1）、`captures/icmp/icmp-large-packet-fragmentation.pcapng`（分片，Identification `0xcfba`）

## 2.1 IP 首部字段表

选定 **帧 1**：本机 `10.122.219.108` → `10.3.19.2` 的 ICMP Echo Request 承载 IPv4 数据报。

| 字段 | 捕获值 | 长度 | 功能说明 |
|---|---|---|---|
| Version | 4 | 4 bit | IPv4 |
| Header Length | 20 bytes (5) | 4 bit | IP 首部长度，单位 4 字节 |
| Differentiated Services | 0x00 | 8 bit | DSCP/ECN 均为 0 |
| Total Length | 60 | 16 bit | IP 数据报总长度（含 20 字节首部） |
| Identification | 0xCFB5 | 16 bit | 分片标识 |
| Flags | DF=0, MF=0 | 3 bit | 未分片 |
| Fragment Offset | 0 | 13 bit | 分片偏移为 0 |
| Time to Live | 128 | 8 bit | 每经一跳减 1 |
| Protocol | ICMP (1) | 8 bit | 上层为 ICMP |
| Header Checksum | 0x6820 | 16 bit | 首部校验和 |
| Source Address | 10.122.219.108 | 32 bit | 源 IP（本机） |
| Destination Address | 10.3.19.2 | 32 bit | 目的 IP（`www.bupt.edu.cn` 解析地址） |

**Packet Bytes 首部十六进制（20 字节）：**

```
45 00 00 3c cf b5 00 00 80 01 68 20 0a 7a db 6c 0a 03 13 02
```

## 2.2 IP 校验和验证

### 原理

IPv4 首部校验和采用 **16 位反码求和（one's complement sum）**：

1. 将校验和字段（第 11–12 字节）置 0；
2. 将首部按 16 bit 分组求和，溢出高位回卷到低位；
3. 对结果按位取反，即为校验和。

### 验证过程（帧 1）

**步骤 1** — 复制 20 字节首部十六进制：

`4500 003c cfb5 0000 8001 6820 0a7a db6c 0a03 1302`

**步骤 2** — 校验和字段 `6820` 置零：

`4500 003c cfb5 0000 8001 0000 0a7a db6c 0a03 1302`

**步骤 3** — 按 16 bit 分成 10 组：

| 组号 | 十六进制 | 十进制 |
|---|---|---|
| 1 | 0x4500 | 17664 |
| 2 | 0x003C | 60 |
| 3 | 0xCFB5 | 53045 |
| 4 | 0x0000 | 0 |
| 5 | 0x8001 | 32769 |
| 6 | 0x0000 | 0 |
| 7 | 0x0A7A | 2682 |
| 8 | 0xDB6C | 56172 |
| 9 | 0x0A03 | 2563 |
| 10 | 0x1302 | 4866 |

**步骤 4** — 反码相加（含回卷）：

```
0x4500 + 0x003C = 0x453C
0x453C + 0xCFB5 = 0x114F1 → 回卷 → 0x14F2
0x14F2 + 0x8001 = 0x94F3
0x94F3 + 0x0A7A = 0x9F6D
0x9F6D + 0xDB6C = 0x17AD9 → 回卷 → 0x7ADA
0x7ADA + 0x0A03 = 0x84DD
0x84DD + 0x1302 = 0x97DF
```

**步骤 5** — 取反：`~0x97DF = 0x6820`

**步骤 6** — 与 Wireshark 对比：显示 `0x6820`，**一致** ✓

## 2.3 IP 分片验证

从 `ping -l 8000` 抓包中选取 **Identification = 0xCFBA**、源地址 `10.122.219.108` 的 6 个出站分片（帧 13–18）：

| 分片序号 | Identification | MF | Fragment Offset | Total Length |
|---|---|---|---|---|
| 1 | 0xCFBA | 1 | 0 | 1500 |
| 2 | 0xCFBA | 1 | 185 | 1500 |
| 3 | 0xCFBA | 1 | 370 | 1500 |
| 4 | 0xCFBA | 1 | 555 | 1500 |
| 5 | 0xCFBA | 1 | 740 | 1500 |
| 6 | 0xCFBA | 0 | 925 | 628 |

### 分析说明

- **Identification 均为 0xCFBA**：表明 6 个分片属于同一原始 IP 数据报。
- **MF 标志**：前 5 个分片 MF=1（More Fragments），最后一个 MF=0，表示分片结束。
- **Fragment Offset 递增**：0 → 185 → 370 → … → 925（单位为 8 字节），接收端按偏移重组。
- **Total Length**：除末片 628 字节外，其余各片 1500 字节（接近以太网 MTU）。

### 分片示意图

```
原始 IP 数据报（> MTU，约 8028 字节载荷）
┌──────────┬──────────┬──────────┬──────────┬──────────┬─────────┐
│ 分片1    │ 分片2    │ 分片3    │ 分片4    │ 分片5    │ 分片6   │
│ off=0    │ off=185  │ off=370  │ off=555  │ off=740  │ off=925 │
│ MF=1     │ MF=1     │ MF=1     │ MF=1     │ MF=1     │ MF=0    │
│ len=1500 │ len=1500 │ len=1500 │ len=1500 │ len=1500 │ len=628 │
└──────────┴──────────┴──────────┴──────────┴──────────┴─────────┘
         Identification = 0xCFBA（全部相同）
```
