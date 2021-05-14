from datetime import datetime, timedelta
import argparse
import importlib
import os
import pathlib
import shlex
import subprocess
import sys
import traceback

ISO_FORMAT_STRING = r"%Y-%m-%dT%H:%M:%S.%f"

tools_dir = pathlib.Path(__file__).parent.absolute()
tools_git_dir = os.path.join(tools_dir, ".git")
last_updated_path = os.path.join(tools_dir, ".last_updated")

manager = importlib.import_module("manager")

parser = argparse.ArgumentParser()
parser.add_argument("program_name", choices=(manager.programs.keys() if manager else None))
parser.add_argument("-k", "--keep", dest="keep_old_files", help="keep old program versions", action="store_true", default=False)
parser.add_argument("-q", "--quiet", dest="quiet", help="silence output", action="store_true", default=False)
parser.add_argument("-u", "--update-interval", dest="update_interval", help="how long to wait between update checks (in seconds) (-1 means never update)", type=int, default=3600)
parser.add_argument("-v", "--version", dest="program_version", help="use a specific version of the program", type=str, default="latest")
parser.add_argument("program_args", nargs=argparse.REMAINDER)

def run(**kwargs):
    try:
        update_tools(**kwargs)

        manager.update_programs(**kwargs)

        manager.run_program(**kwargs)
    except KeyboardInterrupt:
        sys.exit(1)

def update_tools(update_interval=3600, quiet=False, **kwargs):
    global manager

    if update_interval < 0:
        return

    if not os.path.isfile(os.path.join(tools_git_dir, "config")):
        if not quiet:
            print("Warning: 61c-tools is not a valid Git repo, updates may be skipped", file=sys.stderr)
        return

    try:
        status_output = subprocess.check_output(["git", f"--git-dir={tools_git_dir}", "status", "--porcelain"], cwd=tools_dir)
        if len(status_output) > 0:
            if not quiet:
                print("Warning: 61c-tools has unsaved changes, updates may be skipped", file=sys.stderr)
            return
    except FileNotFoundError:
        print("Error: could not run Git. Is it installed?", file=sys.stderr)
        return
    last_updated = None
    try:
        if os.path.isfile(last_updated_path):
            with open(last_updated_path, "r") as f:
                last_updated = datetime.strptime(f.read().strip(), ISO_FORMAT_STRING)
    except KeyboardInterrupt as e:
        raise e
    except:
        traceback.print_exc()
    if last_updated and last_updated + timedelta(seconds=update_interval) >= datetime.now():
        return
    current_branch = subprocess.check_output(["git", f"--git-dir={tools_git_dir}", "rev-parse", "--abbrev-ref", "HEAD"], cwd=tools_dir).decode("utf-8").strip()
    if current_branch == "HEAD":
        print("Warning: 61c-tools has a detached Git HEAD, updates may be skipped", file=sys.stderr)
        return
    if not quiet:
        print("Updating 61c-tools...", file=sys.stderr)
    try:
        with open(last_updated_path, "w") as f:
            f.write(datetime.now().isoformat())

        subprocess.check_output(["git", f"--git-dir={tools_git_dir}", "fetch", "origin"], cwd=tools_dir)
        subprocess.check_output(["git", f"--git-dir={tools_git_dir}", "reset", "--hard", f"origin/{current_branch}"], cwd=tools_dir)

        manager = importlib.reload(manager)
    except KeyboardInterrupt as e:
        raise e
    except:
        traceback.print_exc()

if __name__ == "__main__":
    CS61C_TOOLS_ARGS = shlex.split(os.environ.get("CS61C_TOOLS_ARGS", ""))
    run(**vars(parser.parse_args(CS61C_TOOLS_ARGS + sys.argv[1:])))
