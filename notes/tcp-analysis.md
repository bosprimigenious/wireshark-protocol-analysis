# TCP 协议分析

> 抓包文件：`captures/tcp/tcp-http.pcapng`（`curl -4 http://example.com`，连接 `10.122.219.108:60247 ↔ 172.66.147.243:80`）

## 2.5.1 TCP 首部字段表

以 **帧 1**（客户端 SYN）为例：

| 字段 | 长度 | 捕获示例 | 功能 |
|---|---|---|---|
| Source Port | 16 bit | 60247 | 客户端临时端口 |
| Destination Port | 16 bit | 80 | HTTP 服务端口 |
| Sequence Number | 32 bit | 524890319 | 初始序号（ISN） |
| Acknowledgment Number | 32 bit | 0 | SYN 包无确认号 |
| Header Length | 4 bit | 32 bytes | 含 MSS 选项 |
| Flags | 若干位 | SYN | 请求建立连接 |
| Window Size | 16 bit | 65535 | 接收窗口 |
| Checksum | 16 bit | （见 Wireshark） | 差错检测 |
| Urgent Pointer | 16 bit | 0 | 无紧急数据 |
| Options (MSS) | 可变 | 1460 | 最大段长度 |

## 2.5.2 三次握手分析

连接 `10.122.219.108:60247 → 172.66.147.243:80`（帧 1–3）：

| 步骤 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|
| 1 | Client→Server | SYN | 524890319 | — | 客户端请求连接 |
| 2 | Server→Client | SYN, ACK | 4130144482 | 524890320 | Ack = 524890319 + 1 ✓ |
| 3 | Client→Server | ACK | 524890320 | 4130144483 | Ack = 4130144482 + 1 ✓ |

时序图见 `diagrams/tcp-handshake.mmd`。

## 2.5.3 数据传输分析

**数据段（帧 4）**：客户端 `Seq=524890320`，`Len=75`，Flags=PSH+ACK。

**确认段（帧 5）**：服务器 `Ack=524890395`。

**验证**：`524890395 = 524890320 + 75` ✓

- **Window Size**（帧 5）：16，服务器接收窗口。
- **MSS**（帧 1/2）：客户端 1460，服务器 1382。

时序图见 `diagrams/tcp-data-transfer.mmd`。

## 2.5.4 四次挥手分析

连接释放（帧 9–11，标准 FIN 关闭，无 RST）：

| 步骤 | 帧 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|---|
| 1 | 9 | Client→Server | FIN, ACK | 524890395 | 4130145356 | 客户端请求关闭 |
| 2 | 10 | Server→Client | FIN, ACK | 4130145356 | 524890396 | 确认并关闭，Ack = 524890395 + 1 ✓ |
| 3 | 11 | Client→Server | ACK | 524890396 | 4130145357 | 最终确认，Ack = 4130145356 + 1 ✓ |

> 帧 10 将「对 FIN 的 ACK」与「服务器 FIN」合并发送，属常见优化；逻辑上仍对应四次挥手的中间两步。

时序图见 `diagrams/tcp-termination.mmd`。
