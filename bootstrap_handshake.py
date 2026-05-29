__version__ = "1.0.0"
# Copyright 2026 Gregory Howard  all rights reserved.

import hashlib
import socket
import uuid
import requests
import ctypes
import sys
from datetime import datetime


# ===== CONFIG =====

AUTH_URL = "https://raw.githubusercontent.com/gah2208/ctv/main/auth.json"

ADMIN_PUSHOVER_USER_KEY = "uck9cc5jyue5oir91izu2ordr6s4uc"
ADMIN_PUSHOVER_API_TOKEN = "YOUR_ADMIN_API_TOKEN"

WINDOWS_ALERT_ENABLED = True


# ===== UTIL =====

def get_user_id():
    raw = f"{socket.gethostname()}-{uuid.getnode()}"
    return hashlib.sha256(raw.encode()).hexdigest()[:8]


def show_popup(message):
    if WINDOWS_ALERT_ENABLED:
        try:
            ctypes.windll.user32.MessageBoxW(0, message, "VTBC AUTHORIZATION", 0x10)
        except:
            pass


def send_admin_alert(message):

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    hostname = socket.gethostname()

    full_msg = f"""
VTBC AUTH REQUEST

Time: {timestamp}
Host: {hostname}

{message}
"""

    try:
        requests.post(
            "https://api.pushover.net/1/messages.json",
            data={
                "token": ADMIN_PUSHOVER_API_TOKEN,
                "user": ADMIN_PUSHOVER_USER_KEY,
                "message": full_msg
            }
        )
    except:
        pass


def fetch_auth():
    r = requests.get(AUTH_URL, timeout=5)
    r.raise_for_status()
    return r.json()


# ===== MAIN HANDSHAKE =====

def main():

    user_id = get_user_id()

    # ✅ Always show user ID
    msg = f"""
VTBC AUTHORIZATION REQUIRED

Your User ID:
{user_id}

Send this ID for access approval.
"""

    print(msg)
    show_popup(msg)

    try:
        auth = fetch_auth()

        users = auth.get("users", {})

        if user_id in users and users[user_id].get("enabled", False):
            print("AUTHORIZED")
            return

    except:
        pass

    # ✅ NOT AUTHORIZED → SEND ADMIN ALERT
    alert_msg = f"NEW USER REQUEST\nUser ID: {user_id}"
    send_admin_alert(alert_msg)

    print("NOT AUTHORIZED — REQUEST SENT")
    sys.exit(1)


if __name__ == "__main__":
    main()