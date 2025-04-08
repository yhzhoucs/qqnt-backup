# QQNT Backup

An automation tool to back up QQNT chats as plain text.

## Preparation

### Linux

- Python 3.11 or higher  
- GNU Make  
- `unzip`, `curl`, `git`  

### Windows

- PowerShell  
- Git  

## Instructions

### Linux

First, install the required Python dependencies:

```bash
pip install -r requirements.txt
```

Then, prepare the environment:

```bash
make help       # Show help messages
make prepare    # Requires network access to download code from GitHub
```

You will need to obtain your own QQ UID and encrypted database files. See  
[xCipHanD/qqnt_backup](https://github.com/xCipHanD/qqnt_backup) for instructions.

If necessary, you can adjust the `THREAD_NUM` variable in the `Makefile`.

To convert the database into plain text:

```bash
make convert UID=your-uid DBPATH=path/to/your/databases
```

All converted chat logs will be saved in the `plaintext` directory.

To clean up temporary cache files after conversion:

```bash
make clean-cache
```

To remove **all** generated files, including the plain text output:

```bash
make clean
```

### Windows

Run the `all-in-one.ps1` script in **PowerShell**.

All functionality is packed into this single PowerShell script. You can view usage instructions with:

```powershell
Get-Help ./all-in-one.ps1
```

On the first run, the script will automatically download and initialize a Python environment:

```powershell
./all-in-one.ps1
```

You’ll be prompted to enter your QQ UID and the path to your database files:

```
Enter your QQ UID (e.g., u_12345678):
Enter the path to your database files (e.g., ./qq-nt-dbs):
```

⚠️ Please verify that your inputs are correct.

On subsequent runs, dependency files will not be downloaded again unless they are missing or corrupted.

You can enable automatic cleanup after conversion by adding the `-WithCleanup` flag:

```powershell
./all-in-one.ps1 -WithCleanup
```

To **only** perform cleanup without conversion:

```powershell
./all-in-one.ps1 -JustCleanup
```

You may also specify the number of threads for the conversion process:

```powershell
./all-in-one.ps1 -ThreadNum 4
```

## Acknowledgements

- [xCipHanD/qqnt_backup](https://github.com/xCipHanD/qqnt_backup) — for the decryption tool  
- [Tealina28/QQNT_Export](https://github.com/Tealina28/QQNT_Export.git) — for the extraction tool