from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import requests

PNG_BASE_URL =  'https://inversionrecruitment.blob.core.windows.net/find-the-code/({}).png'

OUTPUT_DIR = Path("images")
OUTPUT_DIR.mkdir(exist_ok=True)

session = requests.Session()

def download(i: int):
    path = OUTPUT_DIR / f"({i}).png"
    if path.exists():
        return
    request = session.get(PNG_BASE_URL.format(i), timeout=30)
    request.raise_for_status()
    path.write_bytes(request.content)
    
MAX_WORKERS = 32

with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    futures = [executor.submit(download, i) for i in range(1, 1201)]
    for i, future in enumerate(as_completed(futures), 1):
        future.result()
        print(f"{i}/1200 downloaded", end="\r")
        
print("\n Done.")