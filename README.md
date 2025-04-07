# QQNT Backup

An automation tool to backup QQNT chats in form of plain text.

# Preparation

- Python 3.11 or higher
- GNU make
- unzip, curl, git

# Instructions

First, install the required dependencies:

```bash
pip install -r requirements.txt
```

Next, prepare codes:

```shell
make help # to get help messages
make prepare # network is needed to download codes from github
```

You should get your uid and encrypted database by yourself. Check
[here](https://github.com/xCipHanD/qqnt_backup) for details.

You can change `THREAD_NUM` in `Makefile` if necessary.

Finally, convert database into plain texts:

```shell
make convert UID=your-uid DBPATH=path/to/your/databases
```

You will find all the converted text in `plaintext` directory.

After the extraction, you may want to clean all cache files:

```shell
make clean-cache
```

You can also clean all files including output plain text files:

```shell
make clean
```

# Acknowledgement

- [xCipHanD/qqnt_backup](https://github.com/xCipHanD/qqnt_backup) for decryption tool
- [Tealina28/QQNT_Export](https://github.com/Tealina28/QQNT_Export.git) for extraction tool
