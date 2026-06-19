// 计算机网络实验二 — 协议数据的捕获和解析
// 北京邮电大学 (BUPT)
// 编译：typst compile report/lab2-report.typ

#set document(
  title: "实验二 · 协议数据的捕获和解析",
  author: "张恒基",
  date: datetime(year: 2026, month: 6, day: 18),
)

#set text(
  font: ("SimSun", "SimHei", "Times New Roman"),
  size: 11pt,
  lang: "zh",
  hyphenate: false,
)

#set heading(numbering: "1.1", outlined: true, bookmarked: true)

#let report-page-footer = context [
  #set text(size: 9pt, fill: luma(130))
  #align(center)[第 #counter(page).display("1") 页]
]

#let report-page-header = context [
  #set text(size: 8.5pt, fill: luma(140))
  #grid(
    columns: (1fr, 1fr),
    align(left)[实验二 · 协议数据的捕获和解析],
    align(right)[北京邮电大学],
  )
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + luma(210))
]

#set page(
  paper: "a4",
  margin: (inside: 2.8cm, outside: 2.2cm, top: 2.4cm, bottom: 2.6cm),
  numbering: "1",
  header: report-page-header,
  footer: report-page-footer,
)

#set par(
  leading: 1.75em,
  first-line-indent: 2em,
  justify: true,
)

#set list(indent: 2em, spacing: 0.55em)
#set enum(indent: 2em, spacing: 0.55em)

#show table: set table(
  stroke: 0.55pt + luma(210),
  inset: (x: 10pt, y: 8pt),
  fill: (x, y) => {
    if y == 0 { rgb("#eef2ff") }
    else if calc.rem(y, 2) == 1 { white }
    else { luma(252) }
  },
)

#show figure: set figure(
  placement: none,
  gap: 0.45em,
  supplement: [图],
)

#show figure.where(kind: image): set align(center)
#show figure.where(kind: image): set block(breakable: true)
#show figure.where(kind: auto): set align(left)
#show figure.where(kind: auto): set block(width: 100%, breakable: true)

#show figure.where(kind: table): set figure(
  supplement: [表],
)
#show figure.where(kind: table): set block(width: 100%, breakable: true)

#show raw.where(block: true): set block(
  fill: luma(248),
  inset: 11pt,
  radius: 4pt,
  width: 100%,
  breakable: true,
)
#show raw.where(block: true): set text(font: ("Consolas", "Courier New"), size: 9pt)

#show raw.where(block: false): box.with(
  fill: luma(242),
  inset: (x: 4pt, y: 1pt),
  radius: 2pt,
)
#show raw.where(block: false): set text(font: ("Consolas", "Courier New"), size: 9.5pt)

#let first-level1-done = state("first-level1", false)

#show heading.where(level: 1): it => {
  context {
    if first-level1-done.get() {
      pagebreak(weak: true)
    }
    first-level1-done.update(true)
  }
  block(breakable: false, sticky: true)[
    #v(0.5cm)
    #text(size: 16pt, weight: "bold", fill: rgb("#1e3a8a"), it.body)
    #v(0.2cm)
    #line(length: 100%, stroke: 1.2pt + rgb("#3b82f6"))
    #v(0.45cm)
  ]
}

#show heading.where(level: 2): it => {
  block(breakable: false, sticky: true)[
    #v(0.55cm)
    #text(size: 13pt, weight: "bold", fill: rgb("#1e40af"), it.body)
    #v(0.18cm)
  ]
}

#show heading.where(level: 3): it => {
  block(breakable: false, sticky: true)[
    #v(0.35cm)
    #text(size: 11.5pt, weight: "bold", fill: rgb("#334155"), it.body)
    #v(0.12cm)
  ]
}

#show list: set par(first-line-indent: 0pt)
#show enum: set par(first-line-indent: 0pt)

#let keybox(title, body) = block(
  width: 100%,
  fill: rgb("#eff6ff"),
  stroke: (left: 3.5pt + rgb("#2563eb")),
  inset: (left: 14pt, top: 10pt, bottom: 10pt, right: 12pt),
  radius: (right: 4pt),
  breakable: true,
  [
    #text(weight: "bold", fill: rgb("#1e40af"))[#title]
    #v(0.35em)
    #set par(first-line-indent: 0pt, justify: true)
    #body
  ],
)

#let notebox(body) = block(
  width: 100%,
  fill: rgb("#f8fafc"),
  stroke: 0.55pt + luma(210),
  inset: 12pt,
  radius: 4pt,
  breakable: true,
  [
    #set par(first-line-indent: 0pt, justify: true)
    #text(size: 10pt, fill: luma(80))[#body]
  ],
)

#let assetshot(filename, caption) = figure(
  image("assets/" + filename, width: 92%),
  caption: caption,
)

// ── 封面 ──
#set par(first-line-indent: 0pt, justify: false, leading: 1.45em)
#set page(header: none, footer: none, numbering: none)

#align(center + top)[
  #v(2cm)
  #text(size: 14pt, tracking: 0.12em, fill: rgb("#64748b"))[
    北京邮电大学 · 计算机网络实验
  ]
  #v(1.2cm)
  #text(size: 28pt, weight: "bold", fill: rgb("#1e3a8a"))[协议数据的捕获和解析]
  #v(0.45cm)
  #line(length: 46%, stroke: 2.5pt + rgb("#3b82f6"))
  #v(0.5cm)
  #text(size: 17pt, fill: rgb("#475569"))[实验二 · 实验报告]
  #v(1.1cm)
  #block(
    width: 72%,
    inset: (x: 24pt, y: 20pt),
    stroke: 0.75pt + luma(210),
    radius: 8pt,
    fill: luma(252),
    [
      #set par(first-line-indent: 0pt, leading: 1.5em)
      #grid(
        columns: (3.2cm, 1fr),
        column-gutter: 14pt,
        row-gutter: 14pt,
        align: (right + top, left + top),
        text(weight: "bold", fill: rgb("#334155"))[姓　　名],
        [张恒基],
        text(weight: "bold", fill: rgb("#334155"))[学　　号],
        [2024210926],
        text(weight: "bold", fill: rgb("#334155"))[班　　级],
        [2024211301],
        text(weight: "bold", fill: rgb("#334155"))[完成日期],
        [2026 年 6 月],
      )
    ],
  )
]

#place(bottom + center, scope: "parent", float: true, dy: -2.4cm)[
  #align(center)[
    #text(size: 15pt, fill: rgb("#334155"))[北京邮电大学]
    #v(0.3cm)
    #text(size: 10.5pt, fill: rgb("#94a3b8"))[
      Beijing University of Posts and Telecommunications
    ]
  ]
]

#pagebreak()

// ── 摘要 ──
#set page(header: none, footer: report-page-footer, numbering: none)

#heading(level: 1, numbering: none, outlined: true, bookmarked: true)[摘要]
#v(0.2cm)
#set par(first-line-indent: 2em, justify: true)

本报告围绕北京邮电大学计算机网络实验二「协议数据的捕获和解析」，在 Windows 11 校园网环境下使用 Wireshark 对 IP、ICMP、DHCP、ARP、TCP 五类典型协议进行抓包与字段级分析。实验依次完成 ICMP ping（含大包分片）、DHCP 地址申请（DORA）、ARP 地址解析以及 TCP 连接建立、数据传输与释放全过程的捕获；在 Wireshark 中展开协议树，抄录首部字段，验证 IPv4 首部校验和算法，分析 IP 分片标识与偏移关系，对比 ICMP Echo 请求/应答、ARP 广播/单播差异，并追踪 TCP 三次握手、确认应答与四次挥手中的序号规律。

全文按指导书第 9 节结构组织，所有字段值均从 `captures/` 下 `.pcapng` 经 tshark 解析抄录，并附字段摘录图与 Mermaid 时序图。

#v(0.8em)
#set par(first-line-indent: 0pt)
*关键词*：Wireshark · IP 分片 · ICMP · DHCP · ARP · TCP 握手

#pagebreak()

// ── 目录 ──
#set page(header: none, footer: report-page-footer, numbering: none)
#set heading(numbering: none)

#heading(level: 1, numbering: none, outlined: false, bookmarked: true)[目录]
#v(0.4cm)

#outline(
  depth: 2,
  indent: 1.8em,
  title: none,
)

#set heading(numbering: "1.1")
#set page(numbering: "1")
#counter(page).update(1)

#pagebreak()

= 实验目的

通过本实验，我希望达成以下目标：

+ *掌握网络协议分析仪的使用方法*：熟悉 Wireshark 的捕获过滤器、显示过滤器，以及 Packet List / Packet Detail / Packet Bytes 三栏的协同分析方式。
+ *理解 IP 层数据报结构*：能够读懂 IPv4 首部各字段含义，手工验证首部校验和，并解释大包 ping 触发的 IP 分片机制。
+ *认识常见网络控制协议*：分析 ICMP 诊断报文、DHCP 动态配置流程、ARP 地址解析过程，建立「协议字段 ↔ 网络行为」的对应关系。
+ *深入理解 TCP 可靠传输*：从真实抓包中观察三次握手、序号确认、窗口与 MSS，以及连接释放的四次挥手过程。

= 实验环境

#figure(
  table(
    columns: (3.2cm, 1fr),
    align: (right, left),
    [*操作系统*], [Windows 11],
    [*抓包工具*], [Wireshark + Npcap],
    [*网络环境*], [校园 Wi-Fi（WLAN）],
    [*本机 IP*], [`10.122.219.108`],
    [*子网掩码*], [`255.255.192.0`],
    [*默认网关*], [`10.122.192.1`],
    [*本机 MAC*], [`c0:35:32:78:d3:09`（以 `ipconfig /all` 为准）],
  ),
  caption: [实验软硬件环境],
)

= 实验内容和实验步骤

== 实验任务

本实验需完成以下五项协议分析任务：

#enum[
  IP 协议：首部字段表、首部校验和验证、分片分析
  ICMP 协议：Echo Request / Reply 字段对比
  DHCP 协议：DORA 四阶段与配置参数提取
  ARP 协议：Request / Reply 字段与广播/单播分析
  TCP 协议：首部字段、三次握手、数据传输、四次挥手
]

== ICMP 数据捕获

#keybox[过滤器与命令][
  - Capture Filter：`icmp`
  - Display Filter：`icmp`
  - 普通 ping：`ping www.bupt.edu.cn`
  - 大包分片：`ping -l 8000 10.122.192.1`
]

操作步骤：在 WLAN 网卡开始捕获 → 执行 ping 命令 → 停止捕获 → 分别保存为 `captures/icmp/icmp-normal.pcapng` 与 `captures/icmp/icmp-large-packet-fragmentation.pcapng`。

== DHCP 数据捕获

#keybox[过滤器与命令][
  - Capture Filter：`udp port 67`
  - Display Filter：`bootp`
  - 释放 IP：`ipconfig /release`
  - 重新申请：`ipconfig /renew`（需管理员权限）
]

保存为 `captures/dhcp/dhcp-dora.pcapng`，验证 Transaction ID 相同的 Discover / Offer / Request / ACK 四包齐全。

== ARP 数据捕获

#keybox[过滤器与命令][
  - Capture Filter：`arp`
  - Display Filter：`arp`
  - 清空缓存：`arp -d *`
  - 触发解析：`ping 10.122.192.1`
]

保存为 `captures/arp/arp-request-reply.pcapng`。

== TCP 数据捕获

#keybox[过滤器与命令][
  - Capture Filter：`tcp port 80`
  - Display Filter：`tcp.port == 80`
  - 触发流量：`curl -4 http://example.com`
]

保存为 `captures/tcp/tcp-http.pcapng`，确认含 SYN 握手、数据段与 FIN 挥手（`tcp.stream==0`）。

= IP 协议分析

== IP 首部字段

从帧 1（ICMP Echo Request，`10.122.219.108 → 10.3.19.2`）抄录 IPv4 首部：

#figure(
  table(
    columns: (3.5cm, 3.5cm, 1.8cm, 1fr),
    align: (left, center, center, left),
    table.header([字段], [捕获值], [长度], [功能说明]),
    [Version], [4], [4 bit], [IPv4],
    [Header Length], [20 bytes (5)], [4 bit], [首部长度，单位 4 字节],
    [Differentiated Services], [0x00], [8 bit], [DSCP/ECN 均为 0],
    [Total Length], [60], [16 bit], [IP 数据报总长度（字节）],
    [Identification], [0xCFB5], [16 bit], [分片标识],
    [Flags], [DF=0, MF=0], [3 bit], [未分片],
    [Fragment Offset], [0], [13 bit], [分片偏移（×8 字节）],
    [Time to Live], [128], [8 bit], [生存时间 TTL],
    [Protocol], [ICMP (1)], [8 bit], [上层协议类型],
    [Header Checksum], [0x6820], [16 bit], [首部校验和],
    [Source Address], [10.122.219.108], [32 bit], [源 IP],
    [Destination Address], [10.3.19.2], [32 bit], [目的 IP],
  ),
  caption: [IPv4 首部字段（帧 1）],
)

#assetshot("ip-header.png", [IPv4 首部字段摘录（tshark 解析生成）])

== IP 首部校验和验证

IPv4 首部校验和采用 *16 位反码求和* 算法：校验和字段置零 → 16 bit 分组求和（溢出回卷）→ 按位取反。

#keybox[验证记录（帧 1）][
  1. 20 字节首部十六进制：`4500 003c cfb5 0000 8001 6820 0a7a db6c 0a03 1302`\
  2. 校验和置零：`4500 003c cfb5 0000 8001 0000 0a7a db6c 0a03 1302`\
  3. 10 组反码相加终值：`0x97DF`\
  4. 取反结果：`0x6820` = Wireshark 显示值 → *一致* ✓
]

`scripts/verify_ipv4_checksum.py` 交叉验证输出同为 `0x6820`。

== IP 分片分析

`ping -l 8000` 抓包中 Identification = `0xCFBA` 的 6 个出站分片（帧 13–18）：

#figure(
  table(
    columns: (2.2cm, 2.8cm, 2.5cm, 2.8cm, 2.5cm),
    align: center,
    table.header([分片序号], [Identification], [MF], [Fragment Offset], [Total Length]),
    [1], [0xCFBA], [1], [0], [1500],
    [2], [0xCFBA], [1], [185], [1500],
    [3], [0xCFBA], [1], [370], [1500],
    [4], [0xCFBA], [1], [555], [1500],
    [5], [0xCFBA], [1], [740], [1500],
    [6], [0xCFBA], [0], [925], [628],
  ),
  caption: [同一原始数据报的分片对比],
)

*分析要点*：Identification 均为 0xCFBA；前 5 片 MF=1，末片 MF=0；Fragment Offset 递增（0→185→…→925），接收端按偏移重组。

#assetshot("ip-fragmentation.png", [IP 分片字段对比摘录])

= ICMP 协议分析

ICMP 工作在网络层，用于差错报告与网络诊断。`ping` 使用 Type 8（Echo Request）与 Type 0（Echo Reply）。

#figure(
  table(
    columns: (3cm, 3cm, 3cm, 1fr),
    align: (left, center, center, left),
    table.header([字段], [Request], [Reply], [功能]),
    [Type], [8], [0], [报文类型],
    [Code], [0], [0], [类型细分],
    [Checksum], [0x4D4A], [0x554A], [ICMP 校验和],
    [Identifier], [1], [1], [ping 会话标识],
    [Sequence Number], [17], [17], [序号],
    [Data], [32 字节 abc…], [同 Request], [携带数据],
  ),
  caption: [ICMP Echo 请求与应答字段对比（帧 1 & 2）],
)

*会话关联*：Identifier 均为 1，Sequence Number 均为 17，且源/目的 IP 互换，证明为同一次 ping 交互。

#assetshot("icmp-echo.png", [ICMP Echo Request / Reply 字段摘录])

= DHCP 协议分析

== DHCP 报文过程（DORA）

Transaction ID = `0x348015F3` 的四包（帧 2–5）：

#figure(
  table(
    columns: (1.2cm, 2.8cm, 3cm, 3cm, 1fr),
    align: center,
    table.header([阶段], [报文类型], [源地址], [目的地址], [主要作用]),
    [1], [DHCP Discover], [0.0.0.0], [255.255.255.255], [客户端广播寻找服务器],
    [2], [DHCP Offer], [10.3.9.2], [10.122.219.108], [服务器单播提供 IP],
    [3], [DHCP Request], [0.0.0.0], [255.255.255.255], [客户端广播请求使用],
    [4], [DHCP ACK], [10.3.9.2], [10.122.219.108], [服务器单播确认分配],
  ),
  caption: [DHCP DORA 四阶段],
)

#assetshot("dhcp-dora.png", [DHCP DORA 流程摘录])

#figure(
  ```mermaid
  sequenceDiagram
    participant C as Client (0.0.0.0)
    participant S as DHCP Server (10.3.9.2)
    C->>S: DHCP Discover (广播)
    S-->>C: DHCP Offer (单播 10.122.219.108)
    C->>S: DHCP Request (广播)
    S-->>C: DHCP ACK (单播 10.122.219.108)
  ```,
  caption: [DHCP DORA 消息序列图],
)

== DHCP 字段和配置参数

从 DHCP ACK（帧 5）提取：

#figure(
  table(
    columns: (3.5cm, 1.5cm, 3.5cm, 1fr),
    align: (left, center, center, left),
    table.header([参数], [Option], [捕获值], [含义]),
    [Your IP Address], [—], [10.122.219.108], [分配给客户端的 IP],
    [Subnet Mask], [1], [255.255.192.0], [子网掩码],
    [Router], [3], [10.122.192.1], [默认网关],
    [Domain Name Server], [6], [10.3.9.5, 10.3.9.4, 10.3.9.6], [DNS 服务器],
    [IP Address Lease Time], [51], [3600（1 小时）], [租约时间],
    [DHCP Server Identifier], [54], [10.3.9.2], [DHCP 服务器标识],
  ),
  caption: [DHCP ACK 配置参数],
)

*服务器角色*：DHCP 服务器为校园网 `10.3.9.2`，非网关 `10.122.192.1`；giaddr 为 0，无 DHCP Relay。

= ARP 协议分析

ARP 根据 IP 地址解析 MAC 地址。本捕获中网关发起 ARP Request，本机单播 Reply。

#figure(
  table(
    columns: (3cm, 3.2cm, 3.2cm, 1fr),
    align: (left, center, center, left),
    table.header([字段], [Request], [Reply], [功能]),
    [Hardware Type], [1], [1], [Ethernet],
    [Protocol Type], [0x0800], [0x0800], [IPv4],
    [Hardware Size], [6], [6], [MAC 6 字节],
    [Protocol Size], [4], [4], [IP 4 字节],
    [Opcode], [1], [2], [请求 / 应答],
    [Sender MAC], [10:4f:58:6c:24:00], [c0:35:32:78:d3:09], [发送方 MAC],
    [Sender IP], [10.122.192.1], [10.122.219.108], [发送方 IP],
    [Target MAC], [00:00:00:00:00:00], [10:4f:58:6c:24:00], [目标 MAC],
    [Target IP], [10.122.219.108], [10.122.192.1], [目标 IP],
  ),
  caption: [ARP Request / Reply 字段对比],
)

*核心原理*：用广播（或单播）询问谁拥有某 IP，目标主机单播返回自己的 MAC。

#assetshot("arp-request-reply.png", [ARP Request / Reply 字段摘录])

= TCP 协议分析

== TCP 首部字段

以帧 1（客户端 SYN，`60247 → 80`，`http://example.com`）为例：

#figure(
  table(
    columns: (3.5cm, 1.8cm, 3.5cm, 1fr),
    align: (left, center, center, left),
    table.header([字段], [长度], [捕获示例], [功能]),
    [Source Port], [16 bit], [60247], [源端口],
    [Destination Port], [16 bit], [80], [HTTP 端口],
    [Sequence Number], [32 bit], [524890319], [初始序号 ISN],
    [Acknowledgment Number], [32 bit], [0], [SYN 无确认号],
    [Header Length], [4 bit], [32 bytes], [含 MSS 选项],
    [Flags], [若干位], [SYN], [请求连接],
    [Window Size], [16 bit], [65535], [接收窗口],
    [Urgent Pointer], [16 bit], [0], [无紧急数据],
    [Options (MSS)], [可变], [1460], [最大段长度],
  ),
  caption: [TCP 首部字段（帧 1）],
)

== 三次握手

连接 `10.122.219.108:60247 ↔ 172.66.147.243:80`（帧 1–3）：

#figure(
  table(
    columns: (1cm, 2.5cm, 2.5cm, 3cm, 3cm, 1fr),
    align: center,
    table.header([步骤], [方向], [Flags], [Seq], [Ack], [说明]),
    [1], [Client→Server], [SYN], [524890319], [—], [客户端请求连接],
    [2], [Server→Client], [SYN, ACK], [4130144482], [524890320], [Ack = Seq+1 ✓],
    [3], [Client→Server], [ACK], [524890320], [4130144483], [Ack = Seq+1 ✓],
  ),
  caption: [TCP 三次握手],
)

#assetshot("tcp-handshake.png", [TCP 三次握手 Wireshark 截图])

#figure(
  ```mermaid
  sequenceDiagram
    participant C as Client
    participant S as Server
    C->>S: SYN Seq=524890319
    S->>C: SYN+ACK Seq=4130144482 Ack=524890320
    C->>S: ACK Seq=524890320 Ack=4130144483
  ```,
  caption: [TCP 三次握手时序图],
)

== 数据传输

帧 4 客户端发送 `Seq=524890320, Len=75`；帧 5 服务器 `Ack=524890395`。

验证：`524890395 = 524890320 + 75` ✓

+ *Window Size*（帧 5）：16 字节。
+ *MSS*：客户端 1460，服务器 1382。

#assetshot("tcp-data.png", [TCP 数据传输 Wireshark 截图])

#figure(
  ```mermaid
  sequenceDiagram
    participant C as Client
    participant S as Server
    C->>S: PSH+ACK Seq=524890320 Len=75
    S->>C: ACK Ack=524890395 Win=16
  ```,
  caption: [TCP 数据传输与确认示意],
)

== 四次挥手

帧 9–11（标准 FIN 关闭，`tcp-http.pcapng` 流 0）：

#figure(
  table(
    columns: (0.8cm, 1cm, 2.8cm, 2.5cm, 3cm, 3cm, 1fr),
    align: center,
    table.header([步骤], [帧], [方向], [Flags], [Seq], [Ack], [说明]),
    [1], [9], [Client→Server], [FIN, ACK], [524890395], [4130145356], [请求关闭],
    [2], [10], [Server→Client], [FIN, ACK], [4130145356], [524890396], [Ack = Seq+1 ✓],
    [3], [11], [Client→Server], [ACK], [524890396], [4130145357], [Ack = Seq+1 ✓],
  ),
  caption: [TCP 四次挥手],
)

#assetshot("tcp-teardown.png", [TCP 四次挥手 Wireshark 截图])

#figure(
  ```mermaid
  sequenceDiagram
    participant C as Client
    participant S as Server
    C->>S: FIN+ACK Seq=524890395
    S->>C: FIN+ACK Seq=4130145356 Ack=524890396
    C->>S: ACK Ack=4130145357
  ```,
  caption: [TCP 四次挥手时序图],
)

= 实验中遇到的问题和解决方案

+ *DHCP 先出现 Release 包*\
  现象：`ipconfig /release` 产生 DHCP Release（帧 1），与后续 DORA 的 Transaction ID 不同。\
  解决：分析时按 Transaction ID `0x348015F3` 筛选帧 2–5，忽略 Release 帧。

+ *ARP 由网关主动询问*\
  现象：Request 由网关 `10.122.192.1` 发出，非本机广播询问网关。\
  解决：仍为一组有效 Opcode 1/2 配对，重点分析字段与单播回复机制。

+ *TCP 改用 HTTP 80 端口*\
  现象：HTTPS 连接常以 RST 快速关闭，不符合四次挥手分析。\
  解决：`curl -4 http://example.com`，保存 `tcp-http.pcapng`，使用 `tcp.stream==0` 分析。

= 实验心得

通过本次实验，我将 TCP/IP 协议栈与真实流量一一对应：Wireshark 三栏让抽象首部变成可验证的数据；手工计算 IP 校验和（`0x6820`）加深了对反码求和的理解；IP 分片表直观展示了 MTU 限制；DHCP 四步广播/单播差异、ARP 地址解析、TCP 序号 +1 规律，都在抓包中得到印证。今后排查网络问题，我会先用显示过滤器定位，再逐层展开协议树分析。

#pagebreak()
#set par(first-line-indent: 0pt)

#notebox[
  *编译*：`typst compile report/lab2-report.typ report/lab2-report.pdf`\
  *抓包文件*：`captures/icmp/`、`dhcp/`、`arp/`、`tcp/`\
  *插图生成*：`python scripts/generate_report_assets.py`
]
