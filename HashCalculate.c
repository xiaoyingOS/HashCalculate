#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <wchar.h>
#include <locale.h>
#include <string.h>
#include <stdbool.h>
#include <windows.h>
#include <wincrypt.h>
#include <time.h>
#include <io.h>

// 定义进度条长度和符号
#define PROGRESS_BAR_LENGTH 100
int CalculateCount;//哈希值计算次数 用于设置进度条
//进度条输出图形
wchar_t PROGRESS_SYMBOL[] = L"█";//▄ ♪ ▃ ▅ █ ▇ ▆ ... 这里只能放Unicode编码靠前的 也不支持emoji

#define MAX_THREADS 32 // 线程池存储最大线程数
#define CREATED_MAX_THREADS 5 // 创建线程, 加入线程池管理 计算哈希值的多线程数
#define FILE_PATH_MAX_LENGTH 10000 //目录最长长度 字节数
// #define THREAD_INCREMENT 10 // 扩展文件数量、线程数量, 每次扩展10倍
unsigned long long int THREADSCOUNT = 0; // 线程总数
unsigned long long int FILESCOUNT = 0;   // 文件总数
//生成的文件名00_Hash.json 可以用一个变量保存

clock_t start, end;//记录程序运行所用时间
double cpu_time_used;

// 结构体用于存储文件信息
struct FileInfo {
    char path[FILE_PATH_MAX_LENGTH];
    char name[256];
    unsigned long long size; // 使用 unsigned long long 类型来存储文件大小
};

// 线程池结构体
typedef struct {
    HANDLE *threads;        // 线程句柄数组
    CRITICAL_SECTION lock;  // 临界区保护线程池资源
    CONDITION_VARIABLE condition; // 条件变量用于线程同步
    int numThreads;         // 当前线程数量
    int maxThreads;         // 最大线程数量
    int numTasks;           // 当前任务数量
    bool shutdown;          // 标记线程池是否关闭
    struct Task {
        struct FileInfo *fileInfo; // 任务的文件信息
        struct Task *next;          // 指向下一个任务的指针
    } *taskQueue;
    CRITICAL_SECTION mutex; // 新添加的互斥量
} ThreadPool;

// 创建线程池
ThreadPool *initializeThreadPool(int maxThreads) {
    ThreadPool *pool = (ThreadPool *)malloc(sizeof(ThreadPool));
    if (pool == NULL) {
        perror("Memory allocation error");
        exit(1);
    }
    pool->threads = (HANDLE *)malloc(maxThreads * sizeof(HANDLE));
    if (pool->threads == NULL) {
        perror("Memory allocation error");
        free(pool);
        exit(1);
    }
    pool->maxThreads = maxThreads;
    pool->numThreads = 0;
    pool->numTasks = 0;
    pool->shutdown = false;
    pool->taskQueue = NULL;
    InitializeCriticalSection(&pool->lock);
    InitializeCriticalSection(&pool->mutex); // 初始化新添加的互斥量
    InitializeConditionVariable(&pool->condition);
    return pool;
}

// 销毁线程池
void destroyThreadPool(ThreadPool *pool) {
    if (pool == NULL) {
        return;
    }
    pool->shutdown = true;
    WakeAllConditionVariable(&pool->condition);
    for (int i = 0; i < pool->numThreads; ++i) {
        WaitForSingleObject(pool->threads[i], INFINITE);
        CloseHandle(pool->threads[i]);
    }
    free(pool->threads);
    DeleteCriticalSection(&pool->lock);
    free(pool);

    // 将 JSON 数组的最后一个逗号替换为右中括号，表示结束
    FILE *file = fopen("00_Hash.json", "r+");//不能用a模式 因为追加模式下 文件指针自动定位到文件末尾
    if (!file) {
        perror("File open error");
        return;
    }
    
    fseek(file, -3, SEEK_END);
    // char lastByte;
    // lastByte = fgetc(file);
    // // 如果最后一个字符是逗号，就替换它 [也可以直接替换]
    // if (lastByte == ',') {
    //     fseek(file, -1, SEEK_CUR);
    //     fwprintf(file, L"");//将最后一个}后面的逗号去掉
    //     // printf("lastByte %c", lastByte);
    // }
    fwprintf(file, L"");//将最后一个}后面的逗号去掉

    // 写入 JSON 数组的结尾
    fwprintf(file, L"\n]");
    fclose(file);
    end = clock(); // 记录结束时间
    cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC; // 计算时间差并转换为秒
    
    // 复制 00_Hash.json 文件为 Hash.txt
    if (!CopyFile("00_Hash.json", "00_Hash.txt", FALSE)) {
        printf("Error copying file: %d\n", GetLastError());
    }

    printf("\n\n--> Program running time: %f 秒\n\n", cpu_time_used);
}

// 添加任务到线程池
void addTaskToThreadPool(ThreadPool *pool, struct FileInfo *fileInfo) {
    EnterCriticalSection(&pool->lock);
    struct Task *newTask = (struct Task *)malloc(sizeof(struct Task));
    if (newTask == NULL) {
        perror("Memory allocation error");
        LeaveCriticalSection(&pool->lock);
        return;
    }
    newTask->fileInfo = fileInfo;
    newTask->next = NULL;
    if (pool->taskQueue == NULL) {
        pool->taskQueue = newTask;
    } else {
        struct Task *temp = pool->taskQueue;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = newTask;
    }
    pool->numTasks++;
    WakeConditionVariable(&pool->condition);
    LeaveCriticalSection(&pool->lock);
}

// 从线程池中获取任务
struct Task *getTaskFromThreadPool(ThreadPool *pool) {
    EnterCriticalSection(&pool->lock);
    while (pool->taskQueue == NULL && !pool->shutdown) {
        SleepConditionVariableCS(&pool->condition, &pool->lock, INFINITE);
    }
    if (pool->shutdown) {
        LeaveCriticalSection(&pool->lock);
        return NULL;
    }
    struct Task *task = pool->taskQueue;
    pool->taskQueue = pool->taskQueue->next;
    pool->numTasks--;
    LeaveCriticalSection(&pool->lock);
    return task;
}

// 获取文件大小
static unsigned long long GetFileSizes(const char *filename) {
    HANDLE hFile = CreateFile(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        return -1; // 错误处理
    }

    LARGE_INTEGER fileSize;
    if (!GetFileSizeEx(hFile, &fileSize)) {
        CloseHandle(hFile);
        return -1; // 错误处理
    }

    CloseHandle(hFile);
    return fileSize.QuadPart;
}

// Function to calculate hash of a file
BOOL CalculateHash(ThreadPool *pool, const char* Path, const char* filePath, const char* fileName, unsigned long long fileSize) {

    // Open the file
    HANDLE hFile = CreateFileA(Path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        wprintf(L"Error opening file\n");
        return FALSE;
    }

    // Create a file mapping object
    HANDLE hMapFile = CreateFileMapping(hFile, NULL, PAGE_READONLY, 0, 0, NULL);
    if (hMapFile == NULL) {
        wprintf(L"Error creating file mapping\n");
        CloseHandle(hFile);
        return FALSE;
    }

    // Map the file into memory
    LPBYTE lpFile = (LPBYTE)MapViewOfFile(hMapFile, FILE_MAP_READ, 0, 0, 0);
    if (lpFile == NULL) {
        wprintf(L"Error mapping file to memory\n");
        CloseHandle(hMapFile);
        CloseHandle(hFile);
        return FALSE;
    }

    // Initialize cryptographic provider context handle
    HCRYPTPROV hProv = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        wprintf(L"Error acquiring crypto context\n");
        UnmapViewOfFile(lpFile);
        CloseHandle(hMapFile);
        CloseHandle(hFile);
        return FALSE;
    }

    WCHAR hashStrings[5][4096] = { L"" }; // Array to hold five hash strings
    ALG_ID hashAlgorithms[5] = { CALG_MD5, CALG_SHA1, CALG_SHA_256, CALG_SHA_384, CALG_SHA_512 };

    // Buffer to hold data read from file
    BYTE buffer[1024*1024];
    DWORD bytesRead = 0;

    // Iterate over hash algorithms
    for (int i = 0; i < 5; ++i) {
        // Create the hash object
        HCRYPTHASH hHash = 0;
        if (!CryptCreateHash(hProv, hashAlgorithms[i], 0, 0, &hHash)) {
            wprintf(L"Error creating hash object\n");
            CryptReleaseContext(hProv, 0);
            UnmapViewOfFile(lpFile);
            CloseHandle(hMapFile);
            CloseHandle(hFile);
            return FALSE;
        }

        // Reset file pointer to beginning
        SetFilePointer(hFile, 0, NULL, FILE_BEGIN);

        // Read file in chunks and update hash
        while (ReadFile(hFile, buffer, sizeof(buffer), &bytesRead, NULL) && bytesRead > 0) {
            if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
                wprintf(L"Error hashing data\n");
                CryptDestroyHash(hHash);
                CryptReleaseContext(hProv, 0);
                UnmapViewOfFile(lpFile);
                CloseHandle(hMapFile);
                CloseHandle(hFile);
                return FALSE;
            }
        }

        // Determine the size of the hash
        DWORD cbHash = 0;
        if (!CryptGetHashParam(hHash, HP_HASHVAL, NULL, &cbHash, 0)) {
            wprintf(L"Error getting hash value length\n");
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            UnmapViewOfFile(lpFile);
            CloseHandle(hMapFile);
            CloseHandle(hFile);
            return FALSE;
        }

        // Allocate memory for the hash
        BYTE* pbData = (BYTE*)malloc(cbHash);
        if (pbData == NULL) {
            wprintf(L"Memory allocation error\n");
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            UnmapViewOfFile(lpFile);
            CloseHandle(hMapFile);
            CloseHandle(hFile);
            return FALSE;
        }

        // Retrieve the hash value
        if (!CryptGetHashParam(hHash, HP_HASHVAL, pbData, &cbHash, 0)) {
            wprintf(L"Error retrieving hash value\n");
            free(pbData);
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            UnmapViewOfFile(lpFile);
            CloseHandle(hMapFile);
            CloseHandle(hFile);
            return FALSE;
        }

        // Convert hash value to hex string
        WCHAR* p = hashStrings[i];
        for (DWORD j = 0; j < cbHash; j++) {
            p += swprintf(p, 3, L"%02x", pbData[j]);
        }

        // Clean up
        free(pbData);
        CryptDestroyHash(hHash);
    }

    // Write hash values to the file

    //打开 Hash.json 文件，以追加写入的方式
    FILE *file = fopen("00_Hash.json", "a, ccs=UTF-8");
    if (!file) {
        perror("File open error");
        // free(fileInfo);
        // free(task);
        return 1;
    }

    EnterCriticalSection(&pool->mutex);

    //写入文件路径
    fwprintf(file, L"    {\n        \"File\": \"%s/%s\",\n", filePath, fileName);//绝对路径
    // 写入文件大小
    fwprintf(file, L"        \"SizeBytes\": %llu,\n", fileSize);

    // Write hash values to the file
    fwprintf(file, 
    L"        \"MD5\": \"%ls\",\n        \"SHA1\": \"%ls\",\n        \"SHA256\": \"%ls\",\n        \"SHA384\": \"%ls\",\n        \"SHA512\": \"%ls\"\n",
    hashStrings[0], hashStrings[1], hashStrings[2], hashStrings[3], hashStrings[4]);

    //结束当前 JSON 对象的写入
    fwprintf(file, L"    }");
    // 在每个 JSON 对象的末尾添加逗号，除非是最后一个对象
    // 可以添加一个判断语句
    fwprintf(file, L",\n");
    fclose(file);
    /*
    进度条加在这里 方便维护
    */
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
    COORD originalPos = csbi.dwCursorPosition;

   CalculateCount++;

    // 获取标准输出的句柄
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hConsole == INVALID_HANDLE_VALUE) {
        fprintf(stderr, "Error getting console handle\n");
        return 1;
    }

    COORD newPos = {0, 20}; // 将光标移动到第 20 行(0-based index)

    COORD newPos2 = {0, 10}; // 将光标移动到第 20 行(0-based index)

    SetConsoleCursorPosition(hConsole, newPos2);
    DWORD threadId = GetCurrentThreadId(); // 获取当前线程ID
    DWORD processorNumber = GetCurrentProcessorNumber(); // 获取当前CPU处理器编号
    printf("\n\rThread ID: %lu   Processor CPU: #%lu   \n", threadId, processorNumber);

        // 计算进度条长度
        int progressLength = (int)((float)CalculateCount / FILESCOUNT * PROGRESS_BAR_LENGTH);
        // 移动光标到记录的位置
        SetConsoleCursorPosition(hConsole, newPos);
        // 输出进度条
        for (int j = 0; j < PROGRESS_BAR_LENGTH; ++j) {
            if (j < progressLength) {
                wprintf(L"%ls", PROGRESS_SYMBOL);
            } else {
                wprintf(L"-");
            }
        }

    wprintf(L"] [%d%%]", progressLength);

    // 强制刷新输出缓冲区，以便立即显示
    fflush(stdout);
    SetConsoleCursorPosition(hConsole, newPos);

    LeaveCriticalSection(&pool->mutex);

     CryptReleaseContext(hProv, 0);
    UnmapViewOfFile(lpFile);
    CloseHandle(hMapFile);
    CloseHandle(hFile);

    return TRUE;
}

// 线程函数，处理文件并计算哈希值
DWORD WINAPI ProcessFiles(LPVOID arg) {
    ThreadPool *pool = (ThreadPool *)arg;
    while (true) {
        struct Task *task = getTaskFromThreadPool(pool); // 获取任务
        if (task == NULL) {
            return 0; // 如果任务为空，则直接返回
        }
        struct FileInfo *fileInfo = task->fileInfo;
        char path[FILE_PATH_MAX_LENGTH];
        sprintf(path, "%s/%s", fileInfo->path, fileInfo->name);

        // 打开 Hash.json 文件，以追加写入的方式
        // FILE *file = fopen("00_Hash.json", "a, ccs=UTF-8");
        // if (!file) {
        //     perror("File open error");
        //     free(fileInfo);
        //     free(task);
        //     return 1;
        // }

        struct stat statbuf;
        stat(path, &statbuf);

        // DWORD threadId = GetCurrentThreadId(); // 获取当前线程ID
        // DWORD processorNumber = GetCurrentProcessorNumber(); // 获取当前CPU处理器编号
        // printf("Thread ID: %lu   Processor CPU: #%lu\n", threadId, processorNumber);
        
        // 计算并写入哈希值
        CalculateHash(pool, path, fileInfo->path, fileInfo->name, GetFileSizes(path));

        // EnterCriticalSection(&pool->mutex);

        //结束当前 JSON 对象的写入
        // fwprintf(file, L"    }");

        // 在每个 JSON 对象的末尾添加逗号，除非是最后一个对象
        //可以添加一个判断语句
        // fwprintf(file, L",\n");
        // LeaveCriticalSection(&pool->mutex);

        // 关闭文件
        // fclose(file);
        free(fileInfo);
        free(task); // 释放任务结构体内存
}
}

// 递归函数，遍历所有子文件夹
void listFilesRecursively(ThreadPool *pool, char *basePath, FILE *file, bool calculateSubfolders) {
    char path[FILE_PATH_MAX_LENGTH];
    struct dirent *dp;
    DIR *dir = opendir(basePath);

    if (!dir) {
        return;
    }

    while ((dp = readdir(dir)) != NULL) {
        if (strcmp(dp->d_name, ".") != 0 && strcmp(dp->d_name, "..") != 0) {
            // 构建完整路径
            sprintf(path, "%s/%s", basePath, dp->d_name);

            // 检查是否是要排除的文件
            if (strcmp(dp->d_name, "00_Hash.json") == 0 || strcmp(dp->d_name, "HashCalculate.exe") == 0 || strcmp(dp->d_name, "00_Hash.txt") == 0) {
                continue; // 跳过排除的文件
            }

            // 使用 stat() 函数获取文件信息
            struct stat statbuf;
            stat(path, &statbuf);

            // 如果是目录，则递归遍历
            if (S_ISDIR(statbuf.st_mode)) {
                if (calculateSubfolders) {
                    listFilesRecursively(pool, path, file, true);
                }
            } else {
                // 如果是文件，将文件信息写入到文件中
                struct FileInfo *fileInfo = (struct FileInfo *)malloc(sizeof(struct FileInfo));
                // 如果文件大小为 0 则跳过
                if (statbuf.st_size == 0) {
                    //多线程输出 位置会干扰其他输出位置 会打乱进度条 不好看 比较乱 这里就不输出了
                    // wprintf(L"Skipping file: %s/%s 文件为空 跳过计算此文件哈希值\n", basePath, dp->d_name);
                    continue;
                }
                strcpy(fileInfo->path, basePath);
                strcat(fileInfo->path, "/");
                strcpy(fileInfo->name, dp->d_name);

                // 移除路径末尾的斜杠
                int len = strlen(fileInfo->path);
                if (fileInfo->path[len - 1] == '/') {
                    fileInfo->path[len - 1] = '\0';
                }

                // 替换反斜杠为正斜杠
                char *p;
                while ((p = strchr(fileInfo->path, '\\')) != NULL) {
                    *p = '/';
                }

                FILESCOUNT++;//文件数量

                // 将任务添加到线程池
                addTaskToThreadPool(pool, fileInfo);
            }
        }
    }

    closedir(dir);
}


int main() {
    setlocale(LC_ALL, "");

    // 提示用户是否计算子文件夹中的哈希值
    char input;
    printf("Do you want to calculate hash values for files in subfolders? (Y/N, press Enter to confirm): ");
    wprintf(L"\n--> 是否计算子文件夹文件哈希值? (Y/N, 是就直接回车): ");
    scanf("%c", &input);
    bool calculateSubfolders = (input == 'y' || input == 'Y' || input == '\n');



    start = clock(); // 记录开始时间

    // 获取当前目录路径
    char basePath[FILE_PATH_MAX_LENGTH];
    if (getcwd(basePath, sizeof(basePath)) == NULL) {
        perror("getcwd() error");
        return 1;
    }

    // 创建 Hash.json 文件，以写入的方式
    FILE *file = fopen("00_Hash.json", "rb+");//此处需要以二进制形式打开才行 不然卡住不动 要么换种方式编写 也不要换成a+ 不然需要修改逻辑
    if (!file) {
        perror("00_Hash.json File open error");//中文输出会乱码 用wprintf才行
        wprintf(L"\nFile open error / 文件不存在 已自动创建 00_Hash.json 文件");
        //文件不存在就创建
        file = fopen("00_Hash.json", "w");//这里都可以 创建文件就行
    }

    if (!file) {
        perror("File open error 文件打开错误");
        return 1;
    }

    /**///二进制形式 打开处理开头加上[ 末尾去掉] 满足json格式 方便追加内容
    // 用于记录查找过程中的字符
    char filechar;
    off_t pos;//存储文件位置
    long filesize;//计算文件大小

    // 将文件指针移动到文件末尾
    fseek(file, 0, SEEK_END);

    filesize = ftell(file);
    // 如果文件为空，写入一个'['字符
    if (filesize <= 5) {//兼容UTF-BOM 占用3个字节 给[留下2个字节空间 [但是此程序编码是UTF-8]
        //文件指针移到文件开头
        fseek(file, 0, SEEK_SET);
        //为了省事少写代码 文件字节数小于5 直接截断为空 
        if (ftruncate(fileno(file), 0) == -1) {
        perror("Error truncating file");
        wprintf(L"Error truncating file 文件截断为空失败");
        fclose(file);
        return 1;
        }
        // 写入新的内容
        fputs("[\n", file);
    }else{
        // 逐个向前查找，直到找到 "{"
        while (filesize > 0) {
            fseek(file, -1, SEEK_CUR);
            filechar = fgetc(file);
            //没有找到任意一个}符号 就不是[{},{}]这种之类格式 有可能是全是数组的json格式[[],[]] 提示用户文件格式不一定是JSON格式
            if (ftell(file) <= 3) {
                wprintf(L"\n找不到任意的 }符号   Hash文件格式不是此程序所需的JSON格式\n");
                fseek(file, 0, SEEK_END);
                fputs("\n\n\n", file);//
                fflush(file); // 立即刷新文件缓冲区
                wprintf(L"文件计算后依然会写入到Hash文件中 可能需要自己手动调整....\n");
                break;
            }
            // wprintf(L"%d",ftell(file));
            if (filechar == '}') {
                // 找到了字符'}'，获取当前的文件指针位置
                pos = ftell(file);//用于获取文件指针在文件末尾的偏移量 以确定文件的大小
                // 将文件指针移动到找到的 '}' 后面
                fseek(file, pos, SEEK_SET);
                
                // 写入',\n'
                // fwprintf(file, L",\n666");//字符之间会多出一个空格 因为宽字符函数fwprintf原因
                fputs(",\n", file);
                // 截断文件到当前位置
                if (ftruncate(fileno(file), ftell(file)) == -1) {
                    perror("Error truncating file");
                    fclose(file);
                    break;
                } 
                wprintf(L"--> 找到文件00_Hash.json字符 %c 已做JSON格式处理\n", filechar);
                break;
            }

            // printf("字符是 %c\n",filechar);
            fseek(file, -1, SEEK_CUR);
        }
    }

    /**/
    // 将文件指针移动到文件末尾
    fseek(file, 0, SEEK_END);//文件指针移不移动都行 下面会关闭文件
    // 关闭文件
    fclose(file);

    // 创建线程池
    ThreadPool *pool = initializeThreadPool(MAX_THREADS);

    // 创建线程来处理文件
    for (int i = 0; i < CREATED_MAX_THREADS; ++i) {
        DWORD threadId;
        HANDLE thread = CreateThread(NULL, 0, ProcessFiles, pool, 0, &threadId);
        if (thread == NULL) {
            perror("Error creating thread");
            return 1;
        }
        pool->threads[i] = thread;
        pool->numThreads++;
        // wprintf(L"创建线程 %d 加入线程池", i);
    }

    // 递归遍历所有文件，将文件信息和哈希值写入到 00_Hash.json 文件中
    listFilesRecursively(pool, basePath, file, calculateSubfolders);

    // 等待所有任务完成
    while (pool->numTasks > 0) {
        // Sleep for a short time to avoid busy waiting
        Sleep(10);
    }

    // end = clock(); // 记录结束时间
    // cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC; // 计算时间差并转换为秒
    // printf("\n--> Program running time: %f 秒\n", cpu_time_used);

    // 销毁线程池
    destroyThreadPool(pool);

    wprintf(L"\n--> 哈希值计算结果已保存到 %s\\00_Hash.json 文件中\n", basePath);
    wprintf(L"--> 文件总数: %d \n\n", FILESCOUNT);

    system("pause");

    return 0;
}

