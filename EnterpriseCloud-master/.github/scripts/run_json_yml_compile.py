import argparse
import json
import logging
import sys
from pathlib import Path

import yaml

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Validate changed JSON and YAML files."
    )
    parser.add_argument(
        "--changed-files",
        required=True,
        help='Changed files separated by "||"',
    )
    return parser.parse_args()


def get_target_files(changed_files_arg: str):
    with open(changed_files_arg, 'r', encoding='utf-8') as f:
        raw = f.read().strip()
    changed_files = [
        Path(f)
        for f in raw.split('||')
        if f.strip()
    ]
    # changed_files = [
    #     Path(f.strip())
    #     for f in changed_files_arg.split("||")
    #     if f.strip()
    # ]
    log.info(f"Changed files: {changed_files}")

    allowed_suffixes = {".json", ".yml", ".yaml"}
    selected_files = []
    seen = set()

    for file_path in changed_files:
        if file_path.suffix.lower() in allowed_suffixes:
            normalized = str(file_path)
            if normalized not in seen:
                seen.add(normalized)
                selected_files.append(file_path)

    return selected_files


def validate_json(filepath: Path):
    with open(filepath, "r", encoding="utf-8") as f:
        json.load(f)


def validate_yaml(filepath: Path):
    with open(filepath, "r", encoding="utf-8") as f:
        yaml.safe_load(f)


def main():
    args = parse_args()
    files_to_validate = get_target_files(args.changed_files)

    if not files_to_validate:
        log.info("No JSON/YML/YAML files to validate.")
        return 0

    error_indicator = 0

    for filepath in files_to_validate:
        if not filepath.exists() or not filepath.is_file():
            log.info(f"{filepath} not found or not a valid file")
            continue

        log.info(f".. Checking file {filepath}")

        try:
            suffix = filepath.suffix.lower()

            if suffix == ".json":
                validate_json(filepath)
                print(f"VALID JSON: {filepath}")
            elif suffix in {".yml", ".yaml"}:
                validate_yaml(filepath)
                print(f"VALID YAML: {filepath}")

        except json.JSONDecodeError as e:
            print(f"INVALID JSON: {filepath}")
            print(e)
            error_indicator = 1
        except yaml.YAMLError as e:
            print(f"INVALID YAML: {filepath}")
            print(e)
            error_indicator = 1
        except Exception as e:
            print(f"ERROR: {filepath}")
            print(e)
            error_indicator = 1

    if error_indicator:
        print("One or more JSON/YAML files failed validation")
        return 1

    print("All JSON/YAML files passed validation")
    return 0


if __name__ == "__main__":
    sys.exit(main())