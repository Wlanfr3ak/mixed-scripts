#!/usr/bin/env python3
"""
MKV Index Repair Tool
Author: Windsurf IDE
Description: This script repairs the index of MKV files that cannot be properly skipped/seeked.
It uses ffmpeg to remux the container and create a proper index.

Requirements:
- ffmpeg must be installed and available in the system PATH
- Python 3.6 or higher

Usage:
    python axis-repair-index.py input.mkv output.mkv

Example:
    python axis-repair-index.py "D:\video_broken.mkv" "D:\video_fixed.mkv"

Note: This script works on both Windows and Linux platforms.
"""

import sys
import os
import subprocess
import argparse
from pathlib import Path


def check_ffmpeg():
    """
    Check if ffmpeg is installed and available.
    
    Returns:
        bool: True if ffmpeg is found, False otherwise
    """
    try:
        result = subprocess.run(['ffmpeg', '-version'], 
                              capture_output=True, 
                              text=True, 
                              timeout=10)
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def repair_mkv_index(input_file, output_file):
    """
    Repair the index of an MKV file by remuxing with ffmpeg.
    
    Args:
        input_file (str): Path to the broken MKV file
        output_file (str): Path for the repaired output file
        
    Returns:
        bool: True on success, False on error
    """
    # Check if input file exists
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        return False
    
    # Check if it's an MKV file
    if not input_file.lower().endswith('.mkv'):
        print(f"Warning: '{input_file}' is not an MKV file. This script is optimized for MKV.")
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(output_file)
    if output_dir and not os.path.exists(output_dir):
        try:
            os.makedirs(output_dir)
            print(f"Created output directory: {output_dir}")
        except OSError as e:
            print(f"Error creating output directory: {e}")
            return False
    
    # Build ffmpeg command
    # -c copy: Stream copy (no re-encoding, very fast)
    # -map 0: Copy all streams from input
    # -avoid_negative_ts make_zero: Fix timestamp issues
    cmd = [
        'ffmpeg',
        '-i', input_file,
        '-c', 'copy',
        '-map', '0',
        '-avoid_negative_ts', 'make_zero',
        '-y',  # Overwrite existing output file
        output_file
    ]
    
    print(f"Starting repair of '{input_file}'...")
    print(f"Output file: '{output_file}'")
    print("This process may take several minutes...")
    
    try:
        # Execute ffmpeg
        process = subprocess.Popen(cmd, 
                                 stdout=subprocess.PIPE, 
                                 stderr=subprocess.STDOUT,
                                 text=True,
                                 universal_newlines=True)
        
        # Show progress in real-time
        for line in process.stdout:
            print(line.rstrip())
        
        # Wait for completion
        return_code = process.wait()
        
        if return_code == 0:
            print(f"\n✓ Repair completed successfully!")
            print(f"Repaired file: {output_file}")
            
            # Show file size comparison
            input_size = os.path.getsize(input_file)
            output_size = os.path.getsize(output_file)
            print(f"Original size: {input_size / (1024*1024):.1f} MB")
            print(f"Repaired size: {output_size / (1024*1024):.1f} MB")
            
            return True
        else:
            print(f"\n✗ Error during repair. ffmpeg return code: {return_code}")
            return False
            
    except subprocess.TimeoutExpired:
        print("Error: ffmpeg timeout - repair took too long.")
        return False
    except KeyboardInterrupt:
        print("\nRepair cancelled by user.")
        return False
    except Exception as e:
        print(f"Error executing ffmpeg: {e}")
        return False


def main():
    """
    Main function of the script.
    """
    parser = argparse.ArgumentParser(
        description='Repair MKV file index for proper seeking/skipping',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python axis-repair-index.py video_broken.mkv video_fixed.mkv
  python axis-repair-index.py "D:\\Videos\\problem.mkv" "D:\\Videos\\fixed.mkv"
  python axis-repair-index.py /home/user/video.mkv /home/user/video_fixed.mkv
        """
    )
    
    parser.add_argument('input', 
                       help='Path to the broken MKV input file')
    parser.add_argument('output', 
                       help='Path for the repaired MKV output file')
    parser.add_argument('--check-only', 
                       action='store_true',
                       help='Only check ffmpeg installation and exit')
    
    args = parser.parse_args()
    
    # Check ffmpeg installation
    print("Checking ffmpeg installation...")
    if not check_ffmpeg():
        print("✗ Error: ffmpeg not found!")
        print("\nInstallation instructions:")
        print("Windows:")
        print("  1. Download ffmpeg from https://ffmpeg.org/download.html")
        print("  2. Extract files (e.g., to C:\\ffmpeg)")
        print("  3. Add C:\\ffmpeg\\bin to system PATH environment variable")
        print("\nLinux (Debian/Ubuntu):")
        print("  sudo apt update && sudo apt install ffmpeg")
        print("\nLinux (Fedora/CentOS):")
        print("  sudo dnf install ffmpeg")
        return 1
    
    print("✓ ffmpeg found and available")
    
    if args.check_only:
        print("ffmpeg check successful. Script is ready to use.")
        return 0
    
    # Perform repair
    success = repair_mkv_index(args.input, args.output)
    
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
