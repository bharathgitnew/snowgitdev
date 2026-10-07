import glob
import os
import sys

#file_pattern = "C:\\Users\\svc_prefect\\.prefect\\results\\prefect-result-*"

def main(file_pattern):
    files = glob.glob(file_pattern) 
    print(f'Number of files to be deleted: {len(files)}')
    deleted_cn = 0
    for file in files:
        try:
            os.remove(file)
            deleted_cn+=1
        except Exception as e:
            raise Exception(f'Error deleting {file}: {str(e)}')
    print(f'Deleted no of files : {deleted_cn}')

if __name__ == "__main__":
    args = sys.argv[1:]
    file_pattern:str = args[0]

    print(f'{file_pattern=}')
    main(file_pattern)