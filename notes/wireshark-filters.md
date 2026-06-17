# Wireshark 过滤器参考

> 对应指导书第 7.1 节（捕获）和第 8.2 节（显示）。抓包前请先阅读本文档。

## 一、Capture Filter 与 Display Filter 的区别

| 对比项 | Capture Filter（捕获过滤器） | Display Filter（显示过滤器） |
|---|---|---|
| 设置位置 | 开始捕获**之前**，Capture Options 对话框 | 主窗口顶部绿色过滤栏 |
| 生效时机 | 抓包时由驱动丢弃不匹配帧，**无法恢复** | 抓包后过滤视图，**原始数据仍在** |
| 语法 | **Berkeley Packet Filter (BPF)** | **Wireshark Display Filter 语法** |
| 性能 | 减少磁盘占用，适合长时间抓包 | 不影响已捕获数据，适合事后分析 |
| 典型用途 | DHCP 抓包（`udp port 67`）减少无关流量 | 定位特定协议包（`icmp`、`bootp`） |

**建议做法**：捕获时用 Capture Filter 缩小范围；保存后用 Display Filter 精确定位分析目标。

---

## 二、五类协议过滤器对照表

### 2.1 协议级过滤器

| 协议 | Capture Filter（BPF） | Display Filter | 说明 |
|---|---|---|---|
| **ICMP** | `icmp` | `icmp` | ping 产生的 Echo Request / Reply |
| **IP 分片** | `icmp` 或 `ip` | `ip.flags.mf == 1 \|\| ip.frag_offset > 0` | 筛选分片包 |
| **DHCP** | `udp port 67` | `bootp` 或 `udp.port == 67` | DHCP 基于 BOOTP，服务端端口 67 |
| **ARP** | `arp` | `arp` | 地址解析请求/应答 |
| **TCP** | `tcp port 80` 或 `tcp port 443` | `tcp.port == 80` 或 `tcp.port == 443` | HTTP / HTTPS 流量 |

### 2.2 细分 Display Filter（分析时常用）

| 场景 | Display Filter | 用途 |
|---|---|---|
| ICMP Echo Request | `icmp.type == 8` | 只看 ping 请求 |
| ICMP Echo Reply | `icmp.type == 0` | 只看 ping 应答 |
| DHCP Discover | `bootp.option.dhcp == 1` | DORA 第 1 步 |
| DHCP Offer | `bootp.option.dhcp == 2` | DORA 第 2 步 |
| DHCP Request | `bootp.option.dhcp == 3` | DORA 第 3 步 |
| DHCP ACK | `bootp.option.dhcp == 5` | DORA 第 4 步 |
| ARP Request | `arp.opcode == 1` | 广播询问 |
| ARP Reply | `arp.opcode == 2` | 单播应答 |
| TCP SYN | `tcp.flags.syn == 1 && tcp.flags.ack == 0` | 三次握手第 1 步 |
| TCP SYN+ACK | `tcp.flags.syn == 1 && tcp.flags.ack == 1` | 三次握手第 2 步 |
| TCP FIN | `tcp.flags.fin == 1` | 连接释放 |
| TCP 重传 | `tcp.analysis.retransmission` | 定位重传包 |

---

## 三、Display Filter 常用语法

### 3.1 基本比较

```
ip.addr == 10.122.219.108       # 源或目的 IP 等于该地址
ip.src == 10.122.192.1          # 源 IP
ip.dst == 10.122.219.108        # 目的 IP
tcp.port == 443                 # 源或目的 TCP 端口
udp.port == 67                  # UDP 端口 67（DHCP 服务端）
icmp.type == 8                  # ICMP 类型
arp.opcode == 1                 # ARP 操作码
```

### 3.2 逻辑组合

```
icmp && ip.dst == 10.122.219.108          # AND
arp || icmp                                  # OR
not arp                                      # NOT
(tcp.flags.syn == 1) && (tcp.flags.ack == 0) # 括号分组
```

### 3.3 字段存在与范围

```
bootp.option.dhcp == 1          # DHCP 消息类型 = Discover
tcp.analysis.retransmission     # 存在重传分析字段
frame.number >= 10 && frame.number <= 50
```

### 3.4 按 MAC 地址

```
eth.addr == ff:ff:ff:ff:ff:ff   # 广播帧
eth.src == c0:35:32:78:d3:09    # 本机 MAC（小写，冒号分隔）
```

---

## 四、各协议推荐抓包配置

### ICMP

| 步骤 | 配置 |
|---|---|
| 网卡 | WLAN（正在上网的网卡） |
| Capture Filter | `icmp` |
| 触发命令 | `ping www.bupt.edu.cn` |
| 大包分片 | `ping -l 8000 www.bupt.edu.cn` |
| Display Filter | `icmp` |
| 保存路径 | `captures/icmp/` |

### DHCP

| 步骤 | 配置 |
|---|---|
| 网卡 | WLAN |
| Capture Filter | `udp port 67` |
| 触发命令 | `ipconfig /release` 然后 `ipconfig /renew` |
| Display Filter | `bootp` |
| 保存路径 | `captures/dhcp/dhcp-dora.pcapng` |

### ARP

| 步骤 | 配置 |
|---|---|
| 网卡 | WLAN |
| Capture Filter | `arp` |
| 触发命令 | `arp -d *` 然后 `ping <网关IP>` |
| Display Filter | `arp` |
| 保存路径 | `captures/arp/arp-request-reply.pcapng` |

### TCP

| 步骤 | 配置 |
|---|---|
| 网卡 | WLAN |
| Capture Filter | `tcp port 80` 或 `tcp port 443` |
| 触发命令 | 浏览器访问 `http://example.com` 或 `https://www.baidu.com` |
| Display Filter | `tcp.port == 80` 或 `tcp.port == 443` |
| 保存路径 | `captures/tcp/` |

---

## 五、Wireshark 主窗口说明

Wireshark 主界面分为三栏，分析协议时三者配合使用：

```
┌─────────────────────────────────────────────────────────────────┐
│  ① Packet List（包列表）                                         │
│  No. | Time | Source | Destination | Protocol | Length | Info   │
├─────────────────────────────────────────────────────────────────┤
│  ② Packet Detail（包详情）— 展开协议树查看各字段                    │
│  ▼ Frame 42: 98 bytes on wire                                   │
│    ▼ Ethernet II                                                  │
│      ▼ Internet Protocol Version 4                              │
│          Version: 4                                               │
│          Header Length: 20 bytes                                  │
│          ...                                                      │
├─────────────────────────────────────────────────────────────────┤
│  ③ Packet Bytes（十六进制字节）— 校验和计算从这里复制               │
│  4500 003c 1c46 4000 4001 0000 c0a8 0001 ...                     │
└─────────────────────────────────────────────────────────────────┘
```

| 区域 | 作用 | 本实验用途 |
|---|---|---|
| ① Packet List | 按时间列出所有捕获的包 | 筛选、定位目标包 |
| ② Packet Detail | 树形展开各层协议字段 | 抄录字段值到分析笔记 |
| ③ Packet Bytes | 原始十六进制 | IP 首部校验和手动验证 |

> **截图要求**：完成抓包后，将主窗口三栏同框截图保存到 `report/assets/wireshark-ui-example.png`，报告中引用为「见图：Wireshark 主界面」。

---

## 六、快速复制技巧

1. **复制字段值**：在 Packet Detail 中右键字段 → Copy → Value。
2. **复制十六进制**：在 Packet Bytes 中选中字节 → 右键 → Copy → …as Hex Stream。
3. **Follow Stream**：右键 TCP 包 → Follow → TCP Stream，查看完整会话（可选）。
4. **导出特定包**：File → Export Specified Packets，只保存过滤后的包。
