# ARP 协议分析

> 抓包文件：`captures/arp/arp-request-reply.pcapng`（`ping 10.122.192.1` 触发）

## 1. ARP 功能简述

ARP（Address Resolution Protocol）根据 IP 地址解析对应的 MAC 地址，使以太网帧能正确封装目的物理地址。

## 2. ARP Request / Reply 字段对比

| 字段 | Request（帧 1） | Reply（帧 2） | 功能 |
|---|---|---|---|
| Hardware Type | 1 | 1 | Ethernet |
| Protocol Type | 0x0800 | 0x0800 | IPv4 |
| Hardware Size | 6 | 6 | MAC 地址 6 字节 |
| Protocol Size | 4 | 4 | IP 地址 4 字节 |
| Opcode | 1 | 2 | 1=Request，2=Reply |
| Sender MAC | 10:4f:58:6c:24:00 | c0:35:32:78:d3:09 | 发送方 MAC |
| Sender IP | 10.122.192.1 | 10.122.219.108 | 发送方 IP |
| Target MAC | 00:00:00:00:00:00 | 10:4f:58:6c:24:00 | 目标 MAC |
| Target IP | 10.122.219.108 | 10.122.192.1 | 目标 IP |

## 3. 广播与单播

- **ARP Request（帧 1）**：Opcode=1，Target MAC 为 `00:00:00:00:00:00`（未知）。本捕获中网关 `10.122.192.1` 向本机 `10.122.219.108` 发起 ARP 询问，以太网目的地址为本机 MAC `c0:35:32:78:d3:09`（单播 ARP，RFC 允许）。
- **ARP Reply（帧 2）**：Opcode=2，本机回复自己的 MAC，以太网目的地址为网关 MAC `10:4f:58:6c:24:00`，**单播**返回。

## 4. 核心原理

**用广播（或单播）询问谁拥有某个 IP，目标主机单播返回自己的 MAC。**

本例中：网关询问「谁有 10.122.219.108」，本机以 `c0:35:32:78:d3:09` 单播回复，完成地址解析。
