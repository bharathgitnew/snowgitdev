---
name: dbt-descriptions
description: "Create or standardize _models.yml files with model and column descriptions following BRONZE/SILVER/GOLD format conventions. Use when: populating dbt model metadata, standardizing yaml descriptions, creating _models.yml files. Triggers: standardize this yaml, dbt descriptions, populate models yml, create _models.yml, add descriptions."
tools: ["read", "write", "edit", "glob", "grep", "bash"]
---

# dbt-descriptions

Populate or standardize `_models.yml` files with model and column descriptions following layer-specific formats.

## Workflow

### Step 1: Identify Target File and Layer

1. Get the `_models.yml` file path from the user (or the currently open file).
2. Determine the layer from the file path or model name prefix:
   - **BRONZE** = path contains `bronze/` or model names start with `BRONZE__`
   - **SILVER** = path contains `silver/` or model names start with `SILVER__`
   - **GOLD** = path contains `gold/` or model names start with `GOLD__`
3. If creating from scratch, locate the SQL model files in the same directory.

**STOP**: Confirm the target file and detected layer with the user.

### Step 2: Read Context

1. Read the target `_models.yml` file.
2. For each model listed, find and read its corresponding SQL file (same directory or sibling files matching the model name).
3. If SILVER or GOLD, also read the upstream `_models.yml` (e.g., GOLD pulls context from SILVER, SILVER from BRONZE) to avoid repeating generic descriptions.

### Step 3: Generate Model Descriptions

Apply the format based on layer:

**SILVER and GOLD models:**
```
PURPOSE: <1-2 lines — purpose or business question this model answers>
GRAIN: <one line — one row = what>
KEY LOGIC: <1-2 lines — explain critical joins/filters/exclusions>
CAVEAT: <1 line — known limitation, edge case>
```

**BRONZE models:**
```
PURPOSE: <one line — purpose or what raw source this is>
GRAIN: <one line — one row = what>
```

### Step 4: Generate Column Descriptions

For ALL layers (BRONZE, SILVER, GOLD), use this format for every column:

```
<what it is>. <unit/format if non-obvious>. <gotcha if any>.
```

### Step 5: Write the File

Write or update the `_models.yml` preserving:
- All existing tests (do not remove or reorder)
- All existing metadata besides descriptions
- Original column ordering (do not move columns around)
- Internal columns (starting with `_`) — do not modify these

**STOP**: Present the updated file for user review.

## Rules

- Do NOT modify internal columns (names starting with `_`).
- Only descriptions should be changed — no changes to tests or other metadata.
- Do NOT move around column names from their original position.
- Descriptions must NOT be generalized or repetitive across models.
- Use the underlying SQL and upstream `_models.yml` as a context layer.
- Confirm that all columns present in the SQL are accounted for in the yml.
- Avoid descriptions that sound like templates or placeholders.
- Avoid the pattern "Model <<table_name>> file." in descriptions.
- Users of different departments should be able to understand column values from descriptions alone.

## Creating From Scratch

When no `_models.yml` exists yet:

1. Glob for all `.sql` files in the target directory.
2. Parse each SQL file to extract the model name and column list.
3. Generate the full `_models.yml` with:
   - `models:` top-level key
   - Each model with `name`, `description`, `tests: [has_data, recently_run]`, and `columns` list.
4. Follow the same description format rules above.

## Stopping Points

- After Step 1: Confirm file and layer
- After Step 5: Review generated descriptions

## Output

A complete `_models.yml` file with standardized descriptions for all models and columns.
