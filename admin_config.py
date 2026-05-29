__version__ = "1.1.0"
# Copyright 2026 Gregory Howard  all rights reserved.

## ===== ADMIN ALERTING =====
ADMIN_PUSHOVER_ENABLED = True
ADMIN_PUSHOVER_USER_KEY = "uck9cc5jyue5oir91izu2ordr6s4uc"
ADMIN_PUSHOVER_API_TOKEN = "YOUR_ADMIN_API_TOKEN"

## ===== AUTH SERVER =====
AUTH_URL = "https://raw.githubusercontent.com/gah2208/ctv/main/auth.json"

## ===== LICENSE CONTROL =====
LICENSE_ENFORCEMENT_ENABLED = True

## ===== CACHE SETTINGS =====
AUTH_CACHE_FILE = "auth_cache.json"
AUTH_CACHE_TTL_SECONDS = 3600

## ===== ENFORCEMENT MODE =====
ADMIN_ENFORCEMENT_MODE = True   # ✅ HARD REQUIREMENT FOR ADMIN ENV

## ===== SECURITY =====
FAIL_CLOSED_ON_AUTH_ERROR = True