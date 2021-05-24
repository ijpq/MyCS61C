# sp21-tools

This is a centralized repository for tools we'll be using this semester that are normally distributed in binary format, namely Logisim and Venus. In addition to avoiding the bad practice of keeping binaries in git, this repository also provides automatic updates to those tools, and a few other goodies.

### Setup

Please clone this repo in the same parent directory as your other assignment repos. If your work was in the `~/cs61c` directory, then your folder layout should look something like this:

```
~/cs61c $ ls
lab
proj1
proj2
proj3
proj4
tools
```

All the folders shown are in the same folder.

Run `python3 -m pip install -r requirements.txt` to install dependencies. Then, run `python3 check_install.py` to verify your install.
