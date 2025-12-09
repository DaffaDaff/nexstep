# Nexstep

> 🔧 A cross-platform / multi-environment project supporting Android, iOS, web, desktop (macOS / Windows / Linux).  
> Struktur monorepo yang digunakan untuk multi-platform development.

---

## 📂 Project Structure

nexstep/
├── android/ – Android platform code
├── ios/ – iOS platform code
├── web/ – Web application code
├── lib/ – Shared library / core logic
├── windows/ – Windows desktop configuration
├── macos/ – macOS desktop configuration
├── linux/ – Linux desktop configuration
├── test/ – Test suite (unit / integration)
├── assets/imgs/ – Image assets / resources
├── analysis_options.yaml
├── .gitignore
└── README.md


---

## 🚀 Overview

**Nexstep** adalah proyek dengan arsitektur monorepo yang dirancang untuk berjalan pada berbagai platform secara bersamaan, termasuk:

- 📱 **Android**
- 🍎 **iOS**
- 💻 **Windows**
- 🐧 **Linux**
- 🍏 **macOS**
- 🌐 **Web**

Folder `lib/` berfungsi sebagai inti logika aplikasi yang digunakan lintas platform, sementara folder lainnya berisi konfigurasi dan kode spesifik untuk masing-masing environment.

---

## 🛠️ Getting Started

```sh
# Clone repository
git clone https://github.com/DaffaDaff/nexstep.git
cd nexstep
