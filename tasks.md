# Tasks: 计算机网络实验二 — 协议数据的捕获和解析

> **使用说明**：本文件供 Cursor 逐任务执行。每个 task 标明了输入文件、输出文件、具体要求和验收标准。按 Phase 顺序执行，Phase 1 必须最先完成，Phase 2-4 可部分并行，Phase 5 最后执行。

---

## Phase 0：仓库初始化（必须先做）

### Task 0.1 — 创建目录结构
- **输出**：完整目录树
- **操作**：在仓库根目录下创建以下空目录：
  - `report/assets/`
  - `captures/icmp/`
  - `captures/dhcp/`
  - `captures/arp/`
  - `captures/tcp/`
  - `notes/`
  - `diagrams/`
  - `scripts/`
  - `docs/`
- **验收**：`ls -R` 能看到上述所有目录

### Task 0.2 — 创建空白占位文件
- **输出**：各目录下的空 `.gitkeep` 或初始空白文件
- **操作**：
  - `notes/` 下创建 7 个空文件：
    - `experiment-steps.md`
    - `wireshark-filters.md`
    - `ip-analysis.md`
    - `icmp-analysis.md`
    - `dhcp-analysis.md`
    - `arp-analysis.md`
    - `tcp-analysis.md`
  - `report/` 下创建空白 `lab2-report.md`
- **验收**：`find . -name "*.md"` 能看到这些文件

---

## Phase 1：基础文档（README 和实验元信息）

### Task 1.1 — 完善 README.md
- **输入**：仓库根目录下已有的 `README.md`（框架已写好）
- **输出**：完善后的 `README.md`
- **要求**：
  - 确认目录结构图与实际一致
  - 根据指导书 PDF 第 9 节，确认报告要求章节已列出
  - 补充你的个人信息（姓名、学号、班级）
- **验收**：GitHub 上打开仓库首页，README 内容完整可读

### Task 1.2 — 撰写 notes/experiment-steps.md
- **输入**：指导书 PDF 第 7 节（实验步骤）
- **输出**：`notes/experiment-steps.md`
- **要求**：用中文写清以下每一步的具体命令和操作：
  1. **ICMP 抓包**
     - 普通 ping：`ping www.bupt.edu.cn`
     - 大包 ping（用于 IP 分片）：`ping -l 8000 www.bupt.edu.cn`（Windows）或 `ping -s 8000 www.bupt.edu.cn`（Mac）
     - Wireshark 显示过滤器：`icmp`
  2. **DHCP 抓包**
     - 释放 IP：`ipconfig /release`（Windows）
     - 重新申请：`ipconfig /renew`（Windows）
     - Wireshark 显示过滤器：`bootp` 或 `udp.port==67`
  3. **ARP 抓包**
     - 清空 ARP 缓存：`arp -d *`（Windows）
     - 然后 ping 网关（如 `ping 192.168.1.1`）
     - Wireshark 显示过滤器：`arp`
  4. **TCP 抓包**
     - 打开浏览器访问 `http://example.com`（HTTP 80 端口优先）或 `https://www.baidu.com`（HTTPS 443）
     - Wireshark 显示过滤器：`tcp.port==80` 或 `tcp.port==443`
- **验收**：另一个同学照着文档能复现所有抓包操作

### Task 1.3 — 撰写 notes/wireshark-filters.md
- **输入**：指导书 PDF 第 7.1 节 + 第 8.2 节
- **输出**：`notes/wireshark-filters.md`
- **要求**：
  - 解释 Capture Filter 和 Display Filter 的区别
  - 列出 5 个协议的 Capture Filter 和 Display Filter（表格）
  - 列出常用的 Display Filter 语法（`ip.src==`, `tcp.port==`, `icmp.type==`, `bootp.option.dhcp==` 等）
  - 附一个 Wireshark 主窗口截图示例（Packet List / Packet Detail / Packet Byte 三栏标注）
- **验收**：表格完整，新人能直接照抄过滤器

---

## Phase 2：协议分析笔记（每个协议一个文件）

### Task 2.1 — 撰写 notes/ip-analysis.md
- **输入**：你抓到的 ICMP 大包（`captures/icmp/icmp-large-packet-fragmentation.pcapng`）
- **输出**：`notes/ip-analysis.md`
- **要求**：必须包含以下三个子章节

#### 2.1.1 IP 首部字段表
- 从 Wireshark 中选定一个承载 ICMP Echo Request 的 IPv4 包
- 抄录以下字段到表格：

| 字段 | 捕获值 | 长度 | 功能说明 |
|---|---|---|---|
| Version | 4 | 4 bit | IPv4 |
| Header Length | （从 Wireshark 读） | 4 bit | IP 首部长度，单位 4 字节 |
| Differentiated Services | （读） | 8 bit | 服务类型 |
| Total Length | （读） | 16 bit | IP 数据报总长度 |
| Identification | （读，十六进制） | 16 bit | 分片标识 |
| Flags | （读） | 3 bit | DF/MF 标志 |
| Fragment Offset | （读） | 13 bit | 分片偏移量 |
| Time to Live | （读） | 8 bit | 生存时间 |
| Protocol | ICMP (1) | 8 bit | 上层协议 |
| Header Checksum | （读，十六进制） | 16 bit | 首部校验和 |
| Source Address | （读） | 32 bit | 源 IP |
| Destination Address | （读） | 32 bit | 目的 IP |

- **禁止**：写"待填"或占位符，必须从真实抓包数据抄录

#### 2.1.2 IP 校验和验证
- 解释 IPv4 首部校验和的计算原理（反码求和）
- 写出你选定包的验证过程：
  1. 从 Wireshark Packet Byte 窗口复制 IPv4 首部十六进制（20 字节，40 个 hex 字符）
  2. 手动将校验和字段（第 11-12 字节）置零
  3. 按 16 bit 一组分成 10 组
  4. 反码相加
  5. 取反得到校验和
  6. 与 Wireshark 显示的 Header Checksum 对比
- 附上每一步的中间值，不能只给结论

#### 2.1.3 IP 分片验证
- 从大包 ping 的抓包中选取属于同一 Identification 的多个分片
- 用表格列出每个分片的：
  - Identification
  - More fragments 标志
  - Fragment Offset
  - Total Length
- 用文字说明：为什么这些字段证明它们属于同一个原始 IP 数据报
- 画出分片示意图（可用 ASCII art 或 Mermaid）

### Task 2.2 — 撰写 notes/icmp-analysis.md
- **输入**：`captures/icmp/icmp-normal.pcapng`
- **输出**：`notes/icmp-analysis.md`
- **要求**：
  1. 简述 ICMP 的功能（网络层控制报文协议，差错报告 + 网络诊断）
  2. 从 Wireshark 中选一对 Echo Request (Type=8) 和 Echo Reply (Type=0)
  3. 用表格列出 ICMP 报文各字段：

| 字段 | Request 取值 | Reply 取值 | 功能 |
|---|---|---|---|
| Type | 8 | 0 | 标识 ICMP 报文类型 |
| Code | （读） | （读） | 类型的进一步细分 |
| Checksum | （读） | （读） | ICMP 报文校验 |
| Identifier | （读） | （读） | 标识一次 ping 会话 |
| Sequence Number | （读） | （读） | ping 报文序号 |
| Data | （读） | （读） | 携带数据 |

  4. 说明 Request 和 Reply 的 Identifier 相同、Sequence Number 对应 → 证明是同一会话
- **验收**：字段值真实，能区分 Request 和 Reply

### Task 2.3 — 撰写 notes/dhcp-analysis.md
- **输入**：`captures/dhcp/dhcp-dora.pcapng`
- **输出**：`notes/dhcp-analysis.md`
- **要求**：
  1. 简述 DHCP 功能（动态主机配置协议，自动分配 IP/子网掩码/网关/DNS/租约）
  2. 找到 Transaction ID 相同的 4 个包（Discover / Offer / Request / ACK）
  3. 用表格列出 DORA 四阶段：

| 阶段 | 报文类型 | 源地址 | 目的地址 | 主要作用 |
|---|---|---|---|---|
| 1 | DHCP Discover | 0.0.0.0 | 255.255.255.255 | 客户端广播寻找服务器 |
| 2 | DHCP Offer | （读） | （读） | 服务器提供 IP |
| 3 | DHCP Request | （读） | （读） | 客户端请求使用 |
| 4 | DHCP ACK | （读） | （读） | 服务器确认分配 |

  4. 从 DHCP ACK 包中提取以下参数（展开 Option 字段）：

| 参数 | Option | 捕获值 | 含义 |
|---|---|---|---|
| Your IP Address | — | （读） | 分配给客户端的 IP |
| Subnet Mask | 1 | （读） | 子网掩码 |
| Router | 3 | （读） | 默认网关 |
| Domain Name Server | 6 | （读） | DNS 服务器 |
| IP Address Lease Time | 51 | （读） | 租约时间 |
| DHCP Server Identifier | 54 | （读） | DHCP 服务器标识 |

  5. 判断你的 DHCP 服务器是否由路由器充当？是否有 DHCP Relay？
  6. **画出 DHCP 消息序列图**（用 Mermaid，保存到 `diagrams/dhcp-sequence.mmd`，并在 `notes/dhcp-analysis.md` 中引用）
- **验收**：4 个包的 Transaction ID 一致，ACK 参数完整

### Task 2.4 — 撰写 notes/arp-analysis.md
- **输入**：`captures/arp/arp-request-reply.pcapng`
- **输出**：`notes/arp-analysis.md`
- **要求**：
  1. 简述 ARP 功能（根据 IP 地址解析 MAC 地址）
  2. 选一对 ARP Request (Opcode=1) 和 ARP Reply (Opcode=2)
  3. 用表格列出 ARP 报文字段：

| 字段 | Request 值 | Reply 值 | 功能 |
|---|---|---|---|
| Hardware Type | （读） | （读） | 硬件类型，Ethernet=1 |
| Protocol Type | （读） | （读） | 协议类型，IPv4=0x0800 |
| Hardware Size | （读） | （读） | MAC 地址长度 |
| Protocol Size | （读） | （读） | IP 地址长度 |
| Opcode | 1 | 2 | 操作码 |
| Sender MAC | （读） | （读） | 发送方 MAC |
| Sender IP | （读） | （读） | 发送方 IP |
| Target MAC | 00:00:00:00:00:00 | （读） | 目标 MAC |
| Target IP | （读） | （读） | 目标 IP |

  4. 说明 ARP Request 用广播、ARP Reply 用单播
  5. 用一句话总结 ARP 核心原理："用广播询问谁拥有某个 IP，目标主机单播返回自己的 MAC"
- **验收**：字段完整，能说清广播/单播区别

### Task 2.5 — 撰写 notes/tcp-analysis.md
- **输入**：`captures/tcp/` 下的 TCP 抓包文件
- **输出**：`notes/tcp-analysis.md`
- **要求**：这是最复杂的一个，必须包含以下 4 个子章节

#### 2.5.1 TCP 首部字段表

| 字段 | 长度 | 捕获示例 | 功能 |
|---|---|---|---|
| Source Port | 16 bit | （读） | 源端口 |
| Destination Port | 16 bit | （读） | 目的端口 |
| Sequence Number | 32 bit | （读） | 发送序号 |
| Acknowledgment Number | 32 bit | （读） | 确认序号 |
| Header Length | 4 bit | （读） | TCP 首部长度 |
| Flags | 若干位 | （读） | SYN/ACK/FIN/RST 等 |
| Window Size | 16 bit | （读） | 接收窗口 |
| Checksum | 16 bit | （读） | 差错检测 |
| Urgent Pointer | 16 bit | （读） | 紧急指针 |
| Options | 可变 | （读 MSS 值） | MSS 等 |

#### 2.5.2 三次握手分析
- 选连接建立的 3 个包（SYN / SYN+ACK / ACK）
- 用表格记录每次交互：

| 步骤 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|
| 1 | Client→Server | SYN | x | — | 客户端请求连接 |
| 2 | Server→Client | SYN, ACK | y | x+1 | 服务器确认 |
| 3 | Client→Server | ACK | x+1 | y+1 | 客户端确认，连接建立 |

- 必须从真实抓包中读出 x 和 y 的具体值
- **画三次握手时序图**（Mermaid，保存到 `diagrams/tcp-handshake.mmd`）

#### 2.5.3 数据传输分析
- 选一对数据段 + 确认段
- 验证：接收方返回的 Ack = 发送方 Seq + 数据长度 (Len)
- 说明 Window Size 的含义（接收方还能收多少数据）
- 说明 MSS 的含义（单个 TCP 段最大数据长度）
- 如果抓到了重传，分析重传原因（超时重传 or 快速重传）
- **画数据传输时序图**（Mermaid，保存到 `diagrams/tcp-data-transfer.mmd`）

#### 2.5.4 四次挥手分析
- 选连接释放的 4 个包（FIN+ACK / ACK / FIN+ACK / ACK）
- 用表格记录：

| 步骤 | 方向 | Flags | Seq | Ack | 说明 |
|---|---|---|---|---|---|
| 1 | 主动方→被动方 | FIN, ACK | u | v | 请求关闭 |
| 2 | 被动方→主动方 | ACK | v | u+1 | 确认关闭请求 |
| 3 | 被动方→主动方 | FIN, ACK | v | u+1 | 被动方也请求关闭 |
| 4 | 主动方→被动方 | ACK | u+1 | v+1 | 最终确认 |

- 必须从真实抓包中读出 u 和 v 的具体值
- **画四次挥手时序图**（Mermaid，保存到 `diagrams/tcp-termination.mmd`）

- **验收**：序号/确认号的 +1 关系验证通过，时序图与表格一致

---

## Phase 3：时序图（Mermaid 源码）

### Task 3.1 — 创建 diagrams/dhcp-sequence.mmd
- **输出**：DHCP DORA 时序图（4 个参与者：Client、DHCP Server、可能的中继）
- **要求**：
  - 使用 Mermaid `sequenceDiagram`
  - 标注每个箭头的消息类型（Discover / Offer / Request / ACK）
  - 标注广播/单播
- **可参考模板**：
  ```mermaid
  sequenceDiagram
    participant C as Client
    participant S as DHCP Server
    C->>+S: DHCP Discover (Broadcast)
    S-->>-C: DHCP Offer
    C->>S: DHCP Request (Broadcast)
    S-->>C: DHCP ACK
  ```

### Task 3.2 — 创建 diagrams/tcp-handshake.mmd
- **输出**：TCP 三次握手时序图
- **要求**：标注 SYN、SYN+ACK、ACK 及各自的 Seq/Ack 值

### Task 3.3 — 创建 diagrams/tcp-data-transfer.mmd
- **输出**：TCP 数据传输时序图（含至少一次重传）
- **要求**：标注 Seq、Ack、数据长度 Len、Window 值

### Task 3.4 — 创建 diagrams/tcp-termination.mmd
- **输出**：TCP 四次挥手时序图
- **要求**：标注 FIN、ACK 及各自的 Seq/Ack 值

---

## Phase 4：辅助脚本（可选，加分项）

### Task 4.1 — 创建 scripts/verify_ipv4_checksum.py
- **输出**：Python 脚本，输入 IPv4 首部十六进制，计算并输出校验和
- **要求**：
  - 输入：20 字节 IPv4 首部（不含选项字段）的十六进制字符串
  - 自动将校验和字段（字节 10-11）置零
  - 按 16 bit 分组，反码相加
  - 输出：`0x????`
  - 附带注释说明算法步骤
- **验收**：用 Wireshark 中读到的首部十六进制作为输入，输出结果与 Wireshark 显示的 Header Checksum 一致

### Task 4.2 — 创建 scripts/README.md
- **输出**：说明每个脚本的用途和用法

---

## Phase 5：合成实验报告（最后做）

### Task 5.1 — 撰写 report/lab2-report.md
- **输入**：`notes/` 下所有分析笔记、`diagrams/` 下所有时序图、指导书 PDF 第 9 节
- **输出**：`report/lab2-report.md`
- **报告结构**（严格按指导书 9.1-9.7）：

```
# 实验二：协议数据的捕获和解析

## 一、实验目的
（用自己的话写，不要照抄指导书）

## 二、实验环境
- 操作系统：Windows 11 / macOS
- 抓包工具：Wireshark x.x.x
- 网络环境：Wi-Fi / 以太网
- 本机 IP：（从 ipconfig 读）
- 网关 IP：（从 ipconfig 读）

## 三、实验内容和实验步骤
### 3.1 实验任务
（列出 5 个协议分析任务）

### 3.2 实验步骤
#### 3.2.1 ICMP 数据捕获
（从 notes/experiment-steps.md 提取）

#### 3.2.2 DHCP 数据捕获
（从 notes/experiment-steps.md 提取）

#### 3.2.3 ARP 数据捕获
（从 notes/experiment-steps.md 提取）

#### 3.2.4 TCP 数据捕获
（从 notes/experiment-steps.md 提取）

## 四、IP 协议分析
### 4.1 IP 首部字段
（从 notes/ip-analysis.md 提取，稍作润色）

### 4.2 IP 首部校验和验证
（从 notes/ip-analysis.md 提取，附计算过程）

### 4.3 IP 分片分析
（从 notes/ip-analysis.md 提取，附分片对比表）

## 五、ICMP 协议分析
（从 notes/icmp-analysis.md 提取）

## 六、DHCP 协议分析
### 6.1 DHCP 报文过程
（从 notes/dhcp-analysis.md 提取 DORA 表格）

### 6.2 DHCP 字段和配置参数
（从 notes/dhcp-analysis.md 提取 ACK 参数表）

### 6.3 DHCP 消息序列图
（嵌入 diagrams/dhcp-sequence.mmd 渲染后的图，或放截图）

## 七、ARP 协议分析
（从 notes/arp-analysis.md 提取）

## 八、TCP 协议分析
### 8.1 TCP 首部字段
（从 notes/tcp-analysis.md 2.5.1 提取）

### 8.2 三次握手
（从 notes/tcp-analysis.md 2.5.2 提取，嵌入时序图）

### 8.3 数据传输
（从 notes/tcp-analysis.md 2.5.3 提取，嵌入时序图）

### 8.4 四次挥手
（从 notes/tcp-analysis.md 2.5.4 提取，嵌入时序图）

## 九、实验中遇到的问题和解决方案
（记录真实踩坑，至少 2 个：DHCP 抓不全、IP 分片不明显、TCP 80 端口无流量等）

## 十、实验心得
（总结通过本实验对 TCP/IP 协议栈的理解提升）
```

- **重要约束**：
  1. 每个表格必须有真实数据，不能用"待填"或占位符
  2. 每个截图引用必须标注"见图 X"
  3. 校验和计算过程必须有中间步骤
  4. TCP 序号/确认号必须验证 +1 关系
  5. 文字不能照抄指导书，用自己的话写

### Task 5.2 — 截图与插图整理
- **输出**：`report/assets/` 下的截图文件（或从 `captures/` 的 Wireshark 分析中导出）
- **需要的截图**（至少）：
  - `ip-header.png` — IP 首部字段截图（Packet Detail 展开 IP 层）
  - `ip-fragmentation.png` — IP 分片多个包的对比
  - `icmp-echo.png` — ICMP Echo Request 和 Reply 对比
  - `dhcp-dora.png` — DHCP 四个包同框
  - `arp-request-reply.png` — ARP Request 和 Reply 对比
  - `tcp-handshake.png` — TCP 三次握手三个包
  - `tcp-data.png` — TCP 数据传输（含 Seq/Ack/Window）
  - `tcp-teardown.png` — TCP 四次挥手四个包
- **操作**：用 Wireshark 截图时展开对应协议层，确保字段值可见

### Task 5.3 — 导出 PDF（可选）
- 如果老师要求 PDF 格式，用 Markdown 转 PDF 工具（如 Pandoc、Typora、VS Code 插件）
- **输出**：`report/lab2-report.pdf`

---

## Phase 6：最终检查（提交前必做）

### Task 6.1 — 字段完整性检查
- 逐行检查报告中的每个表格，确保没有"待填"/"TODO"/占位符
- 所有十六进制值前面有 `0x`
- 所有截图路径有效

### Task 6.2 — 序号/校验和交叉验证
- IP 校验和：手动计算结果 = Wireshark 显示值
- TCP 三次握手：第 2 步 Ack = 第 1 步 Seq + 1；第 3 步 Ack = 第 2 步 Seq + 1
- TCP 四次挥手：同上规则

### Task 6.3 — Git 提交
- 检查 `.gitignore` 是否生效（`.pcapng` 文件应该被提交，临时文件不应该）
- 分阶段提交（建议）：
  ```
  git add .gitignore README.md tasks.md
  git commit -m "init: project structure and task list"

  git add notes/
  git commit -m "docs: add protocol analysis notes"

  git add diagrams/
  git commit -m "docs: add sequence diagrams"

  git add report/
  git commit -m "report: complete experiment report"
  ```

---

## 执行顺序总结

```
Phase 0 (仓库初始化)
  └─> Phase 1 (基础文档)
        └─> Phase 2 (5 个协议笔记，可部分并行)
              ├─> 2.1 IP  ← 依赖 ICMP 大包抓取
              ├─> 2.2 ICMP ← 依赖 ping 抓取
              ├─> 2.3 DHCP ← 依赖 DHCP 抓取
              ├─> 2.4 ARP  ← 依赖 ARP 抓取
              └─> 2.5 TCP  ← 依赖 TCP 抓取
                    └─> Phase 3 (时序图，与 Phase 2 部分并行)
                          └─> Phase 4 (辅助脚本，可选)
                                └─> Phase 5 (合成报告)
                                      └─> Phase 6 (最终检查)
```

---

## 给 Cursor 的注意事项

1. **不要编造数据**：所有字段值必须用 `（从 Wireshark 读）` 标记的占位符，等真实抓包后替换
2. **不要跳过 Phase 1**：README 和实验步骤是写报告的基础
3. **TCP 是最复杂的**：预计占 40% 工作量，留足时间
4. **截图是证据**：没有截图支撑的字段分析不可信
5. **指导书 PDF 第 9 节是验收标准**：写完报告后对照 9.1-9.7 逐条检查
