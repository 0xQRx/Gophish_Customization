#!/bin/bash

######################### AUTHOR ####################################
#
# Creator: 0xQRx
# Created: 25 Jan 2024
#
##################### DISCLAIMER #################################### 
#
# This script is provided for educational purposes only. Use it at your own risk.
# The creator of this script is not responsible for any misuse or damage caused by this script.
#
####################### CREDIT ######################################
#
# References:
# Based on Nicholas Anastasi's blog post:
# https://www.sprocketsecurity.com/resources/never-had-a-bad-day-phishing-how-to-set-up-gophish-to-evade-security-controls
#
# Custom 404 Page setup taken from Michael Eder's GitHub repository:
# https://github.com/edermi/gophish_mods/blob/master/controllers/phish.go
#
######################## USAGE ######################################
#
# The script must be run from its own directory.
# Make the script executable:
# chmod +x ./patch.sh
#
# Usage Example:
# ./patch.sh --path ../gophish --x-contact-header "X-New-Contact" --x-signature-header "X-New-Signature" --server-name "IGNORE" --recipient-parameter "newParam" --rid-length 12
#
# Options:
# --path: Path to the GoPhish installation directory.
# --x-contact-header: New value to replace the old X-Gophish-Contact header.
# --x-signature-header: New value to replace the X-Gophish-Signature header.
# --server-name: New server name.
# --recipient-parameter: New recipient parameter (RID).
# --rid-length: New length for the recipient parameter (RID).
#
#####################################################################


# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE="\e[34m"
YELLOW="\e[33m"
NC='\033[0m' # No Color

# Function to display usage instructions
usage() {
    echo "Usage: $0 --path GOPHISH_DIR [OPTIONS]"
    echo "Options:"
    echo "  --x-contact-header STRING       Value to replace 'X-Gophish-Contact'."
    echo "  --x-signature-header STRING     Value to replace 'X-Gophish-Signature'."
    echo "  --server-name STRING            New value for 'Server Name'."
    echo "  --recipient-parameter STRING    New value for 'Recipient Parameter(RID)'."
    echo "  --rid-length NUMBER            Number to set the length of RID signature."
    echo ""
    echo -e "${YELLOW} DISCLAIMER: This script is provided for educational purposes only. Use it at your own risk."
    echo "            The creator of this script is not responsible for any misuse or damage caused by this script."
}

# Initialize default values for arguments
gophish_dir=""
x_contact_header=""
x_signature_header=""
server_name=""
recipient_parameter=""
rid_length=""

# Read old X-Gophish-Contact header from file
if [ -f "./files/old_contact_header.txt" ]; then
    old_contact_header=$(<./files/old_contact_header.txt)
else
    echo -e "${YELLOW}[WARNING]${NC}Cannot find old_contact_header.txt in ./files. Using default 'X-Gophish-Contact'.${NC}"
    old_contact_header="X-Gophish-Contact"
fi

# Read old X-Gophish-Signature header from file
if [ -f "./files/old_signature_header.txt" ]; then
    old_signature_header=$(<./files/old_signature_header.txt)
else
    echo -e "${YELLOW}[WARNING]${NC}Cannot find old_signature_header.txt in ./files. Using default 'X-Gophish-Signature'.${NC}"
    old_signature_header="X-Gophish-Signature"
fi

# Parse named arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)
            gophish_dir="$2"
            shift 2
            ;;
        --x-contact-header)
            x_contact_header="$2"
            shift 2
            ;;
        --x-signature-header)
            x_signature_header="$2"
            shift 2
            ;;
        --server-name)
            server_name="$2"
            shift 2
            ;;
        --recipient-parameter)
            recipient_parameter="$2"
            shift 2
            ;;
        --rid-length)
            rid_length="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Check if the GoPhish directory path was provided
if [ -z "$gophish_dir" ]; then
    echo -e "${RED}You must specify the path to the GoPhish directory with --path.${NC}"
    usage
    exit 1
fi

# Perform modifications based on provided arguments
if [ -n "$x_contact_header" ]; then
    find "$gophish_dir" -type f -exec sed -i "s/$old_contact_header/$x_contact_header/g" {} +
    echo -e "${GREEN}[SUCCESS]${NC}$old_contact_header header replaced with ${NC}${RED}$x_contact_header${NC}."
    
    echo "$x_contact_header" > ./files/old_contact_header.txt
    echo -e "${BLUE}[INFO]${NC}New header saved to ./files/old_contact_header.txt${NC}"
fi

if [ -n "$x_signature_header" ]; then
    find "$gophish_dir" -type f -exec sed -i "s/$old_signature_header/$x_signature_header/g" {} +
    echo -e "${GREEN}[SUCCESS]${NC}$old_signature_header header replaced with ${NC}${RED}$x_signature_header${NC}."

    echo "$x_signature_header" > ./files/old_signature_header.txt
    echo -e "${BLUE}[INFO]${NC}New header saved to ./files/old_signature_header.txt${NC}"
fi

if [ -n "$server_name" ]; then
    sed -i "s/const ServerName = \".*\"/const ServerName = \"$server_name\"/" "$gophish_dir/config/config.go"
    echo -e "${GREEN}[SUCCESS]${NC}Server Name modified to ${NC}${RED}$server_name${NC}."
fi

if [ -n "$recipient_parameter" ]; then
    sed -i "s/const RecipientParameter = \".*\"/const RecipientParameter = \"$recipient_parameter\"/" "$gophish_dir/models/campaign.go"
    echo -e "${GREEN}[SUCCESS]${NC}Recipient Parameter(RID) modified to ${NC}${RED}$recipient_parameter${NC}."
fi

if [[ $rid_length =~ ^[0-9]+$ ]]; then
    sed -i "s/k := make(\[\]byte, [0-9]\{1,\})/k := make(\[\]byte, $rid_length)/" "$gophish_dir/models/result.go"
    echo -e "${GREEN}[SUCCESS]${NC}RID length set to ${NC}${RED}$rid_length${NC}."
else
    echo -e "${RED}RID length not provided or is not a number${NC}."
fi

# Copying files from ./files to specified locations
cp ./files/phish.go "$gophish_dir/controllers/"
echo -e "${BLUE}[INFO]${NC}Patched ${gophish_dir}/controllers/phish.go${NC}"

cp ./files/404.html "$gophish_dir/templates/"
echo -e "${BLUE}[INFO]${NC}Created 404.html. It is located at ${gophish_dir}/templates/404.html and can be customized.${NC}"
echo -e "${BLUE}[INFO]${NC}Headers for 404 page can be customized in ${gophish_dir}/controllers/phish.go file${NC}."
