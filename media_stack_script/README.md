## Legal and Ethical Disclaimer

This project and its associated tools are intended solely for personal and lawful use. The creators and contributors of this project have developed it as a personal project and do not condone or encourage any illegal or unethical activities, including but not limited to the unauthorized downloading, sharing, or distribution of copyrighted materials.

By using this project, you agree to:

1. **Abide by all applicable laws and regulations** in your jurisdiction, including copyright and intellectual property laws.
2. **Ensure that all content you download, access, or interact with is obtained legally and ethically**.
3. **Take full responsibility for your actions**, including the proper use of the software and any consequences arising therefrom.

The creators and contributors of this project are not liable for any misuse of the software. This project is provided as-is, and any use of it must be in compliance with all legal and ethical standards.

**Warning:** Engaging in the unauthorized downloading or distribution of copyrighted material may lead to severe civil or criminal penalties. Respect the rights of content creators and adhere to ethical practices.

If you are unsure about the legality of your actions, consult the applicable laws in your region or seek legal advice before proceeding.

## Parameters

This section provides an overview of the key parameters used in the project. Customize it to align with your specific project needs.

| Parameter                | Description                                                  | Default Value         |
|--------------------------|--------------------------------------------------------------|-----------------------|
| `PUID`                  | User ID for file permissions                                  | `981`                 |
| `PGID`                  | Group ID for file permissions                                 | (User-specified)      |
| `TZ`                    | Time zone configuration                                      | `US/Chicago`          |
| `LOCAL_NETWORK`         | Local network range for the containers                       | `192.168.0.0/24`      |
| `OPENVPN_CONFIG`        | OpenVPN configuration file                                   | (User-specified)      |
| `HOST_DOWNLOADS`        | Host directory for downloads                                 | (User-specified)      |
| `HOST_TV`               | Host directory for TV shows                                  | (User-specified)      |
| `HOST_MOVIES`           | Host directory for movies                                    | (User-specified)      |
| `HOST_SONARR_CONFIG`    | Host directory for Sonarr configuration                      | (User-specified)      |
| `HOST_RADARR_CONFIG`    | Host directory for Radarr configuration                      | (User-specified)      |
| `HOST_TRANSMISSION_CONFIG` | Host directory for Transmission configuration              | (User-specified)      |
| `HOST_PROWLARR_CONFIG`  | Host directory for Prowlarr configuration                    | (User-specified)      |
| `OPENVPN_CREDENTIALS`   | Path to OpenVPN credentials file                             | (User-specified)      |

### Notes
- Default values are provided only for `PUID`, `TZ`, and `LOCAL_NETWORK`.
- All other parameters must be specified by the user during the script execution.
- Ensure correct values for `PUID` and `PGID` to avoid permission issues.
- Make sure that directory paths are consistent with your system's structure.

Feel free to expand this table with additional parameters that are relevant to your project!