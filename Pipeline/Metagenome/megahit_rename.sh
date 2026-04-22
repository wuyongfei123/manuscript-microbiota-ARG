#!/bin/bash
# usage:只需修改Assembly路径

Assembly=/data/project898/assembly_cbind

# 接收输入文件参数
input_file=$1

# 使用while循环读取输入文件中的样本名并处理
while IFS= read -r -u 3 sample || [ -n "$sample" ]; do
    if [ -n "$sample" ]; then
        sed "s/>/>${sample}_/g" ${Assembly}/${sample}_megahit/final.contigs.fa > ${Assembly}/${sample}_megahit/rename_final.contigs.fa
    fi
done 3< "$input_file"

# 提示用户运行脚本的方式
echo "To run the script, use:"
echo "./your_script_name.sh /path/to/SRA.txt"