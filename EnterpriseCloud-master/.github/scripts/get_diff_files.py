"""
Get changed files using GitHub API.
"""

import os
import json
import re
import urllib.request
from pathlib import Path

TOKEN = os.environ.get("GITHUB_TOKEN", "")
REPOSITORY = os.environ.get("GITHUB_REPOSITORY", "")
PR_NUMBER = os.environ.get("PR_NUMBER", "")
BASE_REF = os.environ.get("INPUT_BASE_REF", "")
HEAD_REF = os.environ.get("INPUT_HEAD_REF", "")
FILTER = os.environ.get("INPUT_GRAB_ON", "")
SQL_ONLY = os.environ.get("INPUT_SQL_ONLY", "false").lower() == "true"

def call_api(endpoint):

    url = f"https://api.github.com{endpoint}"
    
    request = urllib.request.Request(url)
    request.add_header("Authorization", f"token {TOKEN}")
    request.add_header("Accept", "application/vnd.github.v3+json")
    
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def get_pr_files(repo, pr_number):

    all_files = []
    page = 1
    
    while True:
        endpoint = f"/repos/{repo}/pulls/{pr_number}/files?per_page=100&page={page}"
        files = call_api(endpoint)
        
        if not files:
            break
        
        all_files.extend(files)
        page += 1
        
        if len(files) < 100:
            break
    
    return all_files


def get_diff_files(repo, base, head):

    endpoint = f"/repos/{repo}/compare/{base}...{head}"
    response = call_api(endpoint)
    return response.get("files", [])

def matches(filepath):

    if not filepath:
        return False
    
    path = Path(filepath).as_posix()
    
    if FILTER and not re.search(re.escape(FILTER), path, flags=re.IGNORECASE):
        return False
    
    if SQL_ONLY and Path(path).suffix.lower() != ".sql":
        return False
    
    return True


def dedupe(items):

    seen = set()
    result = []
    for item in items:
        if item not in seen:
            result.append(item)
            seen.add(item)
    return result


def process_files(files):

    changed = []
    deleted = []
    
    for file in files:
        filename = file.get("filename", "")
        status = file.get("status", "")
        previous_filename = file.get("previous_filename", "")
        
        if status == "removed":
            if matches(filename):
                deleted.append(Path(filename).as_posix())
        
        elif status == "renamed":
            if matches(filename):
                changed.append(Path(filename).as_posix())
            if previous_filename and matches(previous_filename):
                deleted.append(Path(previous_filename).as_posix())
        
        elif status in ("added", "modified", "copied", "changed"):
            if matches(filename):
                changed.append(Path(filename).as_posix())
    
    return dedupe(changed), dedupe(deleted)

def write_outputs(changed, deleted):

    output_file = os.environ.get("GITHUB_OUTPUT", "")
    
    outputs = {
        "changed_files": "||".join(changed),
        "deleted_files": "||".join(deleted),
        "has_changes": "true" if changed else "false",
        "has_deletes": "true" if deleted else "false",
    }
    
    if output_file:
        with open(output_file, "a") as f:
            for key, value in outputs.items():
                f.write(f"{key}={value}\n")
    else:
        for key, value in outputs.items():
            print(f"{key}={value}")


def print_results(changed, deleted):

    print("::group::Changed (copy)")
    print("\n".join(changed) if changed else "(none)")
    print("::endgroup::")
    
    print("::group::Deleted (delete)")
    print("\n".join(deleted) if deleted else "(none)")
    print("::endgroup::")
    
    print(f"\nTotal: {len(changed)} changed, {len(deleted)} deleted")

def main():
    print(f"Repository: {REPOSITORY}")
    print(f"Filter: {FILTER or '(none)'}")
    print(f"SQL Only: {SQL_ONLY}")
    print("")
    
    if PR_NUMBER:
        print(f"Mode: Pull Request #{PR_NUMBER}")
        files = get_pr_files(REPOSITORY, PR_NUMBER)
    elif BASE_REF and HEAD_REF:
        print(f"Mode: Diff {BASE_REF}...{HEAD_REF}")
        files = get_diff_files(REPOSITORY, BASE_REF, HEAD_REF)
    else:
        raise Exception("Set PR_NUMBER or (INPUT_BASE_REF and INPUT_HEAD_REF)")
    
    print(f"API returned: {len(files)} files")
    print("")
    
    changed, deleted = process_files(files)
    print_results(changed, deleted)
    write_outputs(changed, deleted)


if __name__ == "__main__":
    main()





# - name: Get changed files
#   id: files
#   shell: python
#   env:
#     GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
#     GITHUB_REPOSITORY: ${{ github.repository }}
#     PR_NUMBER: ${{ github.event.pull_request.number }}
#     INPUT_GRAB_ON: "astro_datautility/dags/dbt/"
#     INPUT_SQL_ONLY: "false"
#   run: python .github/scripts/get_diff_files.py



# - name: Get changed files
#   id: files
#   shell: python
#   env:
#     GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
#     GITHUB_REPOSITORY: ${{ github.repository }}
#     INPUT_BASE_REF: ${{ github.event.before }}
#     INPUT_HEAD_REF: ${{ github.event.after }}
#     INPUT_GRAB_ON: "astro_datautility/"
#   run: python .github/scripts/get_diff_files.py