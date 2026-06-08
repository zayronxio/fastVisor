# fastVisor – Minimal QML Image Viewer for Dolphin

**fastVisor** is a lightweight, frameless image viewer designed for **KDE Dolphin’s custom actions**. It shows an image full-window with no titlebar, no toolbars, and **zero margins** – the viewport exactly matches the image’s aspect ratio. Rounded corners and subtle shadows give it a modern, floating look.

Perfect for quickly previewing images without leaving Dolphin or opening a heavy application.

![Screenshot placeholder](https://raw.githubusercontent.com/zayronxio/fastVisor/refs/heads/main/preview/screnshot.webp)

---

## ✨ Features

- 🖼️ **Instant fit** – window resizes to image aspect ratio (no wasted space)
- 🎨 **Frameless & rounded** – no KDE decoration, just the image with soft corners
- 🖱️ **Mouse & keyboard controls** – click-drag to move window, scroll / arrow keys to browse
- 📌 **Pin mode** – keep the viewer open even when losing focus (click the 📍/📌 button)
- 🔄 **Next/Previous** – automatically loads all images from the same folder
- 🚀 **Preloading** – next image loads silently in the background
- ✨ **Smooth transitions** – fade-in from low-res thumbnail to full image
- 🧹 **Minimal UI** – navigation arrows and pin/close buttons appear only on hover

---

## 📦 Requirements

- **KDE Plasma 6.x** 
- **Dolphin** file manager


---

## 🛠️ Installation as a Dolphin Service Menu

1. **Save the QML file**  
   Place `fastVisor.qml` somewhere permanent, e.g.:
   ```bash
   cp fastVisor.qml ~/.local/bin
   ```

2. **Create a `.desktop` service menu**  
   Create file `~/.local/share/kio/servicemenus/fastvisor.desktop` with:

   ```ini
   [Desktop Entry]
Type=Service
MimeType=image/jpeg;image/png;image/webp;image/gif;image/bmp;image/tiff;
Actions=abrirVisor

[Desktop Action abrirVisor]
Name=Abrir en FastVisor
Name[es]=Abrir en FastVisor
Icon=image-viewer
Exec=qml ~/.local/bin/fastVisor.qml %F
   ```

   > If your system uses Qt5 by default, replace `qml6` with `qml`.

3. **Make it executable (optional)**  
   ```bash
   chmod +x ~/.local/share/kio/servicemenus/fastvisor.desktop
   ```

4. **Restart Dolphin** or run `kbuildsycoca5` (or `kbuildsycoca6`).

Now right‑click any image in Dolphin → **Actions** → **FastVisor – quick preview**.

---

## 🎮 Usage

| Action                          | Control                                                                 |
|---------------------------------|-------------------------------------------------------------------------|
| Move window                     | Click + drag the image                                                  |
| Close viewer                    | `Esc` key or click the ✕ button (top‑right)                            |
| Next image                      | `→` / `↓` / `Space` / mouse wheel down / right arrow button            |
| Previous image                  | `←` / `↑` / mouse wheel up / left arrow button                         |
| Pin / unpin                     | `P` key or click 📍/📌 button – keeps window open when unfocused       |
| Quit (when pinned)              | click ✕ or `Esc`                                                        |

> 💡 **Tip**: Without pin, the viewer closes automatically when it loses focus (e.g., clicking another window). Perfect for quick peeks.

---

## 🧩 How It Works (Technical)

1. When launched with an image path, the script determines the image folder.
2. `FolderListModel` collects all images from that folder.
3. A tiny **4×4 thumbnail** loads first to instantly measure aspect ratio – the window resizes to match the real image proportions.
4. The full‑resolution image loads asynchronously and fades in over the thumbnail.
5. The next image in the folder is preloaded silently.
6. Window is frameless but can be moved by dragging (using `startSystemMove()`).
7. Rounded clipping is done via `OpacityMask` to avoid performance hits.

---

## ❓ Troubleshooting

| Problem                          | Solution                                                                                  |
|----------------------------------|-------------------------------------------------------------------------------------------|
| `qml: command not found`         | Install Qt QML runtime (`qt5-declarative` / `qt6-declarative`)                            |
| `module "Qt.labs.folderlistmodel" is not installed` | Install `qml-module-qt-labs-folderlistmodel` (Ubuntu) or `qt5-labs-folderlistmodel` (Arch) |
| Window does not resize on first image | Check that the image file exists and has valid dimensions. The thumbnail must load first. |
| No navigation between images     | Ensure the folder contains other supported image files (see `nameFilters`).               |
| Window stays open after losing focus | You have pin mode enabled – click the 📌 button or press `P` to disable.                  |

---

## 📝 License

**MIT** – free to use, modify, and distribute.

---

## 🤝 Contributing

Pull requests and issues are welcome! Keep it minimal and focused on the **fast, aesthetic preview** experience.

---

## 🙏 Acknowledgements

Built with QtQuick and a little bit of lazy loading magic. Inspired by the need to preview images without marginal chrome.

