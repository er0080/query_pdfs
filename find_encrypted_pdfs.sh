#!/bin/bash

# Script to find all encrypted PDF files in a directory
# Uses pdfinfo from poppler-utils to detect encryption

set -euo pipefail

# Global verbose flag
VERBOSE=false

# Function to display usage
usage() {
    echo "Usage: $0 [-v] <directory>"
    echo "Find all encrypted PDF files in the specified directory (recursively)"
    echo ""
    echo "Options:"
    echo "  -v    Verbose mode (show all PDFs found, not just encrypted ones)"
    echo ""
    echo "Example: $0 /path/to/pdf/directory"
    echo "Example: $0 -v /path/to/pdf/directory"
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
    
    if [ "$VERBOSE" = true ]; then
        echo "DEBUG: Running find command: find \"$target_dir\" -type f \\( -name \"*.pdf\" -o -name \"*.PDF\" \\) -print0"
        echo ""
    fi
    
    # Find all PDF files recursively and process them
    # Temporarily disable set -e to handle function return codes properly
    set +e
    while IFS= read -r -d '' pdf_file; do
        ((total_count++))
        
        if [ "$VERBOSE" = true ]; then
            echo "DEBUG: Found PDF file: $pdf_file"
        fi
        
        # Call function and capture exit code separately to avoid set -e issues
        is_pdf_encrypted "$pdf_file"
        local exit_code=$?
        
        if [ "$VERBOSE" = true ]; then
            echo "DEBUG: is_pdf_encrypted returned: $exit_code"
        fi
        
        case $exit_code in
            0)
                # PDF is encrypted
                echo "ENCRYPTED: $pdf_file"
                ((encrypted_count++))
                ;;
            1)
                # PDF is not encrypted
                if [ "$VERBOSE" = true ]; then
                    echo "NOT ENCRYPTED: $pdf_file"
                fi
                ;;
            2)
                # Error reading PDF
                echo "ERROR: Could not read $pdf_file" >&2
                ;;
        esac
    done < <(find "$target_dir" -type f \( -name "*.pdf" -o -name "*.PDF" \) -print0)
    # Re-enable set -e
    set -e
    
    echo ""
    echo "Summary:"
    echo "Total PDFs found: $total_count"
    echo "Encrypted PDFs: $encrypted_count"
}

# Main script execution
main() {
    local target_directory=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -*)
                echo "Unknown option $1" >&2
                usage
                ;;
            *)
                if [ -n "$target_directory" ]; then
                    echo "Error: Multiple directories specified" >&2
                    usage
                fi
                target_directory="$1"
                shift
                ;;
        esac
    done
    
    # Check if directory was provided
    if [ -z "$target_directory" ]; then
        echo "Error: No directory specified" >&2
        usage
    fi
    
    # Validate target directory
    if [ ! -d "$target_directory" ]; then
        echo "Error: Directory '$target_directory' does not exist." >&2
        exit 1
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "DEBUG: Verbose mode enabled"
        echo "DEBUG: Target directory: $target_directory"
        echo ""
    fi
    
    # Check dependencies
    check_dependencies
    
    # Find encrypted PDFs
    find_encrypted_pdfs "$target_directory"
}

# Run main function with all arguments
main "$@"