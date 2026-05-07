from pathlib import Path


ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "毕业论文.md"

FRONT_MATTER = """# 对中算法研究与仿真系统开发

## 致谢

本论文在指导教师的悉心指导下完成。从课题选题、研究思路确定到仿真系统开发和论文撰写，老师均给予了耐心指导和宝贵建议。在此谨向指导教师表示诚挚感谢。

同时，感谢学院和专业课程学习过程中给予帮助的各位老师，相关理论课程为本文的算法建模和系统实现提供了基础。感谢同学和师兄在资料查找、软件调试和论文修改过程中提供的帮助。最后，感谢家人在学习和生活中给予的理解与支持。

## 摘要

旋转机械轴系对中精度直接影响设备运行稳定性和使用寿命。针对传统机械式对中方法操作复杂、可视化程度低、算法验证成本较高等问题，本文围绕双 LD-PSD 激光对中结构，开展对中算法研究与 MATLAB 仿真系统开发。首先，分析轴系平行不对中、角度不对中和综合不对中的几何特征，建立轴线方向、激光光束和 PSD 接收面之间的空间关系。其次，基于直线与平面求交方法和局部坐标映射方法，构建由不对中参数到 PSD 光斑轨迹的前向仿真模型。然后，开发 MATLAB 交互式仿真系统，实现不对中参数、结构参数和安装误差参数输入，并输出三维光路、全局投影、局部 PSD 轨迹和角度响应曲线。最后，通过理想对中、平行不对中、角度不对中、综合不对中和安装误差等数值实验工况，对仿真系统的输出规律进行验证。结果表明，该系统能够较直观地反映不同不对中参数和安装误差对光斑轨迹的影响，可为后续对中算法优化和实验平台建设提供参考。

关键词：对中算法；激光对中；位置敏感探测器；MATLAB；仿真系统

## Abstract

The alignment accuracy of rotating machinery shafting directly affects equipment stability and service life. To address the limitations of traditional mechanical alignment methods, such as complicated operation, limited visualization, and high cost of algorithm verification, this thesis studies an alignment algorithm and develops a MATLAB simulation system based on a dual LD-PSD laser alignment structure. First, the geometric characteristics of parallel misalignment, angular misalignment, and combined misalignment are analyzed, and the spatial relationship among the shaft axis, laser beam, and PSD receiving plane is established. Second, a forward simulation model from misalignment parameters to PSD spot trajectories is constructed by using line-plane intersection and local coordinate mapping. Third, an interactive MATLAB simulation system is developed to support the input of misalignment parameters, structural parameters, and installation error parameters, and to output three-dimensional optical paths, global projections, local PSD trajectories, and angular response curves. Finally, numerical experiments including ideal alignment, parallel misalignment, angular misalignment, combined misalignment, and installation error conditions are designed to verify the output characteristics of the simulation system. The results show that the system can intuitively reflect the influence of different misalignment parameters and installation errors on spot trajectories, providing a reference for subsequent algorithm optimization and experimental platform construction.

Keywords: Alignment Algorithm; Laser Alignment; Position Sensitive Detector; MATLAB; Simulation System

## 目录

（Markdown 草稿阶段暂不生成页码，Word 定稿阶段自动生成目录。）
"""


def main() -> None:
    chapter_files = sorted((ROOT / "chapters").glob("*.md"))
    parts = [FRONT_MATTER.strip()]

    for chapter_file in chapter_files:
        parts.append(chapter_file.read_text(encoding="utf-8").strip())

    parts.append((ROOT / "references.md").read_text(encoding="utf-8").strip())
    OUTPUT.write_text("\n\n".join(parts) + "\n", encoding="utf-8")
    print(f"Assembled thesis manuscript: {OUTPUT}")


if __name__ == "__main__":
    main()
