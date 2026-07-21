import os
import json
import shutil

map_string = '{{ cookiecutter.env_to_region_map }}'
env_config = json.loads(map_string)

blueprint_dir = os.path.join("adp", "_blueprint")

for env, locations in env_config.items():
    for location, cfg in locations.items():
        target_dir = os.path.join("adp", env, location)

        shutil.copytree(blueprint_dir, target_dir, dirs_exist_ok=True)

        defaults = {
            "create_networking":   True,
            "create_aks":          True,
            "create_identities":   True,
            "create_postgres":     False,
            "create_azure_policy": True,
            "vpa_enabled":         True,
        }
        context = {"ENV": env, "LOCATION": location, **defaults, **cfg}

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
