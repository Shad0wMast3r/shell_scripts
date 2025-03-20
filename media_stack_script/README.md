
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
| `PGID`                  | Group ID for file permissions                                 | `981`                 |
| `TZ`                    | Time zone configuration                                      | `US/Chicago`          |
| `LOCAL_NETWORK`         | Local network range for the containers                       | `192.168.0.0/24`      |
| `OPENVPN_CONFIG`        | OpenVPN configuration file                                   | `us_chicago`          |
| `HOST_DOWNLOADS`        | Host directory for downloads                                 | `/data/torrent/downloads` |
| `HOST_TV`               | Host directory for TV shows                                  | `/data/plex/tv_shows` |
| `HOST_MOVIES`           | Host directory for movies                                    | `/data/plex/movies`   |
| `HOST_SONARR_CONFIG`    | Host directory for Sonarr configuration                      | `/data/torrent/sonarr` |
| `HOST_RADARR_CONFIG`    | Host directory for Radarr configuration                      | `/data/torrent/radarr` |
| `HOST_TRANSMISSION_CONFIG` | Host directory for Transmission configuration              | `/data/torrent/config/works` |
| `HOST_PROWLARR_CONFIG`  | Host directory for Prowlarr configuration                    | `/data/torrent/prowlarr` |
| `OPENVPN_CREDENTIALS`   | Path to OpenVPN credentials file                             | `/data/torrent/config/openvpn-credentials.txt` |

### Notes
- Adjust the **default values** based on your setup.
- Make sure that directory paths are consistent with your system's structure.
- Ensure correct values for `PUID` and `PGID` to avoid permission issues.

Feel free to expand this table with additional parameters that are relevant to your project! Let me know if you'd like further refinement.