import os
import pathlib
import re
import subprocess
import sys
import traceback

ASSIGNMENT_NAME_REGEX = r"(\b|-|^)(lab|labs|proj[1-4])(\b|-|$)"
JAVA_VERSION_REGEX = r"^\w*(java|jdk)\s*version\s*\"([^\"]+)\""

tools_dir = pathlib.Path(__file__).parent.absolute()
tools_git_dir = os.path.join(tools_dir, ".git")

issues = []

try:
    import requests
    print("Found required dependencies")
except ModuleNotFoundError:
    issues.append("Error: could not find required dependencies. Have you installed them?")

try:
    subprocess.check_output(["git", "--help"])
    print("Found Git program")
except ModuleNotFoundError:
    issues.append("Error: could not run Git. Is Git installed?")

if not os.path.isfile(os.path.join(tools_git_dir, "config")):
    print("Couldn't find Git data in repo folder")
    issues.append("Error: 61c-tools is not a valid Git repo")
else:
    print("61c-tools was cloned properly")

try:
    assignment_repo_names = []
    for name in os.listdir(os.path.dirname(tools_dir)):
        if re.search(ASSIGNMENT_NAME_REGEX, name):
            assignment_repo_names.append(name)
    if len(assignment_repo_names) >= 2:
        print(f"Found assignment repos: {assignment_repo_names}")
    elif len(assignment_repo_names) == 1:
        print(f"Warning: did not find many assignment repos in parent directory: {assignment_repo_names}")
    else:
        print(f"Found assignment repos: {assignment_repo_names}")
        issues.append("Error: did not find any assignment repos in parent directory")
except:
    issues.append("Error: could not check for assignment repos in parent directory")
    traceback.print_exc()

try:
    java_version_out = subprocess.check_output(["java", "-version"], stderr=subprocess.STDOUT)
    java_version_out = java_version_out.decode("utf-8", errors="ignore")
    try:
        match = re.match(JAVA_VERSION_REGEX, java_version_out)
        java_version = match[2]
        print(f"Java version: {java_version}")
    except:
        print(f"Unrecognized Java version string:\n{java_version_out}\n")
        raise Exception("Unrecognized Java version string")
except:
    traceback.print_exc()
    issues.append("Error: Java check failed, is it installed and in your PATH?")

if len(issues) == 0:
    print("Your 61c-tools install looks OK!")
else:
    print("Your 61c-tools install might have issues:")
    print("\n".join(issues))
    sys.exit(1)
