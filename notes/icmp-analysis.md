# ICMP 协议分析

> 抓包文件：`captures/icmp/icmp-normal.pcapng`（`ping www.bupt.edu.cn`）

## 1. ICMP 功能简述

ICMP（Internet Control Message Protocol）是网络层控制报文协议，用于在 IP 主机与路由器之间传递差错报告与网络诊断信息。`ping` 使用 **Echo Request（Type=8）** 与 **Echo Reply（Type=0）** 检测连通性与往返时延。

## 2. Echo Request / Reply 字段对比

选定 **帧 1（Request）** 与 **帧 2（Reply）**，序号均为 17：

| 字段 | Request 取值 | Reply 取值 | 功能 |
|---|---|---|---|
| Type | 8 | 0 | 8=Echo Request，0=Echo Reply |
| Code | 0 | 0 | 对 Echo 报文均为 0 |
| Checksum | 0x4D4A | 0x554A | ICMP 报文校验和 |
| Identifier | 1 | 1 | 标识同一次 ping 会话 |
| Sequence Number | 17 | 17 | 报文序号 |
| Data | `abcdefghijklmnopqrstuvwabcdefghi`（32 字节） | 同左 | 携带测试数据 |

## 3. 会话关联说明

- **Identifier 相同**（均为 1）：表明 Request 与 Reply 属于同一次 `ping` 进程。
- **Sequence Number 对应**（均为 17）：表明这是对第 17 号 Echo 请求的应答。
- Reply 源/目的 IP 与 Request 互换：Request `10.122.219.108 → 10.3.19.2`，Reply `10.3.19.2 → 10.122.219.108`。
- Reply 的 IP TTL 为 58（途经路由器后递减），Request TTL 为 128（Windows 默认）。

**结论**：Identifier + Sequence Number 双字段匹配，可唯一确定 Request/Reply 配对关系。
