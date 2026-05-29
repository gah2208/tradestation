def load_config():

    # ===== load defaults =====
    if not os.path.exists(DEFAULT_CONFIG_FILE):
        messagebox.showerror("Error", "config_default.py not found")
        sys.exit(1)

    defaults = {}
    with open(DEFAULT_CONFIG_FILE) as f:
        for line in f:
            m = re.match(r"(\w+)\s*=\s*(.+)", line)
            if m:
                defaults[m.group(1)] = m.group(2).strip()

    # ===== if config missing, create =====
    if not os.path.exists(CONFIG_FILE):
        shutil.copyfile(DEFAULT_CONFIG_FILE, CONFIG_FILE)
        messagebox.showinfo("Created", "config.py created from defaults.")

    current = {}

    with open(CONFIG_FILE) as f:
        for line in f:
            m = re.match(r"(\w+)\s*=\s*(.+)", line)
            if m:
                current[m.group(1)] = m.group(2).strip()

    # ===== VALIDATION / AUTO-REPAIR =====
    updated = False

    for key, default_val in defaults.items():
        if key not in current:
            current[key] = default_val
            updated = True

    # ===== write back only if needed =====
    if updated:
        with open(CONFIG_FILE, "w") as f:
            for k, v in current.items():
                f.write(f"{k} = {v}\n")

        messagebox.showwarning(
            "Config Repaired",
            "Missing config values were added automatically."
        )

    # ===== final values (for UI, strip quotes) =====
    values = {}

    for k, v in current.items():

        val = v.strip()

        if (val.startswith('"') and val.endswith('"')) or \
           (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]

        values[k] = val

    return values