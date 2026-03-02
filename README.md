# dartser

`dartser` 是一個命令列的本地檔案伺服器工具。  
啟動後可以在瀏覽器中瀏覽目錄、以語法高亮的編輯器檢視或修改文字檔案，以及上傳檔案。

---

## 安全使用環境

> ⚠️ **請只在本機（localhost）或受信任的區域網路（LAN）中使用，切勿暴露到公開網路。**

`dartser` 會伺服目前工作目錄下的所有檔案，並允許瀏覽、編輯與上傳，因此**不適合**在公開網路環境下運行。

---

## 我的平台要怎麼下載

### 下載程式碼（已編譯的執行檔）

選擇你的平台，用 `curl` 直接下載到目標位置：

#### Linux / macOS

```bash
# 以 Linux 為例，macOS 將 dartser-linux 換成 dartser-macos
sudo curl -L https://github.com/aakwewaanaqa/dart_lil_ser/releases/latest/download/dartser-linux -o /usr/bin/dartser
sudo chmod +x /usr/bin/dartser
```

#### Windows

**方案一：使用 Git Bash（安裝到 `/usr/bin`）**

```bash
curl -L https://github.com/aakwewaanaqa/dart_lil_ser/releases/latest/download/dartser-windows.exe -o /usr/bin/dartser.exe
```

**方案二：手動放到 `C:\Program Files`**

1. 將 `dartser-windows.exe` 重新命名為 `dartser.exe`
2. 將檔案移動到 `C:\Program Files\dartser\`
3. 將 `C:\Program Files\dartser` 加入系統環境變數 `Path`

---

## 使用方式

在想要伺服的目錄下執行：

```bash
dartser file
```

預設會在 `http://<你的區網 IP>:1347` 提供服務。

也可以自訂 IP 與 Port：

```bash
dartser file -i 127.0.0.1 -p 8080
```

---

### 安裝程式碼（從原始碼編譯）

需要先安裝 [Dart SDK](https://dart.dev/get-dart)（版本 `^3.9.2`）。

```bash
git clone https://github.com/aakwewaanaqa/dart_lil_ser.git
cd dart_lil_ser
dart pub get
dart run build_runner build --delete-conflicting-outputs
dart compile exe -o dartser bin/main.dart   # Windows 用 dartser.exe
```

接著依照你的偏好，選擇安裝到環境變數路徑：

#### `/usr/bin`（Linux / macOS，或 Windows 的 Git Bash）

```bash
chmod +x dartser          # Linux / macOS 才需要
sudo mv dartser /usr/bin/ # Windows Git Bash 不需要 sudo
```

#### `C:\Program Files`（Windows 原生）

1. 將 `dartser.exe` 移動到 `C:\Program Files\dartser\`
2. 將 `C:\Program Files\dartser` 加入系統環境變數 `Path`
