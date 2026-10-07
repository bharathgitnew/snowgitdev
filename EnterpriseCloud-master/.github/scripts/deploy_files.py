import os
import smbclient
from pathlib import Path

SERVER = os.environ.get("SERVER_NAME")
SHARE = os.environ.get("SHARE_PATH", "Shares")  
USERNAME = os.environ.get("SVC_USERNAME", "us\\svc_prefect")
PASSWORD = os.environ.get("SVC_PREFECT_AD_PASSWORD")

WORKSPACE = os.environ.get("GITHUB_WORKSPACE", ".")
CHANGED_FILES = os.environ.get("CHANGED_FILES", "")
DELETED_FILES = os.environ.get("DELETED_FILES", "")


def main():
    if not SERVER:
        raise Exception("SERVER_NAME is required")
    if not PASSWORD:
        raise Exception("SVC_PREFECT_AD_PASSWORD is required (from Key Vault)")

    print("=" * 50)
    print("  DEPLOYMENT")
    print("=" * 50)
    print(f"Server: {SERVER}")
    print(f"Share:  {SHARE}")
    print(f"User:   {USERNAME}")
    print("=" * 50)

    # Authenticate explicitly as the service account - bypasses runner's
    # NETWORK SERVICE / machine-account identity entirely.
    smbclient.register_session(SERVER, username=USERNAME, password=PASSWORD)

    changed = [f.strip() for f in CHANGED_FILES.split("||") if f.strip()]
    deleted = [f.strip() for f in DELETED_FILES.split("||") if f.strip()]

    source_base = Path(WORKSPACE)
    target_base = f"\\\\{SERVER}\\{SHARE}"

    print(f"Copy:   {len(changed)} files")
    print(f"Delete: {len(deleted)} files")
    print("")

    copied, removed, failed = 0, 0, 0

    if deleted:
        print("DELETING from share...")
        for filepath in deleted:
            target = f"{target_base}\\{filepath.replace('/', chr(92))}"
            print(target)
            try:
                if smbclient.path.exists(target):
                    smbclient.remove(target)
                    print(f"relative path:::{filepath}")
                    removed += 1
                else:
                    print(f" - Already gone: {filepath}")
            except Exception as e:
                print(f"{filepath} - {e}")
                failed += 1
        print("")

    if changed:
        print("COPYING to share...")
        for filepath in changed:
            source = source_base / filepath
            target = f"{target_base}\\{filepath.replace('/', chr(92))}"
            print(target)
            if not source.exists():
                print(f" Not in checkout: {filepath}")
                continue
            try:
                target_dir = str(Path(target).parent)
                smbclient.makedirs(target_dir, exist_ok=True)
                with open(source, "rb") as src_f:
                    data = src_f.read()
                with smbclient.open_file(target, mode="wb") as dst_f:
                    dst_f.write(data)
                print(f"relative path:::{filepath}")
                copied += 1
            except Exception as e:
                print(f"{filepath} - {e}")
                failed += 1
        print("")

    print("=" * 50)
    print(f"  Copied:  {copied}")
    print(f"  Deleted: {removed}")
    print(f"  Failed:  {failed}")
    print("=" * 50)

    if failed > 0:
        raise Exception(f"Deployment failed: {failed} errors")


if __name__ == "__main__":
    main()