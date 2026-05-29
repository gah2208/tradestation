# Copyright 2026 Gregory Howard  all rights reserved.

from build_manifest import BUILD_VERSION, FILES

def run_build_check():

    print("=== BUILD CHECK ===")
    print(f"Expected Build: {BUILD_VERSION}\n")

    all_ok = True

    for module, expected in FILES.items():
        try:
            m = __import__(module)
            actual = getattr(m, "__version__", None)

            if actual != expected:
                print(f"❌ {module}: expected {expected}, got {actual}")
                all_ok = False
            else:
                print(f"✅ {module}: {actual}")

        except Exception as e:
            print(f"❌ {module}: FAILED ({e})")
            all_ok = False

    print("\n===================")

    if not all_ok:
        raise Exception("BUILD VERSION MISMATCH")

    print("✅ BUILD VERIFIED\n")
