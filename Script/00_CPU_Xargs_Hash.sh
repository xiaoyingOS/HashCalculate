#!/bin/bash

# Run xargs citation once to silence the notice
# echo | xargs --show-limits > /tmp/xargs_citation 2>&1

# Read user input to determine whether to calculate hash for subdirectories
echo "English: Calculate hash for files in subdirectories? (y/n): "
read -p "是否计算 子文件夹中 所有文件的哈希值? (y/n): " calculate_subdirectories

# Check if 00_Hash.json already has content
if [ -s "$PWD/00_Hash.json" ]; then
  last_char=$(tail -n 1 "$PWD/00_Hash.json")
  if [ "$last_char" == "]" ]; then
    # Remove the trailing comma if present
    sed -i '$!{N;s/\(}\)\n/\1,/}' "$PWD/00_Hash.json"
    sed -i '$ s/]$//' "$PWD/00_Hash.json"
  fi
else
  echo "[" >> "$PWD/00_Hash.json"
fi

declare -g total_files=0
declare -g current_progress=0

#创建文件 并行处理 进度条处理
export file_progress_path="./Temp_Del.temp"

# 检查文件是否存在
if [ ! -e "$file_progress_path" ]; then
    touch "$file_progress_path"
    echo "0" > "$file_progress_path"
else 
    echo "0" > "$file_progress_path"
fi

update_progress() {
  # 旋转字符组成动画
  animation_symbols=("/" "-" "\\" "|")
  #随机数
  random_number=$((RANDOM % 100 + 1))
  #读取文件到变量
  read current_progress < "$file_progress_path"

   ((current_progress++))
   color=$((31 + random_number % 7))  # 基于ANSI颜色码，颜色逐渐变化
   # 更新旋转字符动画
   animation_index=$((current_progress % 4))
   printf "\r\033[${color}m\t程序进度: →%s→ %d%%\033[0m" "${animation_symbols[$animation_index]}" $((current_progress * 100 / total_files))
   printf " →→"
   echo "$current_progress" > "$file_progress_path"
}

export -f update_progress

# Function to calculate hash values and write to 00_Hash.json
calculate_hash() {
  local file="$1"
  local md5_hash=$(md5sum "$file" | awk '{print $1}')
  local sha1_hash=$(sha1sum "$file" | awk '{print $1}')
  local sha256_hash=$(sha256sum "$file" | awk '{print $1}')
  local sha512_hash=$(sha512sum "$file" | awk '{print $1}')
  local file_size=$(wc -c < "$file")

  # Extracting just the file name
  local file_name=$(basename "$file")

  # Create JSON object manually
  local json_object="    {\n        \"file\": \"$file_name\", \n        \"sizebytes\": \"$file_size\", \n        \"md5\": \"$md5_hash\", \n        \"sha1\": \"$sha1_hash\", \n        \"sha256\": \"$sha256_hash\", \n        \"sha512\": \"$sha512_hash\"\n    },"

  # Append JSON object to 00_Hash.json
  echo -e "$json_object" >> "$PWD/00_Hash.json"
  
  #更新进度条
  update_progress
}

export -f calculate_hash  # Export the function for use with xargs

# Function to recursively process files and folders
process_files() {
  local path="$1"
  export total_files=$(find "$path" -maxdepth 1 -type f | wc -l)
  # echo "文件总数: $total_files"

  #current_progress=0
  
  if [ -z "$calculate_subdirectories" ] || [ "$calculate_subdirectories" == "y" ]; then
    # 计算当前文件夹和所有子文件夹中的文件哈希值，排除指定文件
    export total_files=$(find "$path" -type f | wc -l)
    find "$path" -type f -not \( -name '00_Hash.json' -o -name 'Temp_Del.temp' -o -name '00_CPU_Xargs_Hash.sh' \) -print | xargs -I{} -P8 -n1 bash -c 'calculate_hash "$@"' _ "{}"
  else
    # 只计算当前文件夹中的文件哈希值，排除指定文件
    find "$path" -maxdepth 1 -type f -not \( -name '00_Hash.json' -o -name 'Temp_Del.temp' -o -name '00_CPU_Xargs_Hash.sh' \) -print | xargs -I{} -P8 -n1 bash -c 'calculate_hash "$@"' _ "{}"
  fi
  echo "文件总数: $total_files"
}


# Check if 00_Hash.json already exists
if [ ! -e "$PWD/00_Hash.json" ]; then
  touch "$PWD/00_Hash.json"
  echo "[" > "$PWD/00_Hash.json" # Initialize as an empty array
fi

# Directly calculate hash values for files in the current directory
echo "正在计算哈希值..."
start_time=$(date +%s)
process_files "$PWD"
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Remove the trailing comma if present
sed -i '$ s/,$//' "$PWD/00_Hash.json"

# Close the JSON array
echo "]" >> "$PWD/00_Hash.json"
echo -e "\n"
echo "English: Hash calculation completed. Results are saved in 00_Hash.json."
echo "所有文件哈希值 已计算完成，结果已保存到 $PWD/00_Hash.json 文件中。"
echo "消耗时间: $elapsed_time 秒。"

# 在脚本结束时删除临时文件
trap "rm -f $file_progress_path" EXIT

# 复制生成的文件为00_Hash.txt 可以用变量保存 文件名也可以用当前时间日期定义
cp "$PWD/00_Hash.json" "$PWD/00_Hash.txt"

# Press any key to continue...
echo "Press any key to continue..."
echo -n "按任意键继续 ... "
read -n 1 -s

# Move the cursor to the next line
echo -e "\033[1A\033[K"

# Remove the citation notice file
# rm -f /tmp/xargs_citation

