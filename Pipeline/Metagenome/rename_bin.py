import os
import shutil
import argparse

def main(input_file_path, output_directory):
    # 读取文件内容并创建字符串列表
    with open(input_file_path, 'r') as file:
        sra_list = [line.strip() for line in file.readlines()]

    # 确保目标 MAG_Fasta 目录存在
    os.makedirs(output_directory, exist_ok=True)

    # 遍历 SRA IDs
    for sra in sra_list:
        # 指定包含文件的源目录
        source_dir = os.path.join('/data/project898/03_binning', sra, 'BIN_REFINEMENT/metawrap_50_10_bins')

        # 检查源目录是否存在
        if not os.path.isdir(source_dir):
            print(f"警告: {sra} 对应的目录 {source_dir} 不存在，已跳过该样本。")
            continue

        # 遍历源目录中的文件
        for filename in os.listdir(source_dir):
            # 检查是否为常规文件
            if os.path.isfile(os.path.join(source_dir, filename)):
                # 构造新文件名，在原文件名前加上 "SRA_ID_" 
                new_filename = sra + "_" + filename  # 添加下划线以便清晰
                
                # 构造目标文件在 MAG_Fasta 目录下的完整路径
                destination_file = os.path.join(output_directory, new_filename)
                
                # 将修改后的文件复制到目标目录
                shutil.copy(os.path.join(source_dir, filename), destination_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="根据输入文本文件复制并重命名文件。")
    parser.add_argument("input_file", type=str, help="包含 SRA IDs 的输入文本文件路径。")
    parser.add_argument("output_directory", type=str, help="输出目录 (MAG_Fasta) 路径，重命名后的文件将被复制到这里。")

    args = parser.parse_args()

    main(args.input_file, args.output_directory)