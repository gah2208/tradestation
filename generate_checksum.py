__version__ = "1.0.1"
# Copyright 2026 Gregory Howard  all rights reserved.

from checksum import compute_checksum


def generate():

    value = compute_checksum()

    print(value)


if __name__ == "__main__":
    generate()