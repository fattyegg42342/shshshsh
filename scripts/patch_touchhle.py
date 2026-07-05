from pathlib import Path
p=Path(__file__).resolve().parents[1]/"touchhle"
c=p/"Cargo.toml"
s=c.read_text()
s=s.replace('crate-type = ["cdylib", "rlib"]','crate-type = ["staticlib", "rlib"]')
c.write_text(s)
lib=p/"src/lib.rs"
s=lib.read_text()
if "mod ios_bridge;" not in s:
    s=s.replace("mod image;","mod image;\n#[cfg(target_os = \"ios\")]\nmod ios_bridge;")
lib.write_text(s)
(lib.parent/"ios_bridge.rs").write_text((p.parent/"touchhle_overlay/src/ios_bridge.rs").read_text())
