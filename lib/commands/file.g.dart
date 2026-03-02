// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// StrEmbeddingGenerator
// **************************************************************************

const _$editorHtml = r'''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>macOS-Style File Editor</title>
    <!-- CodeMirror CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/theme/neo.min.css">
    <style>
        :root {
            --bg: #f5f5f7;
            --panel: white;
            --border: #d2d2d7;
            --text: #1d1d1f;
            --button-bg: #e9e9ed;
            --button-hover: #dcdcde;
            --radius: 12px;
        }

        body {
            margin: 0;
            background: var(--bg);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: var(--text);
            padding: 40px;
        }

        h2 {
            font-weight: 600;
            text-align: center;
            margin-bottom: 30px;
        }

        .window {
            max-width: 900px;
            margin: 0 auto;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 80vh;
        }

        .titlebar {
            background: #ececec;
            padding: 10px 14px;
            display: flex;
            gap: 8px;
            border-bottom: 1px solid var(--border);
            flex-shrink: 0;
        }

        .traffic-lights {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .close {
            background: #ff5f57;
        }

        .minimize {
            background: #febc2e;
        }

        .maximize {
            background: #28c840;
        }

        .content {
            padding: 0;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        /* CodeMirror Customization */
        .CodeMirror {
            height: 100%;
            font-family: Menlo, monospace;
            font-size: 14px;
            background: #fafafa;
        }

        .footer {
            padding: 15px 20px;
            border-top: 1px solid var(--border);
            background: #f9f9f9;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            flex-shrink: 0;
        }

        button {
            background: var(--button-bg);
            border: 1px solid var(--border);
            padding: 8px 16px;
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 13px;
            transition: background 0.2s;
        }

        button:hover {
            background: var(--button-hover);
        }
    </style>
</head>

<body>
    <div class="window">
        <div class="titlebar">
            <div class="traffic-lights close"></div>
            <div class="traffic-lights minimize"></div>
            <div class="traffic-lights maximize"></div>
            <span style="margin-left: 10px; font-weight: 500; font-size: 13px;">{{FILENAME}}</span>
        </div>
        <div class="content">
            <textarea id="editor">{{CONTENT}}</textarea>
        </div>
        <div class="footer">
            {{SAVE_BUTTON}}
        </div>
    </div>

    <!-- CodeMirror JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/javascript/javascript.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/xml/xml.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/css/css.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/clike/clike.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/shell/shell.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/yaml/yaml.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/dart/dart.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/go/go.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/htmlmixed/htmlmixed.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/python/python.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/rust/rust.min.js"></script>

    <script>
        const saveBtn = document.getElementById("saveBtn");
        const filename = "{{FILENAME}}";
        const mode = {{MODE}};

        // Initialize CodeMirror
        const cm = CodeMirror.fromTextArea(document.getElementById("editor"), {
            lineNumbers: true,
            mode: mode,
            theme: "neo",
            lineWrapping: true,
            readOnly: {{READONLY}},
            indentUnit: 4,
            extraKeys: {
                "Tab": function (cm) {
                    if (cm.somethingSelected()) {
                        cm.indentSelection("add");
                    } else {
                        cm.replaceSelection("    ", "end");
                    }
                },
                "Cmd-S": function (cm) {
                    if (saveBtn) saveBtn.click();
                },
                "Ctrl-S": function (cm) {
                    if (saveBtn) saveBtn.click();
                }
            }
        });

        // Focus editor
        cm.focus();

        if (saveBtn) {
        saveBtn.addEventListener("click", async () => {
            saveBtn.disabled = true;
            saveBtn.innerText = "Saving...";

            try {
                // Get content from CodeMirror
                const content = cm.getValue();
                const blob = new Blob([content], { type: "text/plain" });
                const formData = new FormData();
                formData.append("file", blob, filename);

                const response = await fetch(window.location.href, {
                    method: 'POST',
                    body: formData
                });

                if (response.ok) {
                    saveBtn.innerText = "Saved!";
                    setTimeout(() => {
                        saveBtn.innerText = "Save";
                        saveBtn.disabled = false;
                    }, 2000);
                } else {
                    alert("Failed to save file.");
                    saveBtn.innerText = "Save";
                    saveBtn.disabled = false;
                }
            } catch (e) {
                console.error(e);
                alert("Error saving file: " + e.message);
                saveBtn.innerText = "Save";
                saveBtn.disabled = false;
            }
        });
        }
    </script>
</body>

</html>
''';

const _$directoryHtml = r'''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Index of {{CURRENT_PATH}}</title>
    <style>
        :root {
            --bg: #f5f5f7;
            --panel: white;
            --border: #d2d2d7;
            --text: #1d1d1f;
            --button-bg: #e9e9ed;
            --button-hover: #dcdcde;
            --radius: 12px;
            --selection: #007aff;
            --selection-text: white;
        }

        body {
            margin: 0;
            background: var(--bg);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: var(--text);
            padding: 40px;
        }

        .window {
            max-width: 900px;
            margin: 0 auto;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 80vh;
        }

        .titlebar {
            background: #ececec;
            padding: 10px 14px;
            display: flex;
            gap: 8px;
            border-bottom: 1px solid var(--border);
            flex-shrink: 0;
            align-items: center;
        }

        .traffic-lights {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .close {
            background: #ff5f57;
        }

        .minimize {
            background: #febc2e;
        }

        .maximize {
            background: #28c840;
        }

        .title {
            margin-left: 10px;
            font-weight: 500;
            font-size: 13px;
            flex-grow: 1;
            text-align: center;
            margin-right: 50px;
            /* Balance the traffic lights */
        }

        .content {
            padding: 0;
            flex-grow: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .file-list {
            list-style: none;
            padding: 0;
            margin: 0;
            flex-grow: 1;
        }

        .file-item {
            display: flex;
            align-items: center;
            padding: 8px 16px;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            text-decoration: none;
            color: var(--text);
            font-size: 14px;
        }

        .file-item:hover {
            background-color: #f5f5f5;
        }

        .file-item:last-child {
            border-bottom: none;
        }

        .icon {
            margin-right: 10px;
            font-size: 16px;
            width: 20px;
            text-align: center;
        }

        .footer {
            padding: 15px 20px;
            border-top: 1px solid var(--border);
            background: #f9f9f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0;
        }

        .upload-form {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        button {
            background: var(--button-bg);
            border: 1px solid var(--border);
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            transition: background 0.2s;
        }

        button:hover {
            background: var(--button-hover);
        }

        input[type="file"] {
            font-size: 13px;
        }
    </style>
</head>

<body>
    <div class="window">
        <div class="titlebar">
            <div class="traffic-lights close"></div>
            <div class="traffic-lights minimize"></div>
            <div class="traffic-lights maximize"></div>
            <div class="title">{{CURRENT_PATH}}</div>
        </div>
        <div class="content">
            <div class="file-list">
                {{FILE_LIST}}
            </div>
        </div>
        <div class="footer">
            <span style="font-size: 12px; color: #888;">{{ITEM_COUNT}} items</span>
            {{UPLOAD_FORM}}
        </div>
    </div>
</body>

</html>
''';
