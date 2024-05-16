#!/bin/bash

while :
do
  # 获取包含 "bash" 字符串的进程的 PID
  pid=$(ps aux | grep bash | grep -v grep | awk '{print $2}')
  
  if [ -n "$pid" ]; then
    echo "Terminating bash processes with PID: $pid"
    echo "已终止 bash 进程，其 PID 为：$pid"
    # 强制终止进程
    kill -9 $pid
    sleep 5
  else
    break
  fi
done

# Press any key to continue...
echo "Press any key to continue..."
echo -n "按任意键继续 ... "
read -n 1 -s

# Move the cursor to the next line
echo -e "\033[1A\033[K"