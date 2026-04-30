#!/usr/bin/env python3
import argparse
import csv
import datetime as dt
import re
from collections import Counter, defaultdict
from pathlib import Path


COVER_IMAGES = {
    "AI 写作": "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=1280&q=80",
    "工具流": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1280&q=80",
    "健身": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1280&q=80",
    "北京生活": "https://images.unsplash.com/photo-1508804185872-d7badad00f7d?auto=format&fit=crop&w=1280&q=80",
    "朋友": "https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1280&q=80",
    "学习记录": "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1280&q=80",
    "日常": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1280&q=80",
}


TAG_RULES = [
    ("AI 写作", ("小说", "番茄", "短篇", "玄幻", "生活家", "爽文", "AI", "ai")),
    ("工具流", ("agent", "Agent", "cursor", "Cursor", "脚本", "自动", "工作流", "网站", "工具")),
    ("健身", ("健身", "训练", "练背", "腹肌", "胸", "肩", "有氧", "骑行")),
    ("北京生活", ("北京", "故宫", "apm", "咖啡", "教堂", "三山", "聚宝源", "小红帽")),
    ("朋友", ("女友", "朋友", "可欣", "yjj", "rxn", "zhc", "吃饭", "请客")),
    ("学习记录", ("学习", "调研", "思考", "复盘", "提示词", "小红书")),
]


def clean_text(value):
    return re.sub(r"\s+", " ", (value or "").strip())


def parse_date(value):
    return dt.datetime.strptime(value.strip(), "%Y/%m/%d").date()


def row_text(row):
    return " ".join(clean_text(row.get(key, "")) for key in ("任务/行为", "状态", "内容", "学习内容"))


def infer_tags(rows):
    text = "\n".join(row_text(row) for row in rows)
    tags = []
    for tag, keywords in TAG_RULES:
        if any(keyword in text for keyword in keywords):
            tags.append(tag)
    if not tags:
        tags.append("日常")
    if "日常" not in tags:
        tags.append("日常")
    return tags[:5]


def status_mark(status):
    return {
        "已完成": "完成",
        "进行中": "进行中",
        "延期": "延期",
        "未开始": "未开始",
        "": "记录",
    }.get(status, status)


def summarize_day(day, rows, tags):
    counter = Counter(clean_text(row.get("状态", "")) or "记录" for row in rows)
    status_bits = "，".join(f"{name} {count} 项" for name, count in counter.items())
    focus = "、".join(tag for tag in tags if tag != "日常") or "日常记录"
    return f"{day.isoformat()} 这一天主要围绕 {focus} 展开，共记录 {len(rows)} 项事项；状态分布为 {status_bits}。"


def yaml_list(items):
    return "\n".join(f"  - {item}" for item in items)


def render_post(day, rows):
    tags = infer_tags(rows)
    cover = next((COVER_IMAGES[tag] for tag in tags if tag in COVER_IMAGES), COVER_IMAGES["日常"])
    title = f"縉紳的日常：{day.isoformat()}"
    description = summarize_day(day, rows, tags)
    lines = [
        "---",
        f"title: {title}",
        f"date: {day.isoformat()} 22:00:00",
        "categories: 日常",
        "tags:",
        yaml_list(tags),
        f"description: {description}",
        f"cover: {cover}",
        "---",
        "",
        "## 今日概览",
        "",
        description,
        "",
        "## 今日事项",
        "",
    ]
    for row in rows:
        task = clean_text(row.get("任务/行为", "")) or "未命名事项"
        status = status_mark(clean_text(row.get("状态", "")))
        content = clean_text(row.get("内容", ""))
        learning = clean_text(row.get("学习内容", ""))
        lines.append(f"### {task}")
        lines.append("")
        lines.append(f"- 状态：{status}")
        if content:
            lines.append(f"- 内容：{content}")
        if learning:
            lines.append(f"- 学习：{learning}")
        lines.append("")
    learning_rows = [clean_text(row.get("学习内容", "")) for row in rows if clean_text(row.get("学习内容", ""))]
    if learning_rows:
        lines.extend(["## 学到/想到的东西", ""])
        for item in learning_rows:
            lines.append(f"- {item}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def read_rows(csv_path):
    rows = []
    with Path(csv_path).open("r", encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            if clean_text(row.get("时间", "")):
                rows.append(row)
    return rows


def generate_daily_posts(csv_path, out_dir):
    grouped = defaultdict(list)
    for row in read_rows(csv_path):
        grouped[parse_date(row["时间"])].append(row)

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    written = []
    for day in sorted(grouped):
        path = out / f"{day.isoformat()}-daily-log.md"
        path.write_text(render_post(day, grouped[day]), encoding="utf-8")
        written.append(path)
    return written


def main():
    parser = argparse.ArgumentParser(description="Import daily CSV rows into Hexo posts.")
    parser.add_argument("csv_path", nargs="?", default="縉紳的日常.csv")
    parser.add_argument("out_dir", nargs="?", default="source/_posts")
    args = parser.parse_args()
    written = generate_daily_posts(Path(args.csv_path), Path(args.out_dir))
    print(f"generated {len(written)} daily posts")


if __name__ == "__main__":
    main()
