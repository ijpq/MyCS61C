# Staff README

### Assignment Usage

`loader.py` should be copied to somewhere in the assignment repo.

`program_template` should also be copied (it's small, can be multiple), renamed (e.g. `venus` to run Venus), and updated so the import path inside points to the location of `loader.py`. Then `./venus` (or `python ./venus`) will behave as if it were the real Venus (flags/args/signals/whatever `execvp()` supports), but with auto-update, and multiple assignments can share the same programs so we don't end up with 6 copies of Logisim floating around.

### `version.json` format
```
{
  "logisim": {
    "latest": {
      "ref": "0.0.1"
    },
    "dev": {
      "ref": "0.0.2"
    },
    "0.0.2": {
      "version": "0.0.2",
      "url": "http://127.0.0.1/tools/logisim-evolution-0.0.2.jar",
      "sha256": "fd18cd69ee4232a3099448f1e32f29ee91777241d4942e640b6ec3d100e54747"
    },
    "0.0.1": {
      "version": "0.0.1",
      "url": "http://127.0.0.1/tools/logisim-evolution-0.0.1.jar",
      "sha256": "fd18cd69ee4232a3099448f1e32f29ee91777241d4942e640b6ec3d100e54747"
    }
  },
  "venus": {
    "latest": {
      "ref": "0.0.1-sp21"
    },
    "0.0.1-sp21": {
      "version": "0.0.1-sp21",
      "url": "http://127.0.0.1/tools/venus-0.0.1-sp21.jar",
      "sha256": "f63e9df182a5db5054431b4f1458550d2b0de1b56f7f4a4920923a19bf237206"
    }
  }
}
```
