# PDF Encryption Detection Tool

A simple bash script that uses the `pdfinfo` command-line tool from the poppler-utils package to identify all encrypted PDF files in a target directory.

## Prerequisites

- `poppler-utils` package (provides the `pdfinfo` command)

### Installation

**Ubuntu/Debian:**
```bash
sudo apt-get install poppler-utils
```

**CentOS/RHEL/Fedora:**
```bash
sudo yum install poppler-utils
# or
sudo dnf install poppler-utils
```

**macOS:**
```bash
brew install poppler
```

## Usage

The script will recursively scan a target directory for PDF files and identify which ones are encrypted.

## Features

- Recursively searches directories for PDF files
- Uses `pdfinfo` to detect PDF encryption status
- Reports encrypted PDF files found in the target directory

## How it Works

The script leverages the `pdfinfo` utility, which can detect whether a PDF file is encrypted by examining the PDF metadata. When `pdfinfo` encounters an encrypted PDF, it will indicate the encryption status in its output.