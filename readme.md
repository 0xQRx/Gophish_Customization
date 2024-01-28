# GoPhish Customization Script

## Project Overview
This script is designed to streamline customization of [GoPhish](https://github.com/gophish/gophish), an open-source phishing toolkit, making it more effective and versatile for simulated phishing campaigns. It automates several customizations, especially those that help in evading common security controls.

### Key Features:
- **Header Customization**: Modifies HTTP headers used by **GoPhish**, enhancing the ability to evade security controls and to mimic legitimate traffic more closely.
- **Server Name and Parameters Configuration**: Enables easy modification of server names and recipient parameters within **GoPhish**.
- **404 Page Customization**: Provides the ability to implement a custom 404 error page, making phishing pages less conspicuous and more convincing when browsed to the wrong page.


## Author
**Creator:** 0xQRx  
**Created:** 25 Jan 2024

## Disclaimer
This script is provided for educational purposes only. Use it at your own risk. The creator of this script is not responsible for any misuse or damage caused by this script.

## Usage
**The script must be run from its own directory before building GoPhish binary, DO NOT place script folder inside `gophish` folder**. To use the script, first make it executable:

```bash
chmod +x ./patch.sh
```

Then run the script with the required options:

```bash
./patch.sh --path ../gophish --x-contact-header "X-New-Contact" --x-signature-header "X-New-Signature" --server-name "NewServerName" --recipient-parameter "newParam" --rid-length 12

Options
--path: Path to the GoPhish installation directory.
--x-contact-header: New value to replace the old X-Gophish-Contact header.
--x-signature-header: New value to replace the X-Gophish-Signature header.
--server-name: New server name.
--recipient-parameter: New recipient parameter(RID).
--rid-length: New length for the recipient parameter(RID).
```

**NOTE**: You can delete the `gophish` binary. To modify values again, simply use the same script. It tracks the latest values used, allowing you to customize your `GoPhish` instance multiple times as needed.

## Credit
### References:
- Based on Nicholas Anastasi's blog post: [Never Had a Bad Day Phishing - How to Set Up GoPhish to Evade Security Controls](https://www.sprocketsecurity.com/resources/never-had-a-bad-day-phishing-how-to-set-up-gophish-to-evade-security-controls)
- Custom 404 Page setup taken from Michael Eder's GitHub repository: [edermi/gophish_mods](https://github.com/edermi/gophish_mods/blob/master/controllers/phish.go)