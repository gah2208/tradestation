__version__ = "1.0.3"
# Copyright 2026 Gregory Howard  all rights reserved.

import hashlib
import os
from build_manifest import FILES


FILES_TO_CHECK = [
    f"{k}.py"
    for k in FILES.keys()
    if k not in ("config", "checksum")
]


CHECKSUM = "3fa9c5c03a072787dc37d7d091a5abd32a86424a2643ceabed759b68af0aeaeb"


def compute_checksum():

    sha = hashlib.sha256()

    for fname in sorted(FILES_TO_CHECK):

        if not os.path.exists(fname):
            raise Exception(f"Missing file: {fname}")

        with open(fname, "rb") as f:
            sha.update(f.read())

    return sha.hexdigest()


def verify_checksum():

    print("\n=== VTBC CHECKSUM VALIDATION START ===")

    current = compute_checksum()

    print(f"Expected: {CHECKSUM}")
    print(f"Actual  : {current}")

    if current != CHECKSUM:
        print("\n❌ CHECKSUM FAILED — FILES MODIFIED OR CORRUPTED\n")
        raise Exception("CHECKSUM MISMATCH")

    print("\n✅ CHECKSUM VERIFIED\n")
    print("======================================\n")