import csv
import tempfile
import unittest
from pathlib import Path

from tools.import_daily_csv import generate_daily_posts


class DailyCsvImportTest(unittest.TestCase):
    def test_generates_one_post_per_date_with_tags_and_cover(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            csv_path = root / "daily.csv"
            out_dir = root / "posts"
            with csv_path.open("w", encoding="utf-8", newline="") as f:
                writer = csv.DictWriter(
                    f,
                    fieldnames=["任务/行为", "状态", "时间", "内容", "学习内容"],
                )
                writer.writeheader()
                writer.writerow(
                    {
                        "任务/行为": "✅番茄小说更新",
                        "状态": "已完成",
                        "时间": "2025/12/01",
                        "内容": "完成 10 章内容",
                        "学习内容": "学习 AI 小说流程",
                    }
                )
                writer.writerow(
                    {
                        "任务/行为": "✅健身",
                        "状态": "已完成",
                        "时间": "2025/12/01",
                        "内容": "练背和腹肌",
                        "学习内容": "",
                    }
                )
                writer.writerow(
                    {
                        "任务/行为": "",
                        "状态": "",
                        "时间": "",
                        "内容": "",
                        "学习内容": "",
                    }
                )

            written = generate_daily_posts(csv_path, out_dir)

            self.assertEqual([out_dir / "2025-12-01-daily-log.md"], written)
            content = written[0].read_text(encoding="utf-8")
            self.assertIn("title: 縉紳的日常：2025-12-01", content)
            self.assertIn("categories: 日常", content)
            self.assertIn("cover:", content)
            self.assertIn("- AI 写作", content)
            self.assertIn("- 健身", content)
            self.assertIn("## 今日概览", content)
            self.assertIn("完成 10 章内容", content)
            self.assertIn("学习 AI 小说流程", content)


if __name__ == "__main__":
    unittest.main()
