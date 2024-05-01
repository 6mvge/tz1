#!/bin/bash

# Проверяем наличие двух параметров
if [ $# -ne 2 ]; then
    echo "Использование: $0 <input_directory> <output_directory>"
    exit 1
fi

input_dir="$1"
output_dir="$2"

# Создаем выходную директорию, если она не существует
mkdir -p "$output_dir"

# Функция для копирования файлов с учетом возможных одинаковых имен
copy_files_with_unique_names() {
    local source_file="$1"
    local dest_dir="$2"
    local file_name="$(basename "$source_file")"
    local counter=0
    local dest_path="$dest_dir/$file_name"

    # Если файл с таким именем уже существует в выходной директории
    while [ -e "$dest_path" ]; do
        # Проверяем, являются ли содержимое файлов идентичным
        if cmp -s "$source_file" "$dest_path"; then
            # Если файлы идентичны, пропускаем копирование
            return
        else
            # Иначе, добавляем суффикс к имени файла
            ((counter++))
            dest_path="${dest_dir}/${file_name}_${counter}"
        fi
    done

    # Копируем файл в выходную директорию
    cp "$source_file" "$dest_path"
}

# Функция для рекурсивного обхода входной директории и копирования файлов
copy_all_files() {
    local current_dir="$1"
    local dest_dir="$2"
    
    # Получаем список файлов и копируем их
    find "$current_dir" -type f -print0 | while IFS= read -r -d $'\0' file; do
        copy_files_with_unique_names "$file" "$dest_dir"
    done
}

# Запускаем функцию копирования файлов
copy_all_files "$input_dir" "$output_dir"

echo "Копирование завершено."
