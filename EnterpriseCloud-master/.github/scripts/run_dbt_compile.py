import os, sys, re, json, argparse, subprocess, logging
from pathlib import Path
import shutil
import time
from unittest import result

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger(__name__)

ENV_CONFIG_PATH = os.path.join(".github", "scripts", "TelTools_Environment.json")



def run_dbt_deps_with_cleanup( dbt_project):
    """Run dbt deps with Windows file lock handling"""
    
    packages_dir = dbt_project / "dbt_packages"
    if packages_dir.exists():
        log.info(f"Cleaning {packages_dir}")
        try:
            shutil.rmtree(packages_dir, ignore_errors=True)
            time.sleep(5) 
        except Exception as e:
            log.warning(f"Cleanup warning: {e}")
    
    max_attempts = 3
    for attempt in range(1, max_attempts + 1):
        try:
            log.info(f"Running dbt deps (attempt {attempt}/{max_attempts})")
            result = subprocess.run(
                ['dbt', "deps"],
                cwd=str(dbt_project),
                check=True,
                capture_output=True,
                text=True
            )

            log.info("dbt deps succeeded")
            return
            
        except subprocess.CalledProcessError as e:
            # Check if it's a file lock error
            log.info(f"dbt deps stdout:\n{e.stdout}")
            log.error(f"dbt deps stderr:\n{e.stderr}")
            if "WinError 32" in e.stderr or "WinError 5" in e.stderr:
                if attempt < max_attempts:
                    wait_time = 3 * attempt  
                    log.warning(f"File lock detected, waiting {wait_time}s before retry...")
                    time.sleep(wait_time)
                else:
                    log.error("dbt deps failed after all retries")
                    print(e.stderr)
                    raise
            else:
                log.info(f"dbt deps stdout:\n{e.stdout}")
                log.error(f"dbt deps stderr:\n{e.stderr}")
                # Different error, fail immediately
                log.error(f"dbt deps failed: {e}")
                raise


def main():
    # --- Parse ALL_VARS safely ---
    raw_vars = os.environ.get("ALL_VARS")
    log.info(f"ALL_VARS type: {type(raw_vars)}")
    log.info(f"ALL_VARS length: {len(raw_vars) if raw_vars else 0}")

    try:
        ALL_VARS = json.loads(raw_vars)
        print(f"Parsed OK — keys: {list(ALL_VARS.keys())}")
    except json.JSONDecodeError as e:
        log.error(f"ALL_VARS JSON parse FAILED: {e}")
        if raw_vars and e.pos is not None:
            context = raw_vars[max(0, e.pos-20):e.pos+20]
            log.error(f"Error at position {e.pos}, context: {repr(context)}")
        return 1
    
    if not os.environ.get("SNOWFLAKE_SECRET"):
        log.error("SNOWFLAKE_SECRET not found in environment")
        return 1
    log.info(f"SNOWFLAKE_SECRET : {os.environ.get('SNOWFLAKE_SECRET')[:6]}****")
    # --- Args ---
    parser = argparse.ArgumentParser()
    parser.add_argument("--changed-files", default="")
    args = parser.parse_args()
    log.info(f"[DEBUG] Raw sys.argv: {sys.argv}")
    log.info(f"[DEBUG] Parsed args: {args}")

    base_dir = Path(os.environ["GITHUB_WORKSPACE"])
    dbt_directory = Path("astro_datautility/dags/dbt/dbt_tel")
    dbt_project = base_dir / dbt_directory
    dbt_profiles = dbt_project / "DEV_PROFILES"

    # --- Build vars for dbt ---
    vars_dict = {k: v for k, v in ALL_VARS.items() if k.startswith("SNOWFLAKE_")}
 
    os.environ.update(vars_dict)

    log.info("=== Credential Check ===")
    creds = {
        "SNOWFLAKE_ACCOUNT": os.environ.get("SNOWFLAKE_ACCOUNT"),
        "SNOWFLAKE_USER": os.environ.get("SNOWFLAKE_USER"),
        "SNOWFLAKE_SECRET": os.environ.get("SNOWFLAKE_SECRET"),
        "SNOWFLAKE_ROLE": os.environ.get("SNOWFLAKE_ROLE"),
    }

    for key, value in creds.items():
        if value:
            if "SECRET" in key:
                log.info(f"{key}: Set ({len(value)} chars)")
            else:
                log.info(f"{key}: {value}")
        else:
            log.error(f"{key}: MISSING")

    log.info(f"Injected {len(vars_dict)} vars into environment")
    # --- Changed files ---
    with open(args.changed_files, 'r', encoding='utf-8') as f:
        raw = f.read().strip()
    log.info(f"RAW: {raw}")   
    changed_files = [
        Path(f).stem
        for f in raw.split('||')
        if f.strip()
    ]
    log.info(f"Changed files: {changed_files}")

    try:
        # log.info(f"Running: dbt deps --profiles-dir {dbt_profiles}")
        # subprocess.run(["dbt", "deps"], cwd=str(dbt_project), check=True)
        run_dbt_deps_with_cleanup(dbt_project)
        # compile
        
        print(f"Running dbt compile for changed files: {changed_files}")
        cmd = [
            "dbt", "compile",
            "--profiles-dir", str(dbt_profiles),
            "--select", *changed_files  
        ]
        log.info(f"Running: {' '.join(cmd)}")
        log.info(f"SNOWFLAKE_USER : {os.environ.get('SNOWFLAKE_USER')}")
        log.info(f"SNOWFLAKE_ACCOUNT : {os.environ.get('SNOWFLAKE_ACCOUNT')}")
        log.info(f"SNOWFLAKE_ROLE : {os.environ.get('SNOWFLAKE_ROLE')}")
        log.info(f"SNOWFLAKE_WAREHOUSE : {os.environ.get('SNOWFLAKE_WAREHOUSE')}")
        log.info(f"SNOWFLAKE_ADMIN : {os.environ.get('SNOWFLAKE_ADMIN')}")

                 

        result = subprocess.run(cmd, cwd=str(dbt_project), capture_output=True, text=True)

        print(result.stdout)
        if result.returncode != 0:
            print(result.stderr)
            print(f"::error title=dbt compile failed::{result.stderr.strip()[:200]}")
            return result.returncode

        return 0

    except subprocess.CalledProcessError as e:
        log.error(f"Command failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())