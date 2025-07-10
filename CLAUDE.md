# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple bash script project for detecting encrypted PDF files using the `pdfinfo` command-line tool from poppler-utils. The project consists of a single bash script that recursively scans directories to identify encrypted PDFs.

## Prerequisites

- `poppler-utils` package must be installed (provides `pdfinfo` command)
- Installation varies by OS:
  - Ubuntu/Debian: `sudo apt-get install poppler-utils`
  - CentOS/RHEL/Fedora: `sudo yum install poppler-utils` or `sudo dnf install poppler-utils`
  - macOS: `brew install poppler`

## Core Functionality

The main script should:
- Accept a target directory as input
- Recursively find all `.pdf` files in the directory
- Use `pdfinfo` to check encryption status of each PDF
- Report which PDFs are encrypted

## Testing

When developing or testing the script:
- Create test directories with both encrypted and unencrypted PDF files
- Verify the script correctly identifies encrypted PDFs
- Test with various directory structures and edge cases
- Ensure proper error handling for invalid files or missing dependencies