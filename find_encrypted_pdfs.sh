#!/bin/bash

# Script to find all encrypted PDF files in a directory
# Uses pdfinfo from poppler-utils to detect encryption

set -euo pipefail

# Function to display usage
usage() {
    echo "Usage: $0 <directory>"
    echo "Find all encrypted PDF files in the specified directory (recursively)"
    echo ""
    echo "Example: $0 /path/to/pdf/directory"
    exit 1
}

# Check if pdfinfo is available
check_dependencies() {
    if ! command -v pdfinfo &> /dev/null; then
        echo "Error: pdfinfo command not found. Please install poppler-utils package." >&2
        echo "Ubuntu/Debian: sudo apt-get install poppler-utils" >&2
        echo "CentOS/RHEL/Fedora: sudo yum install poppler-utils" >&2
        echo "macOS: brew install poppler" >&2
        exit 1
    fi
}

# Function to check if a PDF is encrypted
is_pdf_encrypted() {
    local pdf_file="$1"
    local pdfinfo_output
    
    # Run pdfinfo and capture output, suppressing stderr for cleaner output
    if pdfinfo_output=$(pdfinfo "$pdf_file" 2>/dev/null); then
        # Check if the output contains "Encrypted: yes"
        if echo "$pdfinfo_output" | grep -q "^Encrypted:[[:space:]]*yes"; then
            return 0  # PDF is encrypted
        else
            return 1  # PDF is not encrypted
        fi
    else
        # pdfinfo failed (possibly corrupted file or permission issue)
        return 2  # Error reading PDF
    fi
}

# Main function to find encrypted PDFs
find_encrypted_pdfs() {
    local target_dir="$1"
    local encrypted_count=0
    local total_count=0
    
    echo "Scanning directory: $target_dir"
    echo "Looking for encrypted PDF files..."
    echo ""
    
    # Find all PDF files recursively and process them
    while IFS= read -r -d '' pdf_file; do
        ((total_count++))
        
        case $(is_pdf_encrypted "$pdf_file"; echo $?) in
            0)
                # PDF is encrypted
                echo "ENCRYPTED: $pdf_file"
                ((encrypted_count++))
                ;;
            1)
                # PDF is not encrypted (silent)
                ;;
            2)
                # Error reading PDF
                echo "ERROR: Could not read $pdf_file" >&2
                ;;
        esac
    done < <(find "$target_dir" -type f \( -name "*.pdf" -o -name "*.PDF" \) -print0)
    
    echo ""
    echo "Summary:"
    echo "Total PDFs found: $total_count"
    echo "Encrypted PDFs: $encrypted_count"
}

# Main script execution
main() {
    # Check command line arguments
    if [ $# -ne 1 ]; then
        usage
    fi
    
    local target_directory="$1"
    
    # Validate target directory
    if [ ! -d "$target_directory" ]; then
        echo "Error: Directory '$target_directory' does not exist." >&2
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Find encrypted PDFs
    find_encrypted_pdfs "$target_directory"
}

# Run main function with all arguments
main "$@"