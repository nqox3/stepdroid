# This Script is rejected for use due someone be a vibecoder lol.


#!/bin/bash

echo ""
echo "Quick-Builder"
echo "
echo

menu() {
    echo "Выберите действие:"
    echo "1. Компилировать C# проект"
    echo "2. Запустить Python скрипт"
    echo "3. Скомпилировать Python PyInstaller"
    echo "4. Выход"
    echo
    read -p "Введите номер 1-4: " choice
    
    case $choice in
        1) compile_csharp ;;
        2) run_python ;;
        3) compile_python ;;
        4) exit 0 ;;
        *) echo "Неверный выбор!"; menu ;;
    esac
}

compile_csharp() {
    echo
    echo "--- Компиляция C# ---"
    read -p "Введите имя .cs файла или .csproj (или нажмите Enter для поиска): " cs_file
    
    if [ -z "$cs_file" ]; then
        echo "Поиск .csproj файлов..."
        cs_file=$(find . -maxdepth 1 -name "*.csproj" -print -quit)
        
        if [ -z "$cs_file" ]; then
            echo "Поиск .cs файлов..."
            cs_file=$(find . -maxdepth 1 -name "*.cs" -print -quit)
        fi
        
        if [ -z "$cs_file" ]; then
            echo "Файлы не найдены!"
            read -p "Нажмите Enter для продолжения..."
            menu
            return
        fi
    fi
    
    if [ ! -f "$cs_file" ]; then
        echo "Файл не найден: $cs_file"
        read -p "Нажмите Enter для продолжения..."
        menu
        return
    fi
    
    echo "Компиляция: $cs_file"
    echo
    
    if [[ "$cs_file" == *.csproj ]]; then
        if command -v dotnet &> /dev/null; then
            dotnet build "$cs_file" -c Release
            if [ $? -eq 0 ]; then
                echo
                echo "✓ Компиляция успешна!"
                dotnet run --project "$cs_file" -c Release
            else
                echo
                echo "✗ Ошибка компиляции!"
            fi
        else
            echo "dotnet не установлен!"
        fi
    else
        if command -v mcs &> /dev/null; then
            mcs "$cs_file" -out:program.exe
            if [ $? -eq 0 ]; then
                echo
                echo "✓ Компиляция успешна! Создан: program.exe"
                read -p "Запустить программу? y/n: " run_choice
                if [[ "$run_choice" =~ ^[Yy]$ ]]; then
                    mono program.exe
                fi
            else
                echo
                echo "✗ Ошибка компиляции!"
            fi
        else
            echo "mcs (Mono) не установлен!"
        fi
    fi
    
    echo
    read -p "Нажмите Enter для продолжения..."
    menu
}

run_python() {
    echo
    echo "--- Запуск Python ---"
    read -p "Введите имя .py файла (или нажмите Enter для поиска): " py_file
    
    if [ -z "$py_file" ]; then
        echo "Поиск .py файлов..."
        py_file=$(find . -maxdepth 1 -name "*.py" -print -quit)
        
        if [ -z "$py_file" ]; then
            echo "Файлы не найдены!"
            read -p "Нажмите Enter для продолжения..."
            menu
            return
        fi
    fi
    
    if [ ! -f "$py_file" ]; then
        echo "Файл не найден: $py_file"
        read -p "Нажмите Enter для продолжения..."
        menu
        return
    fi
    
    echo "Запуск: $py_file"
    echo
    
    if command -v python3 &> /dev/null; then
        python3 "$py_file"
    elif command -v python &> /dev/null; then
        python "$py_file"
    else
        echo "Python не установлен!"
    fi
    
    echo
    read -p "Нажмите Enter для продолжения..."
    menu
}

compile_python() {
    echo
    echo "--- Компиляция Python ---"
    read -p "Введите имя .py файла: " py_file
    
    if [ ! -f "$py_file" ]; then
        echo "Файл не найден: $py_file"
        read -p "Нажмите Enter для продолжения..."
        menu
        return
    fi
    
    echo "Проверка PyInstaller..."
    
    if ! pip3 show pyinstaller &> /dev/null && ! pip show pyinstaller &> /dev/null; then
        read -p "PyInstaller не установлен. Установить? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            if command -v pip3 &> /dev/null; then
                pip3 install pyinstaller
            else
                pip install pyinstaller
            fi
        else
            menu
            return
        fi
    fi
    
    echo "Компиляция: $py_file"
    echo
    pyinstaller --onefile --clean "$py_file"
    
    if [ $? -eq 0 ]; then
        echo
        echo "✓ Компиляция успешна! Исполняемый файл находится в папке dist/"
    else
        echo
        echo "✗ Ошибка компиляции!"
    fi
    
    echo
    read -p "Нажмите Enter для продолжения..."
    menu
}

# Запуск меню
menu