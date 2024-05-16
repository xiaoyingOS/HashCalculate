#!/bin/bash

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
  else echo "[" >> "$PWD/00_Hash.json"
fi

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
  
}

# Function to recursively process files and folders
process_files() {
  local path="$1"
  local total_files=$(find "$path" -type f | wc -l)
  local processed_files=0
  # 旋转字符组成动画
  animation_symbols=("/" "-" "\\" "|")

  for file in "$path"/*; do
    if [ -d "$file" ] && [ "$file" != "$PWD/00_Hash.json" ] && [ "$file" != "$PWD/00_Hash.sh" ]; then
      if [ -z "$calculate_subdirectories" ] || [ "$calculate_subdirectories" == "y" ]; then
        process_files "$file"
      fi
    elif [ -f "$file" ] && [ "$file" != "$PWD/00_Hash.json" ] && [ "$file" != "$PWD/00_JSON_Hash.sh" ]; then
      calculate_hash "$file"
      ((processed_files++))
      # 更新进度条
      color=$((31 + processed_files % 7))  # 基于ANSI颜色码，颜色逐渐变化
      # 更新旋转字符动画
      animation_index=$((processed_files % 4))
      printf "\r\033[${color}m\t程序进度: →%s→ %d%%\033[0m" "${animation_symbols[$animation_index]}" $((processed_files * 100 / total_files))
      printf " →→"
      # sleep 0.1  # 为了更好的观察动态效果
    fi
  done
}

# Check if 00_Hash.json already exists
if [ ! -e "$PWD/00_Hash.json" ]; then
  touch "$PWD/00_Hash.json"
  echo "[" > "$PWD/00_Hash.json" # Initialize as an empty array
fi

# 直接计算当前目录下的文件
echo "正在计算哈希值..."
start_time=$(date +%s)
process_files "$PWD"
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Remove the trailing comma if present
sed -i '$ s/,$//' "$PWD/00_Hash.json"

# Close the JSON array
echo "]" >> "$PWD/00_Hash.json"

# 复制生成的文件为00_Hash.txt 可以用变量保存 文件名也可以用当前时间日期定义
cp "$PWD/00_Hash.json" "$PWD/00_Hash.txt"

echo "\n"
echo "English: Hash calculation completed. Results are saved in 00_Hash.json."
echo "所有文件哈希值 已计算完成，结果已保存到 $PWD/00_Hash.json 文件中。"
echo "消耗时间: $elapsed_time 秒。"

# 按任意键继续...
echo "Press any key to continue..."
echo -n "按任意键继续 ... "
read -n 1 -s

# Move the cursor to the next line
echo -e "\033[1A\033[K"

