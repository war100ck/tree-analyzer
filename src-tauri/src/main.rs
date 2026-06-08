#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::fs::{self, File};
use std::io::Write;
use std::path::Path;

fn build_tree(
    dir: &Path,
    output: &mut String,
    prefix: &str,
    exclusions: &[String],
    depth: usize,
) -> Result<(), String> {
    if depth > 10 {
        return Ok(()); // Стоп-лосс: защита от бесконечной рекурсии
    }

    let mut entries: Vec<_> = fs::read_dir(dir)
        .map_err(|e| e.to_string())?
        .filter_map(|e| e.ok())
        .collect();

    entries.sort_by_key(|e| e.file_name());

    for (i, entry) in entries.iter().enumerate() {
        let file_name = entry.file_name().to_string_lossy().to_string();

        // Фильтрация неликвидных активов (исключенных файлов/папок)
        if exclusions.iter().any(|exc| file_name.contains(exc)) {
            continue;
        }

        let is_last = i == entries.len() - 1;
        let connector = if is_last { "└── " } else { "├── " };

        output.push_str(&format!("{}{}{}\n", prefix, connector, file_name));

        let path = entry.path();
        if path.is_dir() {
            let new_prefix = format!("{}{}", prefix, if is_last { "    " } else { "│   " });
            build_tree(&path, output, &new_prefix, exclusions, depth + 1)?;
        }
    }
    Ok(())
}

#[tauri::command]
fn generate_tree(path: String, exclusions: Vec<String>) -> Result<String, String> {
    let dir_path = Path::new(&path);
    if !dir_path.is_dir() {
        return Err("Выбранный путь не является директорией".to_string());
    }

    let mut tree_output = String::new();
    tree_output.push_str(&format!("Аудит структуры проекта: {}\n", dir_path.display()));
    tree_output.push_str(&"=".repeat(60));
    tree_output.push('\n');

    build_tree(dir_path, &mut tree_output, "", &exclusions, 0)?;

    let output_file = dir_path.join("project_tree.txt");
    let mut file = File::create(&output_file).map_err(|e| e.to_string())?;
    file.write_all(tree_output.as_bytes()).map_err(|e| e.to_string())?;

    Ok(format!("Успешно: файл сохранен по пути {}", output_file.display()))
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![generate_tree])
        .run(tauri::generate_context!())
        .expect("Ошибка при запуске приложения Tauri");
}