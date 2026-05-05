---
title: Agent 学习周记 04：让 Agent 从会说话走向会做事
date: 2026-05-05 13:00:00
categories:
  - 学习
  - AI agent
tags:
  - Agent
  - Tool Calling
  - MCP
  - LangChain
  - 学习记录
description: 第四周学习工具调用、LangChain Tool、MCP 和 Skill：LLM 负责理解和调度，工具负责执行和验证，技能把工具组合成可复用任务能力。
cover: /images/agent-learning/week4-cover.png
---

学完 Week 3 的 Prompt Engineering 后，我对 LLM 的边界更清楚了：

```text
Prompt 可以引导模型，但不能把模型变成确定性系统。
```

Week 4 开始进入另一个关键阶段：

```text
工具使用。
```

前面几周更多是在处理：

```text
用户输入
  ↓
Prompt
  ↓
LLM
  ↓
文本输出
```

这一周开始变成：

```text
用户输入
  ↓
LLM 判断要做什么
  ↓
调用外部工具
  ↓
拿到真实结果
  ↓
LLM 再组织回答或继续执行
```

这一步很重要。

因为没有工具时，Agent 其实只是一个“会说话的模型”。有了工具以后，它才开始能连接数据库、API、文件、搜索、计算器和业务系统。

![Agent 连接外部工具世界](/images/agent-learning/week4-cover.png)

## 没有工具，LLM 只能说，不能做

LLM 的核心能力还是预测下一个 token。

它可以说：

```text
我已经帮你创建订单。
```

但如果没有工具，它不会真的：

```text
写数据库
调用订单 API
发送邮件
创建文件
查询物流
修改库存
```

所以裸 LLM 有三个天然缺陷。

第一，它不能真正行动。

它能生成动作描述，但不能直接改变真实系统状态。

第二，它不天然可信。

比如你问：

```text
某只股票最近 7 天收益是多少？
```

模型可能给你一个看起来很合理的数字，但如果没有查真实行情数据，这个数字就只是语言生成结果，不是可验证事实。

第三，它没有持续状态和真实权限。

它可以在对话里扮演财务助手，但如果没有外部系统，它不会真正记录账单、维护用户状态、持续跟踪任务。

所以这周最重要的一句话是：

```text
LLM 负责理解和决策，工具负责执行和验证。
```

比如用户问：

```text
帮我查一下我最近一笔订单物流到哪里了。
```

模型不能直接回答：

```text
您的订单正在派送中。
```

除非工具真的返回了这个状态。

正确流程应该是：

```text
1. LLM 识别意图：用户要查订单物流
2. 调用订单工具：query_recent_order(user_id)
3. 拿到订单号和物流单号
4. 调用物流工具：query_tracking(tracking_no)
5. 拿到真实物流状态
6. LLM 把结果整理成自然语言回复
```

这里事实来源不是模型，而是：

```text
订单数据库
物流 API
用户身份系统
```

模型只负责把问题理解清楚，把结果讲明白。

## 工具调用不是模型执行函数

这一周还纠正了一个误解：

```text
Tool Calling 不是模型真的执行函数。
```

模型不会打开数据库，也不会运行 Python 函数。它只是输出一个结构化调用意图。

完整链路是：

```text
用户输入
  ↓
模型理解意图
  ↓
模型输出工具调用请求
  ↓
外部程序执行工具
  ↓
工具结果回传模型
  ↓
模型基于真实结果继续回答
```

比如用户问：

```text
帮我查一下今天上海的天气，顺便判断适不适合洗车。
```

系统里有一个工具：

```text
get_weather(city)
```

模型不会自己查天气，而是生成类似：

```json
{
  "name": "get_weather",
  "arguments": {
    "city": "上海"
  }
}
```

程序看到这个调用请求后，才真正执行工具。

工具返回：

```json
{
  "city": "上海",
  "weather": "小雨",
  "humidity": 90
}
```

然后模型再基于这个真实结果回答：

```text
今天上海有小雨，湿度较高，不太适合洗车。
```

![工具调用闭环](/images/agent-learning/week4-tool-call-flow.png)

所以 Tool Calling 的本质是一种协议：

```text
模型生成结构化调用意图。
程序执行工具。
程序把结果回传给模型。
模型再继续推理。
```

## Tool Schema 是模型的工具说明书

模型怎么知道有哪些工具？

靠 Tool Schema。

Tool Schema 可以理解成：

```text
工具能力说明书。
```

它至少告诉模型三件事：

```text
工具叫什么
工具能做什么
工具需要什么参数
```

比如：

```json
{
  "name": "search_orders",
  "description": "当用户需要查询真实订单状态、订单金额、下单时间或物流信息时，使用此工具从订单系统获取权威数据。",
  "parameters": {
    "type": "object",
    "properties": {
      "user_id": {
        "type": "string",
        "description": "当前登录用户 ID"
      }
    },
    "required": ["user_id"]
  }
}
```

这里最重要的不只是参数，而是：

```text
description
```

在普通代码里，注释写得差一点，程序照样能运行。

但在工具调用里，`description` 是给模型看的决策依据。它会影响模型：

```text
会不会用这个工具
什么时候用这个工具
会不会和其他工具混淆
参数该怎么填
是否应该放弃自己猜，改用工具查询
```

坏的描述是：

```json
{
  "name": "func1",
  "description": "查询数据"
}
```

模型根本不知道它查什么数据、什么时候用。

好的描述应该写清楚：

```text
适用场景
能力边界
数据来源
参数含义
什么时候不要用
```

所以 Tool Schema 不是普通文档，它直接参与模型决策。

## LangChain 里的工具调用闭环

Day 24 用 LangChain 做了一个天气查询示例。

LangChain 不会增强模型能力，它主要帮我们做三件事：

```text
1. 把 Python 函数包装成 Tool
2. 把 Tool Schema 注入给模型
3. 帮程序处理 tool_call 和 ToolMessage 的衔接
```

最小工具函数像这样：

```python
from langchain.tools import tool

@tool
def get_weather(city: str) -> str:
    """当用户询问实时天气情况时，使用该工具获取指定城市的天气信息。"""
    fake_weather_db = {
        "上海": "小雨，湿度 90%",
        "北京": "晴，温度 10°C"
    }
    return fake_weather_db.get(city, "未查询到该城市天气")
```

这里的 `@tool` 会把普通 Python 函数注册成 LangChain Tool。

函数名、参数类型和 docstring 会变成 Tool Schema。

然后把工具绑定给模型：

```python
tools = [get_weather]
tool_map = {t.name: t for t in tools}
llm_with_tools = llm.bind_tools(tools)
```

注意这句话：

```text
bind_tools 只是把工具说明交给模型。
```

它不代表模型会自己执行工具。

第一次调用模型时：

```python
response = llm_with_tools.invoke([
    HumanMessage(content="帮我查一下今天上海的天气，顺便判断适不适合洗车")
])
```

模型可能返回：

```json
[
  {
    "name": "get_weather",
    "args": {"city": "上海"},
    "id": "call_xxx"
  }
]
```

这只是调用提案。

程序还要自己执行：

```python
for call in response.tool_calls:
    tool = tool_map[call["name"]]
    result = tool.invoke(call["args"])
```

执行完成后，把结果包成 `ToolMessage`：

```python
ToolMessage(
    content=str(result),
    tool_call_id=call["id"]
)
```

然后再把 `ToolMessage` 回传给模型，让模型做第二次推理。

为什么需要第二次？

因为第一次模型只完成了：

```text
判断要不要用工具
选择哪个工具
生成参数
```

它还没有真实天气结果。

工具返回以后，模型才有条件继续：

```text
读取工具结果
判断任务是否完成
结合用户问题
组织自然语言回答
```

对于“天气 + 是否适合洗车”这个例子，工具只返回天气，模型还要进一步判断：

```text
小雨 + 湿度高 → 不适合洗车
```

这就是工具调用闭环。

## 工具执行前，代码必须守门

工具调用有一个重要边界：

```text
模型发出 tool_call，不代表系统必须执行。
```

比如模型生成：

```json
{
  "name": "delete_order",
  "arguments": {
    "order_id": "123"
  }
}
```

后端不能直接删。

执行前要检查：

```text
工具是否在白名单
参数是否合法
用户是否有权限
业务状态是否允许
是否需要二次确认
是否记录审计日志
是否有超时和失败处理
```

这和 Week 3 的结论是连在一起的：

```text
Prompt 和模型负责提出意图。
真正的权限、规则和状态变化必须由代码控制。
```

尤其是涉及：

```text
删除
退款
转账
发邮件
改库存
改权限
写数据库
```

都不能只靠模型一句话就执行。

## 工具多了以后，Prompt 会变成垃圾场

如果只有 3 个工具，直接塞给模型问题不大。

但真实 Agent 里，工具会越来越多：

```text
查订单
查物流
查库存
查用户
查退款
取消订单
创建工单
发短信
发邮件
改地址
```

这时如果把所有 Tool Schema 都塞进 Prompt，会出现几个问题。

第一，token 成本变高。

每个工具都有名称、描述、参数、示例。工具越多，上下文越长，每次调用越贵，也越慢。

第二，模型更容易选错工具。

比如：

```text
search_order
query_order_detail
get_latest_order
track_order_shipping
```

这些名字和能力太接近，如果描述边界不清，模型很容易误用。

第三，权限边界不清楚。

客服查询 Agent 可能只需要：

```text
查订单
查物流
查售后状态
```

但如果同时暴露：

```text
取消订单
退款
删除用户
修改库存
```

风险就很高。

所以工具不是越多越好。

更合理的做法是：

```text
按任务暴露工具
按权限暴露工具
按场景动态选择工具
高风险工具加审批
工具调用前做代码校验
用 Gateway / MCP 管理能力边界
```

## MCP：把工具从某个 Agent 里解耦出来

Day 25 学了 MCP。

MCP 全称是：

```text
Model Context Protocol
```

它解决的不是“模型怎么生成 tool_call”，而是更上层的问题：

```text
外部能力如何标准化接入、复用、隔离和治理。
```

传统 Tool Calling 容易变成私有接口：

```text
LangChain 写一套 Tool
AutoGen 写一套 Tool
Claude 写一套 Schema
OpenAI 写一套 Schema
换模型还要调参数格式
```

结果就是：

```text
工具不可复用
框架迁移成本高
模型一换工程大改
权限和审计分散
```

MCP 的思路是把能力做成独立服务。

大概结构是：

```text
MCP Host
  ↓
MCP Client
  ↓
MCP Server
  ↓
Resources / Tools / Prompts
```

Host 是运行 Agent 的应用，比如 Claude Desktop、Cursor、自己的 Agent 平台。

Client 是 Host 里负责协议通信的模块。

Server 是真正提供能力的独立服务。

比如：

```text
文件系统 MCP Server
数据库 MCP Server
GitHub MCP Server
企业订单 MCP Server
旅游规划 MCP Server
```

![MCP 架构：Host、Client、Server 与能力边界](/images/agent-learning/week4-mcp-architecture.png)

MCP Server 可以提供三类能力：

```text
Resources：读取资料
Tools：执行动作
Prompts：预设任务模板
```

这带来的工程价值是：

```text
一次实现，多处复用
工具和 Agent 解耦
权限可以集中治理
调用可以统一审计
不同客户端可以接同一个能力服务
```

所以我现在更愿意这样区分：

```text
Tool Calling：解决模型怎么调用工具。
MCP：解决工具能力如何标准化接入和治理。
```

## MCP 实战：Tool 和 Resource 的区别

Day 26 做了一个 TravelPlanner MCP Server。

它提供两类能力。

Tools：

```text
查询航班
查询酒店
查询天气
规划路线
```

Resources：

```text
城市热门景点
城市指南
```

比如天气查询：

```python
@mcp.tool()
async def get_weather(city: str, date: str):
    ...
```

这适合做 Tool，因为它是动态查询：

```text
需要参数：城市、日期
结果会随时间变化
通常要调用外部天气 API
每次查询可能不同
```

而城市指南：

```python
@mcp.resource("guides://{city}")
def get_city_guide(city: str) -> str:
    ...
```

这适合做 Resource，因为它是相对稳定的资料：

```text
城市背景
文化介绍
热门美食
礼仪建议
景点说明
```

可以提前整理成文档、数据库记录或知识资源，需要时按 URI 读取。

所以这周我记住了一个简单判断：

```text
Tool：执行动作 / 动态查询
Resource：读取资料 / 稳定上下文
```

这比只说“都是外部能力”清楚很多。

## 从工具到技能：会调工具不等于会做事

Day 27 学的是 Skill。

这个概念很关键，因为它把工具再往上抬了一层。

工具解决的是：

```text
能不能做一个动作。
```

技能解决的是：

```text
怎么用一组动作完成一类任务。
```

比如有一个工具：

```text
fetch_webpage(url)
```

它能抓网页内容。

但这不等于它具备“文章总结技能”。

因为文章总结还需要知道：

```text
抓取失败怎么办
正文如何清洗
如何提取标题、作者、发布时间
如何总结核心观点
如何区分事实和评论
如何引用原文依据
最终按什么模板输出
```

所以 `fetch_webpage(url)` 只是一个 Tool。

真正的文章总结 Skill 至少应该包含：

```text
1. 使用 fetch_webpage 抓取网页
2. 清洗正文，去掉导航、广告、页脚
3. 提取标题、作者、发布时间等元信息
4. 总结核心结论
5. 提炼主要观点
6. 提取关键事实、数据、案例
7. 检查是否有编造内容
8. 按 report_template.md 输出结构化报告
```

这时它才是一套可复用任务能力。

![Tool、Skill、Agent 的层级关系](/images/agent-learning/week4-tool-skill-agent.png)

Skill 通常包含：

```text
元信息 Metadata
执行指令 Instructions
脚本 Scripts
模板 Templates
参考资料 Resources
失败处理规则
```

可以这样理解：

```text
Tool：一把工具
Skill：一套做事方法
Agent：知道什么时候选什么方法，并推进目标
```

对应工程语言：

```text
Tool：原子能力
Skill：可复用工作流
Agent：目标驱动的调度系统
```

## 如果 Agent 经常选错工具，先排查什么

Week 4 复盘里有一个问题：

```text
如果一个 Agent 经常选错工具，你会优先从哪些地方排查？
```

现在我的排查顺序会是这样。

第一，看工具描述是否太模糊。

比如：

```text
查询数据
处理订单
获取信息
```

这种 description 对模型来说几乎没用。

第二，看工具边界是否重叠。

如果有多个工具都像是在“查订单”，模型就容易混。

需要明确：

```text
查最近订单用哪个
查订单详情用哪个
查物流用哪个
查退款用哪个
```

第三，看参数是否设计得清楚。

参数名、类型、必填项、时间格式、枚举值都要明确。不要让模型猜。

第四，看是不是暴露了太多无关工具。

当前任务只需要查询，就不要把删除、退款、改库存也暴露给模型。

第五，看是否缺少路由层。

工具多的时候，最好先做意图识别或动态工具选择，而不是把所有工具一次性塞给模型。

第六，看工具结果是否稳定。

如果工具返回格式经常变，模型后续推理也会不稳定。

所以工具选错不一定是“模型不聪明”，很多时候是工程接口设计不清楚。

## 这一周的完整理解

Week 4 最重要的收获，是把几个概念的边界分清楚。

LLM：

```text
理解意图
选择工具
提取参数
解释结果
组织回答
```

Tool：

```text
执行一个确定性动作
返回真实、可验证的结果
```

Tool Calling：

```text
模型和外部程序之间的结构化调用协议
```

MCP：

```text
把工具、资源、提示模板标准化成可复用、可治理的外部能力服务
```

Skill：

```text
把工具、流程、模板、经验和失败处理打包成一类可复用任务能力
```

Agent：

```text
根据目标选择工具或技能，处理异常，推进任务完成
```

这周也让我更清楚地看到：

```text
Agent 不是一个更长的 Prompt。
Agent 是 LLM + 工具 + 协议 + 技能 + 状态 + 权限 + 校验组成的系统。
```

没有工具，Agent 只能说。

有了工具，Agent 才能查、算、写、调接口、访问真实系统。

但工具多了以后，又必须有 MCP、权限、审计、动态选择和 Skill 这样的组织方式。

这一周最终可以收束成一句话：

```text
工具让 LLM 从语言生成器变成外部能力调度器，MCP 让工具能力标准化，Skill 让工具组合成可复用任务能力。
```

到这里，Agent 的样子开始更像一个工程系统，而不是一个聊天窗口。
