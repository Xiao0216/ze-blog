---
title: Agent 学习周记 02：从命令行到英语学习 Agent
date: 2026-05-02 09:45:00
categories: AI 工具
tags:
  - Agent
  - LangChain
  - 学习记录
description: 第二周从一个最小 LLM 调用开始，逐步接上 Gradio、多轮对话、流式输出、语音输入输出和深度思考模式。
cover: /images/agent-learning/week2-cover.png
---

第一周补的是 LLM 底层直觉，第二周开始动手写应用。

这一周的项目是一个英语学习助手。它不是一上来就做成完整 Agent，而是从最小链路开始，一层一层加能力：

```text
LLM 调用
  ↓
网页交互
  ↓
多轮对话
  ↓
流式输出
  ↓
语音输入输出
  ↓
深度思考模式
```

这个过程很适合建立一个判断：Agent 不是凭空出现的，它是从很多小的工程能力叠起来的。

![英语学习 Agent 应用流程](/images/agent-learning/week2-agent-flow.png)

## 第一步：用 LangChain 组织一次 LLM 调用

最开始的代码非常小：

```python
from langchain_core.prompts import PromptTemplate
from langchain_openai.chat_models import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

prompt = PromptTemplate.from_template(
    "Write an English paragraph about {topic} and list 3 vocabulary words."
)

model = ChatOpenAI(
    model="qwen-flash",
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
)

output_parser = StrOutputParser()

chain = prompt | model | output_parser

result = chain.invoke({"topic": "climate change"})
print(result)
```

这里有三个关键组件。

`PromptTemplate` 负责把变量填进提示词：

```text
Write an English paragraph about {topic}
```

传入：

```python
{"topic": "climate change"}
```

就变成最终 prompt。

`ChatOpenAI` 负责调用模型。虽然名字叫 OpenAI，但这里通过 OpenAI-compatible API 调用的是阿里云 DashScope 的 Qwen 模型。很多模型厂商都支持类似接口，这样应用层可以用比较统一的方式接入不同模型。

`StrOutputParser` 负责把模型返回的消息对象变成普通字符串，方便展示、保存或继续处理。

最重要的是这行：

```python
chain = prompt | model | output_parser
```

它代表一条流水线：

```text
输入 dict
  ↓
PromptTemplate 格式化
  ↓
调用模型
  ↓
解析成字符串
  ↓
得到结果
```

这还不是 Agent，但它是 Agent 应用里最小的基础单元。

## 第二步：用 Gradio 做一个能用的页面

只在命令行里 `print(result)`，还不算一个能用的应用。

Gradio 的价值是把 Python 函数快速包装成网页 UI。

核心结构像这样：

```python
import gradio as gr

def chat_handler(message: str, history: list) -> str:
    return get_ai_response(message, history)

chat_ui = gr.ChatInterface(
    fn=chat_handler,
    title="英语学习助手",
    description="一个基于 LLM 的对话式英语学习助手示例"
)

chat_ui.launch()
```

用户在页面输入一句话，Gradio 就会调用 `chat_handler`。

这里有两个参数：

```text
message：用户当前这一次输入
history：前端聊天窗口里的历史记录
```

不过第二天的版本只是“看起来像聊天”。代码虽然接收了 `history`，但没有真正把历史传给模型。所以每一轮对模型来说，还是单轮调用。

这也是下一步要解决的问题。

## 第三步：让模型真的看到历史对话

多轮对话的本质不是模型天然记住了，而是每次调用时把历史重新塞进上下文。

LangChain 里用这几个东西处理：

```python
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory
```

Prompt 变成：

```python
english_tutor_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a friendly English tutor."),
    MessagesPlaceholder(variable_name="chat_history"),
    ("user", "{user_message}"),
])
```

`MessagesPlaceholder` 解决的是：

```text
历史消息应该插到 prompt 的哪个位置。
```

但它不负责存储历史。存储历史靠：

```python
store = {}

def get_session_history(session_id: str):
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]
```

再用 `RunnableWithMessageHistory` 包一层：

```python
chain_with_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="user_message",
    history_messages_key="chat_history",
)
```

它做三件事：

```text
调用前：按 session_id 读取历史
调用时：把历史插入 chat_history
调用后：把本轮用户输入和 AI 回复写回历史
```

这样英语助手才开始真正支持上下文。

## 第四步：流式输出，让体验接近真实聊天

非流式调用是：

```text
用户输入
  ↓
等待模型完整生成
  ↓
一次性显示答案
```

体验上会有几秒空白。

流式输出则是：

```text
模型生成一段
  ↓
后端收到一段
  ↓
前端显示一段
```

最小例子：

```python
for chunk in llm.stream("解释什么是 Agent"):
    print(chunk.content, end="", flush=True)
```

在 Gradio 里，关键是 `yield`：

```python
def stream_ai_response(user_message: str, session_id: str):
    partial_answer = ""

    for chunk in chain_with_history.stream(
        {"user_message": user_message},
        config={"configurable": {"session_id": session_id}},
    ):
        if chunk:
            partial_answer += chunk
            yield partial_answer
```

这里不是每次返回一个小切片，而是返回“当前累计答案”：

```text
Hello
Hello, I
Hello, I can help
```

前端不断刷新，看起来就是模型在逐步输出。

![多轮历史与流式输出链路](/images/agent-learning/week2-history-stream.png)

多轮和流式其实是两层能力：历史管理解决“模型能不能看到上下文”，流式输出解决“用户能不能及时看到生成过程”。

## 第五步：接入语音输入和语音输出

多模态版本把流程扩展成：

```text
用户语音
  ↓
ASR 转文字
  ↓
LLM 生成文本回复
  ↓
TTS 转语音
  ↓
播放 AI 回复
```

三个模块分工很清楚：

```text
ASR：Audio → Text
LLM：Text + Context → Text
TTS：Text → Audio
```

代码里 ASR 用 Whisper：

```python
import whisper

asr_model = whisper.load_model("turbo")

def speech_to_text(audio_path: str) -> str:
    transcribed = asr_model.transcribe(audio_path)
    return transcribed["text"]
```

TTS 用 edge-tts：

```python
import edge_tts
import time

def text_to_speech(text: str) -> str:
    audio_path = f"./output_{int(time.time())}.mp3"
    communicate = edge_tts.Communicate(text, "en-GB-SoniaNeural")
    with open(audio_path, "wb") as file:
        for chunk in communicate.stream_sync():
            if chunk["type"] == "audio":
                file.write(chunk["data"])
    return audio_path
```

这个版本从 `ChatInterface` 切到了 `Blocks`，因为界面不再只是一个聊天框，还需要麦克风输入、语音播放、自定义布局和清空按钮。

学习项目里直接写 mp3 文件没问题，但生产系统还要考虑：

```text
临时文件清理
并发文件名冲突
音频隐私
生成失败兜底
存储成本
```

## 第六步：深度思考模式

最后加入的是“普通模式 / 深度思考模式”切换。

它不是界面上多一个按钮这么简单，本质是运行时切换：

```text
模型配置
推理参数
输出处理方式
前端展示方式
```

比如：

```python
def get_model(is_reasoning):
    if is_reasoning:
        return ChatOpenAI(
            model="qwen-flash",
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
            extra_body={"enable_thinking": True},
        )
    return ChatOpenAI(
        model="qwen-max",
        base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
    )
```

深度思考模式下，模型可能返回两类内容：

```text
reasoning_content：思考 / 推理内容
content：最终回答
```

这时就不能简单用 `StrOutputParser()` 了，因为它可能只保留最终文本，丢掉厂商扩展字段。

所以代码直接处理 `AIMessageChunk`：

```python
answer_buffer = ""
thinking_buffer = ""

for chunk in chain_with_history.stream(...):
    reasoning = chunk.additional_kwargs.get("reasoning_content")
    if reasoning:
        thinking_buffer += reasoning

    if chunk.content:
        answer_buffer += chunk.content
```

工程上这里要特别小心：思考内容可以做前端展示，但不应该直接写进历史记忆。否则下一轮对话会把大量推理文本带回上下文，token 成本变高，还可能污染后续回答。

![语音多模态与深度思考链路](/images/agent-learning/week2-multimodal-thinking.png)

语音版并不是换掉原来的文本链路，而是在 LLM 前后接入 ASR 和 TTS；深度思考则是在模型调用和输出处理上多了一条更慢、更重的分支。

## 为什么它还只是 Agent 雏形

这一周做完之后，英语助手已经有了不少能力：

```text
网页交互
多轮对话
流式输出
语音输入输出
深度思考模式
```

但它还不是完整的任务型 Agent。

它缺少：

```text
自主规划任务步骤
主动选择工具
调用外部系统
观察工具结果
根据结果修正计划
长期记忆
任务状态管理
失败重试
权限与安全控制
评估与监控
```

更完整的英语学习 Agent 应该能做这些事：

```text
识别用户是在练语法、写作、口语还是阅读
记录用户常犯错误
自动生成个性化练习
调用发音评分工具
根据历史进步调整难度
制定学习计划并跟踪完成情况
```

所以 Week 2 的收获不是“已经做完了 Agent”，而是看清了一个应用从最小 LLM 调用到 Agent 雏形的演进路径。

一句话总结：

```text
LangChain 负责组织 LLM 调用，Gradio 负责交互界面，多轮、流式、语音和深度思考逐步把它推向 Agent 应用形态。
```
