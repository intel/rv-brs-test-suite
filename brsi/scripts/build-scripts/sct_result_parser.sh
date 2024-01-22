#!/bin/bash
#!/bin/bash
#
#  Copyright (c) 2024 Intel Corporation
#
#  This program and the accompanying materials
#  are licensed and made available under the terms and conditions of the BSD License
#  which accompanies this distribution.  The full text of the license may be found at 
#  http://opensource.org/licenses/bsd-license.php
# 
#  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
# 
##

# Initialize associative arrays for storing test cases and counts
declare -A testcases
declare -A status_counts=(
)
usage() {
  echo "Usage: $0 -l LOG_PATH -s SKIP_PATH [-o OUTPUT_PATH]"
  echo "  -l LOG_PATH      Path to the log summary file."
  echo "  -s SKIP_PATH     Path to the skipped case list file."
  echo "  -o OUTPUT_PATH   Path to the output result file (optional, default: ./result.txt)."
  echo "  -m: Use this option to output the result in Markdown format."
  echo ""
  echo "Example:"
  echo "  $0 -l FSx:/acs_results/sct_results/Overall/Summary.log \\"
  echo "     -s FS(x):/EFI/BOOT/brs/SCT/Data/SkippedCase.ini \\"
  echo "     -o ./result.txt"
  exit 1
}
# Function to process log file
process_log_file() {
  echo "Processing log file: $1"
  while IFS= read -r line; do
    if [[ $line =~ (.*):\ \[(.*)\] ]]; then
      testcase_name="${BASH_REMATCH[1]}"
      status="[${BASH_REMATCH[2]}]"
      # Add to testcases array if not already present
      if [[ -z ${testcases["$testcase_name:$status"]} ]]; then
        testcases["$testcase_name:$status"]=1
        ((status_counts["$status"]++))
      fi
    fi
  done < "$1"
}

# Function to process skip file
process_skip_file() {
  echo "Processing skip file: $1"
  dos2unix -f "$1"
  while IFS= read -r line; do
    if [[ $line =~ CaseName=(.*) ]]; then
      testcase_name="${BASH_REMATCH[1]}"
      status="[SKIP]"
      # Add to testcases array if not already present
      if [[ -z ${testcases["$testcase_name:$status"]} ]]; then
        testcases["$testcase_name:$status"]=1
        ((status_counts["$status"]++))
      fi
    fi
  done < "$1"
}

result_file="result.txt"
markdown=false

# Parse command-line arguments
while getopts "l:s:o:m" opt; do
  case $opt in
    l) process_log_file "$OPTARG" ;;
    s) process_skip_file "$OPTARG" ;;
    o) result_file="$OPTARG" ;;
    m) markdown=true ;;
    \?) usage ;;
    :) usage ;;
  esac
done

# Calculate total number of test cases
total=0
for count in "${status_counts[@]}"; do
  ((total+=count))
done

# Clear the result file or create it if it doesn't exist
> "$result_file"

{
  echo "SCT Summary"
  echo ""
  echo "Result                  Test(s)"
  for status in "${!status_counts[@]}"; do
    percentage=$(printf "%.2f%%" "$(bc <<< "scale=4; (${status_counts[$status]}*100)/$total")")
    printf "%-25s %5s (%6s)\n" "$status:" "${status_counts[$status]}" "$percentage"
  done
  echo ""
} | tee "$result_file"
# Output detailed test case list by status
status_order=([FAILED] [NOT SUPPORTED] [SKIP] [PASSED] [PASSED WITH WARNINGS])

if $markdown; then
  echo "| Testcase Status |" >> "$result_file"
  echo "| --------------- |" >> "$result_file"
else
  for status in "${status_order[@]}"; do
    echo "$status:" >> "$result_file"
  done
fi

for status in "${status_order[@]}"; do
  for testcase in "${!testcases[@]}"; do
    if [[ $testcase == *":$status" ]]; then
      # Remove the status from the testcase name and append to the file
      if $markdown; then
        echo "| ${testcase%:$status} |" >> "$result_file"
      else
        echo "${testcase%:$status}" >> "$result_file"
      fi
    fi
  done
  if ! $markdown; then
    echo "" >> "$result_file"
  fi
done
