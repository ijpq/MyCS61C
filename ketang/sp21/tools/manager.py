from collections.abc import Iterable
from datetime import datetime, timedelta
import hashlib
import json
import os
import pathlib
import re
import sys
import traceback

BYTE_PREFIXES = {0: "", 1: "Ki", 2: "Mi", 3: "Gi"}
ISO_FORMAT_STRING = r"%Y-%m-%dT%H:%M:%S.%f"
VERSION_URL = "https://inst.eecs.berkeley.edu/~cs61c/sp21/tools/version.json"

tools_dir = pathlib.Path(__file__).parent.absolute()
programs_dir = os.path.join(tools_dir, "programs")
version_file_path = os.path.join(tools_dir, "version.json")

class Program:
    def __init__(self, name, ext):
        self.name = name
        self.ext = ext
    def get_file_path(self, version):
        return os.path.join(programs_dir, f"{self.name}-{version}.{self.ext}")
    def get_run_args(self, **kwargs):
        version = get_version_data(self.name, **kwargs)["version"]
        path = self.get_file_path(version)
        if not os.path.isfile(path):
            other_versions = self.get_installed_versions()
            if len(other_versions) < 1:
                raise Exception(f"Could not find program files for {self.name}")
            # No version sort data, just pick the first one
            version = other_versions[0]
            path = self.get_file_path(version)
            print(f"Warning: {self.name} {version} is outdated", file=sys.stderr)
        if self.ext == "jar":
            return ["java", "-jar", path]
        raise Exception(f"Unknown program type: {self.ext}")
    def get_version(self, filename):
        m = re.match(f"^{self.name}-([0-9][0-9a-z.-]+)\\.{self.ext}$", filename)
        if not m:
            return None
        return m.group(1)
    def get_installed_versions(self):
        versions = []
        try:
            for filename in os.listdir(programs_dir):
                if not os.path.isfile(os.path.join(programs_dir, filename)):
                    continue
                version = self.get_version(filename)
                if version:
                    versions.append(version)
        except FileNotFoundError:
            pass
        return versions
programs = {
    "logisim": Program("logisim", "jar"),
    "venus": Program("venus", "jar"),
}

def run_program(program_name, program_args=None, **kwargs):
    try:
        program = programs[program_name]
        args = program.get_run_args(**kwargs)
        if program_args:
            args.extend(program_args)

        # Windows bug: https://bugs.python.org/issue436259 (wontfix)
        if sys.platform == 'win32':
            import subprocess
            proc = subprocess.Popen(args)
            proc.communicate()
            sys.exit(proc.returncode)
        else:
            os.execvp(args[0], args)
    except FileNotFoundError:
        raise Exception(f"Error: could not run {args[0]}. Is it installed?")
    except KeyboardInterrupt as e:
        raise e

def update_programs(**kwargs):
    program_names = kwargs.pop("program_name", programs.keys())
    if not isinstance(program_names, Iterable) or isinstance(program_names, str):
        program_names = (program_names,)
    for program_name in program_names:
        update_program(program_name, **kwargs)

def update_program(program_name, keep_old_files=False, quiet=False, **kwargs):
    try:
        data = get_version_data(program_name, **kwargs)
        program = programs[program_name]

        other_vers = program.get_installed_versions()
        latest_ver = data["version"]
        if latest_ver in other_vers:
            other_vers.remove(latest_ver)
            return
        if not quiet:
            print(f"Updating {program_name} {other_vers} => {latest_ver}", file=sys.stderr)
        urls = [data["url"]]
        if "mirror_urls" in data:
            urls += data["mirror_urls"]
        did_get_file = False
        get_file_errors = []
        for url in urls:
            try:
                get_file(program.get_file_path(latest_ver), url, data["sha256"], quiet=quiet)
                did_get_file = True
                break
            except KeyboardInterrupt as e:
                raise e
            except Exception as e:
                if not quiet:
                    traceback.print_exc()
                get_file_errors.append(e)
        if not did_get_file:
            if quiet:
                for e in get_file_errors:
                    print(e, file=sys.stderr)
            print(f"Error: failed to download {program_name}", file=sys.stderr)
            return
        if not keep_old_files and len(other_vers) > 0:
            if not quiet:
                print(f"Removing {program_name} {other_vers}", file=sys.stderr)
            for other_ver in other_vers:
                if other_ver != latest_ver:
                    try:
                        os.remove(program.get_file_path(other_ver))
                    except FileNotFoundError:
                        traceback.print_exc()
    except KeyboardInterrupt as e:
        raise e
    except:
        traceback.print_exc()
        print(f"Error: failed to update {program_name}", file=sys.stderr)

def get_version_data(program_name, program_version="latest", update_interval=3600, **kwargs):
    program_version_data = get_version_json(update_interval)[program_name]
    if program_version not in program_version_data:
        raise Exception(f"Unrecognized {program_name} version: {program_version}")
    data = program_version_data[program_version]
    for _ in range(256):
        if "ref" in data:
            data = program_version_data[data["ref"]]
            continue
        return data
    raise Exception("Encountered potential cycle when resolving versions")

def get_version_json(update_interval=3600):
    data = None
    try:
        with open(version_file_path, "r") as f:
            _data = f.read()
            data = json.loads(_data)
            if update_interval < 0:
                return data
            if "_last_checked" in data:
                last_checked = datetime.strptime(data["_last_checked"], ISO_FORMAT_STRING)
                if last_checked + timedelta(seconds=update_interval) >= datetime.now():
                    return data
    except FileNotFoundError:
        pass
    try:
        import requests
        if update_interval < 0:
            raise Exception("No version data saved, but updating is disabled")
        res = requests.get(VERSION_URL)
        data = res.json()
        data["_last_checked"] = datetime.now().isoformat()
        with open(version_file_path, "w") as f:
            f.write(json.dumps(data))
        return data
    except Exception as e:
        if data:
            traceback.print_exc()
            return data
        raise e

def fmt_bytes(size):
    power = 2 ** 10
    n = 0
    while size > power:
        size /= power
        n += 1
    return f"{size:.1f}{BYTE_PREFIXES[n]}B"

def get_file(path, url, expected_digest, quiet=False):
    try:
        os.mkdir(programs_dir)
    except FileExistsError:
        pass

    is_stderr_interactive = not quiet and sys.stderr.isatty()

    temp_path = f"{path}.part"
    filename = os.path.basename(path)

    if not quiet:
        sys.stderr.write(f"Downloading {filename}...")
        sys.stderr.flush()
    import requests
    response = requests.get(url, stream=True)
    response.raise_for_status()
    bytes_total = response.headers.get("content-length")
    sha256 = hashlib.sha256()

    with open(temp_path, "wb") as f:
        if bytes_total is None:
            data = response.content
            f.write(data)
            sha256.update(data)
            if not quiet:
                print(" OK", file=sys.stderr)
        else:
            bytes_written = 0
            bytes_total = int(bytes_total)
            last_perc = -1
            for data in response.iter_content(chunk_size=65536):
                bytes_written += len(data)
                f.write(data)
                sha256.update(data)
                perc = int(50 * bytes_written / bytes_total)
                if last_perc != perc:
                    if is_stderr_interactive:
                        sys.stderr.write(f"\r[{'=' * perc}{' ' * (50 - perc)}] {fmt_bytes(bytes_written):>8}/{fmt_bytes(bytes_total):<8} {filename}")
                        sys.stderr.flush()
                    last_perc = perc
            if is_stderr_interactive:
                sys.stderr.write("\n")
                sys.stderr.flush()
            elif not quiet:
                sys.stderr.write(" Done\n")
                sys.stderr.flush()
        digest = sha256.hexdigest()
        if digest != expected_digest:
            raise Exception(f"Download failed: {filename} has bad checksum")
    os.rename(temp_path, path)
