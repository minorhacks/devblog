use std::env;
use std::fs;
use std::path;

use std::io::Write;

fn main() {
    let out = path::PathBuf::from(env::var_os("OUT_DIR").unwrap());
    println!("cargo:rustc-link-search={}", out.display());

    let memory_x = include_bytes!("memory.x");
    let mut f = fs::File::create(out.join("memory.x")).unwrap();
    f.write_all(memory_x).unwrap();
    println!("cargo:rerun-if-changed=memory.x");

    println!("cargo:rerun-if-changed=build.rs");
}
