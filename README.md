# PowerShell | SharePoint Online | Inventory | Reporting | Governance | Microsoft 365
This repository provides a robust automation solution that scans large SharePoint and organisational repositories to produce precise filetype distribution insights. It replaces manual auditing with a scalable, repeatable workflow that reduces operational effort and supports compliance, migration planning, and storage optimisation. 
## Sample Execution Output
<img width="1707" height="921" alt="Output" src="https://github.com/user-attachments/assets/74e88706-59f3-4030-807e-cb9a2cc9479f" />

## Key Features
- Automated filetype analysis across SharePoint repositories  
- High-speed scanning for large datasets  
- Detailed filetype distribution reports for compliance and governance  
- Supports migration planning and storage optimisation  
- Reduces manual workload and operational risk

## Technologies Used
- PowerShell / PnP.PowerShell  
- SharePoint REST / Graph API  
- CSV/JSON reporting modules  
## Enterprise Impact
Successfully deployed in enterprise environments to resolve complex inventory challenges and enable data-driven decisions. The script improves audit accuracy, reduces manual effort, and enhances operational efficiency.
## Prerequisites

### Software
- Windows PowerShell 5.1 or PowerShell 7.4+
- PnP.PowerShell module

```powershell
Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force
```

### Permissions
- SharePoint Administrator or Global Administrator role (to enumerate all site collections)
- Alternatively, Site Collection Administrator or Read access on each site to be scanned
- SharePoint Admin Center URL, for example `https://<tenant>-admin.sharepoint.com`

### Authentication
- Interactive sign-in (MFA supported) or an Entra ID app registration with `Sites.Read.All`

### Environment
- Network access to `*.sharepoint.com` and `login.microsoftonline.com`
- A local folder with write access for the exported CSV report

## Getting Started

1. Clone the repository.
2. Update the SharePoint admin URL and output path at the top of the script.
3. Run the script:

```powershell
.\SharePointFileTypeSummary.ps1
```

4. Review the generated CSV report.
## Automation Alignment
This project demonstrates innovation in enterprise automation and technical leadership in developing scalable solutions for SharePoint inventory management. By publishing this work, I contribute to the broader digital technology community and highlight impact aligned with the innovation criteria, leadership, and sector contribution
## Future Enhancements
- Integration with Azure storage analytics  
- Support for multi-tenant SharePoint environments  
- Visual dashboards for filetype distribution  
- Automated anomaly detection for compliance insights
## Contributions
Contributions and suggestions are welcome. Please raise issues or submit pull requests.
