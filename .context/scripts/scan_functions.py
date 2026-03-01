
import os
import re

def parse_sql_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fonksiyon imzasini bul
    # CREATE [OR REPLACE] FUNCTION schema.name(params)
    func_pattern = re.compile(r'CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+)\s*\((.*?)\)', re.DOTALL | re.IGNORECASE)
    match = func_pattern.search(content)

    if not match:
        return None

    full_name = match.group(1)
    params = match.group(2).strip()

    # Parametreleri temizle (sadece isimleri degil, tipleri de dahil uzun olabilir, yeni satirlari tek satira indir)
    params = ' '.join(params.split())

    schema, name = full_name.split('.') if '.' in full_name else ('public', full_name)

    # Aciklamayi bul
    # Genellikle dosyanin basindaki yorumlar veya COMMENT ON FUNCTION
    comment = ""

    # 1. Yontem: COMMENT ON FUNCTION
    comment_pattern = re.compile(r"COMMENT\s+ON\s+FUNCTION\s+.*?\s+IS\s+'(.*?)';", re.DOTALL | re.IGNORECASE)
    comment_match = comment_pattern.search(content)
    if comment_match:
        comment = comment_match.group(1).replace("''", "'")
    else:
        # 2. Yontem: Dosya basindaki -- yorumlari
        lines = content.split('\n')
        comments = []
        for line in lines:
            if line.strip().startswith('--'):
                clean_line = line.strip().lstrip('-').strip()
                if not clean_line.startswith('='): # Susleme satirlarini atla
                    comments.append(clean_line)
            elif not line.strip():
                continue
            else:
                break # Kod basladi

        if comments:
            comment = " ".join(comments)

    return {
        'schema': schema,
        'name': name,
        'params': params,
        'description': comment
    }

def scan_directory(root_dir):
    db_functions = {}

    for dirpath, dirnames, filenames in os.walk(root_dir):
        if 'functions' in dirpath.split(os.sep) or 'triggers' in dirpath.split(os.sep):
             # .git vb. atla
            if '.git' in dirpath:
                continue

            # Hangi veritabanina ait oldugunu bul (root altindaki ilk klasor)
            rel_path = os.path.relpath(dirpath, root_dir)
            parts = rel_path.split(os.sep)
            db_name = parts[0]

            # functions veya triggers altinda degilse atla (ornegin node_modules varsa)
            if 'functions' not in parts and 'triggers' not in parts:
                continue

            if db_name not in db_functions:
                db_functions[db_name] = {}

            for filename in filenames:
                if filename.endswith('.sql'):
                    full_path = os.path.join(dirpath, filename)
                    func_info = parse_sql_file(full_path)

                    if func_info:
                        schema = func_info['schema']
                        if schema not in db_functions[db_name]:
                            db_functions[db_name][schema] = []

                        db_functions[db_name][schema].append(func_info)

    return db_functions

def generate_markdown(db_functions):
    lines = []
    lines.append("# Veritabanı Fonksiyon ve Trigger Dokümantasyonu")
    lines.append("")
    lines.append("Bu doküman, projede yer alan stored procedure ve trigger tanımlarını içerir.")
    lines.append("")

    # Veritabanlarini sirala (Core once)
    sorted_dbs = sorted(db_functions.keys())
    # Core en basa
    if 'core' in sorted_dbs:
        sorted_dbs.remove('core')
        sorted_dbs.insert(0, 'core')

    for db_name in sorted_dbs:
        db_title = db_name.replace('_', ' ').title()
        lines.append(f"## {db_title} Veritabanı")
        lines.append("")

        schemas = db_functions[db_name]
        if not schemas:
             lines.append("Henüz özel fonksiyon tanımlanmamıştır.")
             lines.append("")
             continue

        for schema_name in sorted(schemas.keys()):
            schema_title = schema_name.title()
            lines.append(f"### {schema_title} Şeması")
            lines.append("")

            functions = sorted(schemas[schema_name], key=lambda x: x['name'])
            for func in functions:
                desc = func['description'] if func['description'] else "Açıklama bulunamadı."
                # Parametreleri guzellestir
                params = func['params'].replace('\n', ' ')
                lines.append(f"- **`{func['name']}`**: {desc}")

            lines.append("")

    return "\n".join(lines)

if __name__ == "__main__":
    root_dir = r"c:\Projects\Git\Sortis One\OneDB"
    data = scan_directory(root_dir)
    markdown = generate_markdown(data)

    output_path = os.path.join(root_dir, ".docs", "DATABASE_FUNCTIONS.md")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(markdown)

    print(f"Documentation generated at {output_path}")
