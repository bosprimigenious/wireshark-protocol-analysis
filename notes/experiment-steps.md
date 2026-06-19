# 实验二：协议数据捕获操作步骤

> 本文档对应指导书第 7 节。按顺序完成四种协议的抓包，将 `.pcapng` 保存到 `captures/` 对应子目录。

## 准备工作

1. 安装 [Wireshark](https://www.wireshark.org/download.html)，安装时勾选 **Npcap**（Windows 抓包驱动）。
2. 以**管理员身份**运行 Wireshark（DHCP 抓包、ARP 清缓存需要管理员权限）。
3. 确认本机联网网卡（**WLAN**，勿选 VMware 虚拟网卡）：
   - 本机 IP：`10.122.219.108`（以 `ipconfig` 实际输出为准）
   - 默认网关：`10.122.192.1`
4. 过滤器设置详见 [`wireshark-filters.md`](wireshark-filters.md)。

### Wireshark 通用操作流程

1. 启动 Wireshark → 选择正在使用的网卡（有流量波动的那个，通常是 **WLAN**）。
2. 点击齿轮图标设置 **Capture Filter**（可选，见各协议说明）。
3. 点击蓝色鲨鱼鳍 **开始捕获**。
4. 在命令行执行下方对应操作命令。
5. 停止捕获 → **File → Save As** 保存到指定路径。
6. 在 **Display Filter** 栏输入显示过滤器，验证包是否抓全。

---

## 1. ICMP 抓包

**目标文件**：

| 文件名 | 路径 | 用途 |
|---|---|---|
| `icmp-normal.pcapng` | `captures/icmp/` | 普通 ping，分析 ICMP Echo |
| `icmp-large-packet-fragmentation.pcapng` | `captures/icmp/` | 大包 ping，分析 IP 分片 |

### 1.1 普通 ping

```
Capture Filter:  icmp
Display Filter:  icmp
```

1. 在 WLAN 网卡上开始捕获。
2. 打开 PowerShell 或 CMD，执行：

```powershell
ping www.bupt.edu.cn
```

3. 等待 4 次回复后按 `Ctrl+C` 停止 ping。
4. 停止 Wireshark 捕获，保存为 `captures/icmp/icmp-normal.pcapng`。
5. 用显示过滤器 `icmp` 检查：应能看到 **Echo (ping) request**（Type=8）和 **Echo (ping) reply**（Type=0）成对出现。

### 1.2 大包 ping（触发 IP 分片）

```
Capture Filter:  icmp
Display Filter:  icmp
```

1. 重新开始捕获。
2. 执行（Windows 用 `-l` 指定负载大小 8000 字节）：

```powershell
ping -l 8000 www.bupt.edu.cn
```

> macOS / Linux 使用：`ping -s 8000 www.bupt.edu.cn`

3. 停止捕获，保存为 `captures/icmp/icmp-large-packet-fragmentation.pcapng`。
4. 用显示过滤器 `icmp` 或 `ip.flags.mf == 1 || ip.frag_offset > 0` 检查：
   - 应看到同一 **Identification** 字段的多个 IP 分片包；
   - 最后一个分片的 **More fragments** 标志为 0。

---

## 2. DHCP 抓包

**目标文件**：`captures/dhcp/dhcp-dora.pcapng`

```
Capture Filter:  udp port 67
Display Filter:  bootp
```

> 也可用显示过滤器 `udp.port == 67`。

### 操作步骤

1. **以管理员身份**打开 Wireshark，在 WLAN 网卡上开始捕获。
2. **以管理员身份**打开 PowerShell，依次执行：

```powershell
ipconfig /release
ipconfig /renew
```

3. `ipconfig /renew` 完成后等待 3–5 秒，停止捕获。
4. 保存为 `captures/dhcp/dhcp-dora.pcapng`。
5. 用显示过滤器 `bootp` 验证，应看到完整 **DORA** 四步：
   - DHCP Discover
   - DHCP Offer
   - DHCP Request
   - DHCP ACK

### 常见问题

| 现象 | 原因 | 解决 |
|---|---|---|
| 只有 Discover，没有 Offer | 校园网/运营商可能禁止客户端自行 renew | 断开 Wi-Fi 重连，或换手机热点 |
| 抓不到任何 DHCP 包 | 选错了网卡 | 确认选 WLAN，不是 VMware 虚拟网卡 |
| 包太多找不到 DORA | 未设捕获过滤器 | 重抓，Capture Filter 填 `udp port 67` |

---

## 3. ARP 抓包

**目标文件**：`captures/arp/arp-request-reply.pcapng`

```
Capture Filter:  arp
Display Filter:  arp
```

### 操作步骤

1. 在 WLAN 网卡上开始捕获。
2. **以管理员身份**清空 ARP 缓存：

```powershell
arp -d *
```

> 若提示拒绝访问，确认 PowerShell 已用管理员运行。

3. ping 默认网关（将 IP 替换为 `ipconfig` 中的网关地址）：

```powershell
ping 10.122.192.1
```

4. 收到 1 次回复后即可 `Ctrl+C`，停止捕获。
5. 保存为 `captures/arp/arp-request-reply.pcapng`。
6. 用显示过滤器 `arp` 验证：
   - **ARP Request**（Opcode = 1）：目标 MAC 为 `00:00:00:00:00:00`，以太网帧目的地址为广播 `ff:ff:ff:ff:ff:ff`
   - **ARP Reply**（Opcode = 2）：单播回复，含网关 MAC 地址

---

## 4. TCP 抓包

**目标文件**：`captures/tcp/tcp-http-or-https.pcapng`（文件名可自定，保留在 `captures/tcp/` 即可）

### 方案 A：HTTP（推荐，字段更直观）

```
Capture Filter:  tcp port 80
Display Filter:  tcp.port == 80
```

1. 在 WLAN 网卡上开始捕获。
2. 在 PowerShell 执行（强制 IPv4）：

```powershell
curl -4 http://example.com
```

3. 页面加载完成后停止捕获并保存为 `captures/tcp/tcp-http.pcapng`。
4. 用 `tcp.stream==0` 分析 example.com 的完整握手、数据传输与 FIN 挥手。

### 方案 B：HTTPS（校园网常用）

```
Capture Filter:  tcp port 443
Display Filter:  tcp.port == 443
```

1. 开始捕获。
2. 浏览器访问：

```
https://www.baidu.com
```

3. 停止捕获并保存。

> HTTPS 载荷已加密，但 **TCP 首部**（SYN/ACK/FIN、Seq、Ack、Window、MSS）仍可完整分析。

### 验证清单

用显示过滤器筛选后，确认抓包包含：

- [ ] 三次握手：SYN → SYN+ACK → ACK
- [ ] 至少一对数据传输：PSH+ACK 数据段 + 对应 ACK 确认
- [ ] 四次挥手：FIN+ACK → ACK → FIN+ACK → ACK

若 80 端口无流量，改用方案 B（443 端口）。

---

## 抓包文件命名汇总

```
captures/
├── icmp/
│   ├── icmp-normal.pcapng
│   └── icmp-large-packet-fragmentation.pcapng
├── dhcp/
│   └── dhcp-dora.pcapng
├── arp/
│   └── arp-request-reply.pcapng
└── tcp/
    └── tcp-http-or-https.pcapng
```

完成全部抓包后，告知 Cursor 继续执行 `tasks.md` **Phase 2** 协议分析。
