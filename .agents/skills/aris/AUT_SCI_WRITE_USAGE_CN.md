# Aut_Sci_Write Skills（ARIS 本地配置）

本仓库已将 `Aut_Sci_Write` 按 ARIS 约束安装到：

- `.agents/skills/aris/sci-search`
- `.agents/skills/aris/sci-extract`
- `.agents/skills/aris/sci-review`
- `.agents/skills/aris/sci-zotero`
- `.agents/skills/aris/sci-figure`
- `.agents/skills/aris/sci-ppt`

## 触发方式
在对话里直接提到 skill 名称即可触发，例如：

- `请用 sci-search 帮我检索这篇方向近三年文献`
- `用 sci-extract 提取这篇 PDF 的方法和实验结论`
- `用 sci-review 帮我润色 related work`
- `用 sci-zotero 根据 DOI 补全 bib`
- `用 sci-figure 从论文 PDF 中抽取图并编号`
- `用 sci-ppt 生成汇报幻灯片草稿`

## 每个 skill 的用途
- `sci-search`：学术检索、聚合结果、输出可追溯的候选文献。
- `sci-extract`：从论文/PDF 抽取结构化信息（任务、方法、数据集、指标等）。
- `sci-review`：学术写作审阅与改写（段落、术语、rebuttal 模板）。
- `sci-zotero`：文献条目整理与参考文献管理辅助。
- `sci-figure`：论文图像检测与拆分、图注相关处理。
- `sci-ppt`：基于论文内容组织汇报稿与页面结构。

## 依赖说明
部分 skill 含 Python 依赖（见各目录 `requirements.txt` 或 `pyproject.toml`）。
如需运行脚本，先在仓库根目录创建虚拟环境并安装依赖。

## 来源
- 上游仓库：`https://github.com/ShZhao27208/Aut_Sci_Write`
- 导入时间：2026-05-07
