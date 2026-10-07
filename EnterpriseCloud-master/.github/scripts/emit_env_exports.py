import json
from pathlib import Path
import os

ENV_CONFIG_PATH = os.path.join(
    ".github", "scripts", "TelTools_Environment.json"
)

def main():
    data = json.loads(Path(ENV_CONFIG_PATH).read_text())
    for key in data.keys():
        key_lower = key.lower()
        if "secret" in key_lower or "password" in key_lower:
            print(f"{key}=${{{{ secrets.{key} }}}}")
        else:
            print(f"{key}=${{{{ vars.{key} }}}}")

if __name__ == "__main__":
    main()
