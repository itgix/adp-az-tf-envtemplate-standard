import os
import json
import shutil

map_string = '{{ cookiecutter.env_to_region_map }}'
env_config = json.loads(map_string)

# Top-level cookiecutter vars available for token replacement
global_vars = {
    "tenant_id":       '{{ cookiecutter.tenant_id }}',
    "subscription_id": '{{ cookiecutter.subscription_id }}',
    "client_name":     '{{ cookiecutter.client_name }}',
}

blueprint_dir = os.path.join("adp", "_blueprint")

for env, locations in env_config.items():
    for location, cfg in locations.items():
        target_dir = os.path.join("adp", env, location)

        shutil.copytree(blueprint_dir, target_dir, dirs_exist_ok=True)

        # Flatten nested sections into a single dict for token replacement.
        # All nested dict values are merged into the flat dict without prefixing,
        # so config keys must match the template tokens directly.
        flat = {}
        for key, value in cfg.items():
            if isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    flat[sub_key] = sub_value
            else:
                flat[key] = value

        context = {"ENV": env, "LOCATION": location, **global_vars, **flat}

        for root, _, files in os.walk(target_dir):
            for fname in files:
                fpath = os.path.join(root, fname)
                with open(fpath) as f:
                    content = f.read()
                for key, value in context.items():
                    str_value = str(value).lower() if isinstance(value, bool) else str(value)
                    content = content.replace(f"__{key.upper()}__", str_value)
                with open(fpath, "w") as f:
                    f.write(content)

if os.path.exists(blueprint_dir):
    shutil.rmtree(blueprint_dir)

# Initialize git repo so that get_repo_root() works in terragrunt
os.system("git init")
os.system("git add -A")
os.system('git commit -m "Initial scaffold" --allow-empty')
