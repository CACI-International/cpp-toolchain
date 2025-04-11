import sys
import hashlib
import codecs
import requests
import json
from pathlib import Path

def get_assets(tag):
    response = requests.get("https://api.github.com/repos/CACI-International/cpp-toolchain/releases/tags/" + tag)
    return response.json()["assets"]

def integrity(url):
    response = requests.get(url, stream=True)
    digest = hashlib.file_digest(response.raw, "sha256").hexdigest()
    return "sha256-" + codecs.encode(codecs.decode(digest, "hex"), "base64").decode(
        "utf-8"
    ).replace("\n", "")

def bazel(assets):
    output = []
    for asset in assets:
        output.append({
            "name": asset["name"].removesuffix(".tar.xz"),
            "url": asset["browser_download_url"],
            "integrity": integrity(asset["browser_download_url"]),
        })
    
    with open(Path(__file__).resolve().parent.parent / "bazel/detail/assets/assets.json", "w") as f:
        json.dump(output, f, indent="  ")

def sha256(url):
    response = requests.get(url, stream=True)
    return hashlib.file_digest(response.raw, "sha256").hexdigest()

def cmake(assets):
    with open(Path(__file__).resolve().parent.parent / "cmake/assets.cmake", "w") as f:
        for asset in assets:
            name = asset["name"].removesuffix(".tar.xz")
            url = asset["browser_download_url"]
            checksum = sha256(url)
            print(f'set(_ASSET_URL_{name} {url})', file=f)
            print(f'set(_ASSET_SHA256_{name} {checksum})\n', file=f)

tag = sys.argv[1]
assets = get_assets(tag)
bazel(assets)
cmake(assets)
