# QQNT Backup

一个用于备份 QQ NT 聊天记录为纯文本的自动化工具。

## 环境准备

### Linux 系统

- Python 3.11 或更高版本
- GNU Make
- `unzip`、`curl`、`git` 命令工具

### Windows 系统

- PowerShell
- Git

## 使用说明

### Linux

首先，安装依赖：

```bash
pip install -r requirements.txt
```

然后准备环境：

```bash
make help        # 查看帮助信息
make prepare     # 从 GitHub 下载必要代码（需要联网）
```

你需要自行获取你的 QQ UID 和加密数据库文件。具体方法请参考 [xCipHanD/qqnt_backup](https://github.com/xCipHanD/qqnt_backup)。

如有需要，你可以在 `Makefile` 中修改 `THREAD_NUM` 来调整线程数。

进行数据库转换：

```bash
make convert UID=你的UID DBPATH=你的数据库路径
```

转换后的聊天记录将保存在 `plaintext` 目录下。

完成后可使用以下命令清除缓存文件：

```bash
make clean-cache
```

如需清除包括输出在内的所有生成文件：

```bash
make clean
```

### Windows

在 **PowerShell** 中运行 `all-in-one.ps1` 脚本。

所有功能都封装在这个单独的脚本中。你可以通过以下命令查看用法：

```powershell
Get-Help ./all-in-one.ps1
```

首次运行时脚本会自动下载并初始化 Python 环境：

```powershell
./all-in-one.ps1
```

运行过程中会提示你输入 QQ UID 以及数据库文件路径：

```
请输入你的 QQ UID（例如：u_12345678）：
请输入数据库文件路径（例如：./qq-nt-dbs）：
```

⚠️ 请自行确认输入信息的正确性。

后续再次运行时，依赖文件不会重复下载，除非文件已损坏或丢失。

你可以使用 `-WithCleanup` 参数在转换结束后自动清理临时依赖：

```powershell
./all-in-one.ps1 -WithCleanup
```

也可以仅进行清理而不执行转换：

```powershell
./all-in-one.ps1 -JustCleanup
```

如需指定转换时使用的线程数量：

```powershell
./all-in-one.ps1 -ThreadNum 4
```

## 致谢

- [xCipHanD/qqnt_backup](https://github.com/xCipHanD/qqnt_backup) —— 提供解密工具
- [Tealina28/QQNT_Export](https://github.com/Tealina28/QQNT_Export.git) —— 提供导出工具
