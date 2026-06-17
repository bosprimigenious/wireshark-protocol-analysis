# TCP 协议分析

> 抓包文件：`captures/tcp/tcp-https.pcapng`（`curl https://www.baidu.com`，连接 `10.122.219.108:62451 ↔ 220.181.111.1:443`）

## 2.5.1 TCP 首部字段表

以 **帧 29**（客户端 SYN）为例：

| 字段 | 长度 | 捕获示例 | 功能 |
|---|---|---|---|
| Source Port | 16 bit | 62451 | 客户端临时端口 |
| Destination Port | 16 bit | 443 | HTTPS 服务端口 |
| Sequence Number | 32 bit | 3410032806 | 初始序号（ISN） |
| Acknowledgment Number | 32 bit | 0 | SYN 包无确认号 |
| Header Length | 4 bit | 32 bytes (8) | 含 MSS 选项 |
| Flags | 若干位 | SYN | 请求建立连接 |
| Window Size | 16 bit | 65535 | 接收窗口 |
| Checksum | 16 bit | 0x83DC | 差错检测 |
| Urgent Pointer | 16 bit | 0 | 无紧急数据 |
| Options (MSS) | 可变 | 1460 | 最大段长度 |

## 2.5.2 三次握手分析

连接 `10.122.219.108:62451 → 220.181.111.1:443`（帧 29–31）：

| 步骤 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|
| 1 | Client→Server | SYN | 3410032806 | — | 客户端请求连接 |
| 2 | Server→Client | SYN, ACK | 208860029 | 3410032807 | 服务器确认，Ack = 3410032806 + 1 ✓ |
| 3 | Client→Server | ACK | 3410032807 | 208860030 | 连接建立，Ack = 208860029 + 1 ✓ |

时序图见 `diagrams/tcp-handshake.mmd`。

## 2.5.3 数据传输分析

**数据段（帧 32）**：客户端 `Seq=3410032807`，`Len=460`，Flags=PSH+ACK。

**确认段（帧 33）**：服务器 `Ack=3410033267`。

**验证**：`3410033267 = 3410032807 + 460` ✓

- **Window Size**（帧 33）：948 字节，表示服务器当前还能接收 948 字节数据（流量控制）。
- **MSS**（帧 29/30）：客户端 MSS=1460，服务器 MSS=1382，取较小值协商传输。
- **重传**（帧 40）：`Seq=208864110` 与帧 38 相同，Wireshark 标记 `tcp.analysis.retransmission`，为**超时重传**（同一数据段重复发送）。

时序图见 `diagrams/tcp-data-transfer.mmd`。

## 2.5.4 四次挥手分析

连接释放（帧 55–59，本连接以帧 58 RST 复位结束）：

| 步骤 | 帧 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|---|
| 1 | 55 | Client→Server | FIN, ACK | 3410033530 | 208868323 | 客户端请求关闭 |
| 2 | 56 | Server→Client | ACK | 208868323 | 3410033530 | 服务器确认（Ack=u） |
| 3 | 59 | Server→Client | FIN, ACK | 208868354 | 3410033530 | 服务器也请求关闭 |
| 4 | 58 | Client→Server | RST, ACK | 3410033531 | 208868354 | 客户端复位，替代最终 ACK |

*说明*：HTTPS 短连接常见 RST 快速关闭；帧 60 为服务器后续 ACK（`Seq=208868355=208868354+1`），标准四次挥手中的最终客户端 ACK 被 RST 取代。

时序图见 `diagrams/tcp-termination.mmd`。
