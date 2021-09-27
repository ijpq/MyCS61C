from pathlib import Path
import argparse
import csv
import os
import re
import subprocess
import sys
import time
import traceback


CIRC_IMPORT_REGEX = re.compile(r"desc=\"file#([^\"]+?\.circ)\"")

proj_dir_path = Path(__file__).parent
tests_dir_path = proj_dir_path / "tests"
logisim_path = proj_dir_path / "tools" / "logisim"

tools_env = os.environ.copy()
tools_env["CS61C_TOOLS_ARGS"] = tools_env.get("CS61C_TOOLS_ARGS", "") + " -q"

known_imports_dict = {
  "cpu/cpu.circ": [
    "cpu/alu.circ",
    "cpu/branch-comp.circ",
    "cpu/control-logic.circ",
    "cpu/csr.circ",
    "cpu/imm-gen.circ",
    "cpu/regfile.circ",
  ],
  "harnesses/alu-harness.circ": [
    "cpu/alu.circ",
  ],
  "harnesses/csr-harness.circ": [
    "cpu/cpu.circ",
    "cpu/mem.circ",
  ],
  "harnesses/cpu-harness.circ": [
    "cpu/cpu.circ",
    "cpu/mem.circ",
  ],
  "harnesses/regfile-harness.circ": [
    "cpu/regfile.circ",
  ],
  "harnesses/run.circ": [
    "harnesses/cpu-harness.circ",
  ],
  "tests/part-a/alu/*.circ": [
    "cpu/alu.circ",
  ],
  "tests/part-a/regfile/*.circ": [
    "cpu/regfile.circ",
  ],
  "tests/part-b/sanity/cpu-csr*.circ": [
    "harnesses/csr-harness.circ",
  ],
  "tests/part-b/sanity/*.circ": [
    "harnesses/cpu-harness.circ",
  ],
}
known_imports_dict["tests/part-a/addi/*.circ"] = known_imports_dict["tests/part-b/sanity/*.circ"]
known_imports_dict["tests/part-b/custom/*.circ"] = known_imports_dict["tests/part-b/sanity/*.circ"]


class TestCase():
  def __init__(self, circ_path, name=None):
    self.circ_path = Path(circ_path)
    self.id = str(self.circ_path)
    self.name = name or self.circ_path.stem

  def can_pipeline(self):
    if self.circ_path.match("alu/*.circ") or self.circ_path.match("regfile/*.circ"):
      return False
    return True

  def fix_circ(self):
    fix_circ(self.circ_path)

  def get_actual_table_path(self):
    return self.circ_path.parent / "student-output" / f"{self.name}-student.out"

  def get_expected_table_path(self, pipelined=False):
    path = self.circ_path.parent / "reference-output" / f"{self.name}-ref.out"
    if pipelined:
      path = path.with_name(f"{self.name}-pipelined-ref.out")
    return path

  def run(self, pipelined=False):
    self.fix_circ()

    if pipelined and not self.can_pipeline():
      pipelined = False
    passed = False
    proc = None
    try:
      proc = subprocess.Popen([sys.executable, str(logisim_path), "-tty", "table,binary,csv", str(self.circ_path)], stdout=subprocess.PIPE, encoding="utf-8", errors="ignore", env=tools_env)

      with self.get_expected_table_path(pipelined=pipelined).open("r", encoding="utf-8", errors="ignore") as expected_file:
        passed = self.check_output(proc.stdout, expected_file)
        kill_proc(proc)
        if not passed:
          return (False, "Did not match expected output")
        return (True, "Matched expected output")
    except KeyboardInterrupt:
      kill_proc(proc)
      sys.exit(1)
    except:
      traceback.print_exc()
      kill_proc(proc)
    return (False, "Errored while running test")

  def check_output(self, actual_file, expected_file):
    passed = True
    actual_csv = csv.reader(actual_file)
    expected_csv = csv.reader(expected_file)
    actual_lines = []
    while True:
      actual_line = next(actual_csv, None)
      expected_line = next(expected_csv, None)
      if expected_line is None:
        break
      if actual_line != expected_line:
        passed = False
      if actual_line is None:
        break
      actual_lines.append(actual_line)
    output_path = self.get_actual_table_path()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w") as output_file:
      output_csv = csv.writer(output_file, lineterminator="\n")
      for line in actual_lines:
        output_csv.writerow(line)
    return passed

def fix_circ(circ_path):
  circ_path = circ_path.resolve()

  for glob, known_imports in known_imports_dict.items():
    if circ_path.match(glob):
      old_data = None
      data = None
      is_modified = False
      with circ_path.open("r", encoding="utf-8") as test_circ:
        old_data = test_circ.read()
        data = old_data
      for match in re.finditer(CIRC_IMPORT_REGEX, old_data):
        import_path_str = match.group(1)
        import_path = (circ_path.parent / Path(import_path_str)).resolve()
        for known_import in known_imports:
          if import_path.match(known_import):
            known_import_path = (proj_dir_path / known_import).resolve()
            expected_import_path = Path(os.path.relpath(known_import_path, circ_path.parent))
            if import_path_str != expected_import_path.as_posix():
              print(f"Fixing bad import {import_path_str} in {circ_path.as_posix()} (should be {expected_import_path.as_posix()})")
              data = data.replace(import_path_str, expected_import_path.as_posix())
              is_modified = True
            break
        else:
          expected_import_path = Path(os.path.relpath(import_path, circ_path.parent))
          if import_path_str != expected_import_path.as_posix():
            print(f"Fixing probably bad import {import_path_str} in {circ_path.as_posix()} (should be {expected_import_path.as_posix()})")
            data = data.replace(import_path_str, expected_import_path.as_posix())
            is_modified = True
      if is_modified:
        with circ_path.open("w", encoding="utf-8") as test_circ:
          test_circ.write(data)
      break

def run_tests(search_paths, pipelined=False):
  circ_paths = []
  for search_path in search_paths:
    if search_path.is_file() and search_path.suffix == ".circ":
      circ_paths.append(search_path)
      continue
    for circ_path in search_path.rglob("*.circ"):
      circ_paths.append(circ_path)
  circ_paths = sorted(circ_paths)

  for circ_path in proj_dir_path.rglob("cpu/*.circ"):
    fix_circ(circ_path)
  for circ_path in proj_dir_path.rglob("harnesses/*.circ"):
    fix_circ(circ_path)

  failed_tests = []
  passed_tests = []
  for circ_path in circ_paths:
    test = TestCase(circ_path)
    did_pass, reason = False, "Unknown test error"
    try:
      did_pass, reason = test.run(pipelined=pipelined)
    except KeyboardInterrupt:
      sys.exit(1)
    except SystemExit:
      raise
    except:
      traceback.print_exc()
    if did_pass:
      print(f"PASS: {test.id}", flush=True)
      passed_tests.append(test)
    else:
      print(f"FAIL: {test.id} ({reason})", flush=True)
      failed_tests.append(test)

  print(f"Passed {len(passed_tests)}/{len(failed_tests) + len(passed_tests)} tests", flush=True)


def kill_proc(proc):
  if proc.poll() is None:
    proc.terminate()
    for _ in range(10):
      if proc.poll() is not None:
        return
      time.sleep(0.1)
  if proc.poll() is None:
    proc.kill()


if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Run Logisim tests")
  parser.add_argument("test_path", help="Path to a test circuit, or a directory containing test circuits", type=Path, nargs="+")
  parser.add_argument("-p", "--pipelined", help="Check against reference output for 2-stage pipeline (when applicable)", action="store_true", default=False)
  args = parser.parse_args()

  run_tests(args.test_path, args.pipelined)
