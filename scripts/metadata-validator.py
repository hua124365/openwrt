#!/usr/bin/env python3

import json
import yaml
from jsonschema import validate, RefResolver, ValidationError
from pathlib import Path
from sys import argv

if len(argv) != 2:
    print(f"{argv[0]} <metadata file>")
    quit(1)

instance_file = Path(argv[1])
assert instance_file.is_file(), f"Metadata file does not exists at '{instance_file}'"
instance_content = yaml.safe_load(instance_file.read_text())

schema_path = Path("scripts/schemas")
assert schema_path.is_dir(), f"Schema folder does not exists at '{schema_path}'"

# load YAML schemas
store = {}
for schema in schema_path.glob("*.yaml"):
    store[f"file:{schema.name}"] = yaml.safe_load(schema.read_text())

try:
    validate(
        instance=instance_content,
        schema={"$ref": "file:device.yaml"},
        resolver=RefResolver("", {}, store=store),
    )
    print(f"Valid metadata: {instance_file}")

except ValidationError as e:
    print(e)
    quit(1)
