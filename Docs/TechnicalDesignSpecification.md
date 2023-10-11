# Technical Design Specification for SSL Certificate Management Script

## 1. Introduction

This Technical Design Specification outlines the architecture, functionality, and implementation details for the PowerShell script designed to manage SSL certificate bindings for a service running on port 9443. The script leverages the `netsh` utility and PowerShell to automate the process of adding and removing SSL certificate bindings. 

## 2. High-Level Overview

The script performs the following key tasks:

- Identifies a certificate with a specific subject pattern in the Local Machine's personal certificate store.
- Extracts the thumbprint of the identified certificate for use in SSL certificate binding.
- Configures the `netsh` commands for adding and removing SSL certificate bindings on port 9443.
- Logs script execution details and errors to a specified log file.
- Manages SSL certificate bindings by executing `netsh` commands and handling service restarts as necessary.

## 3. Script Components

The script is divided into several key components:

### 3.1. Log File Management

The script uses a log file to record script execution details, including timestamps for each log entry. The log file path is defined using the `$logPath` variable.

### 3.2. Certificate Thumbprint Extraction

A certificate with a subject matching the "*claims*" pattern is sought in the Local Machine's personal certificate store. The thumbprint of the found certificate is stored in the `$certThumbprint` variable.

### 3.3. `netsh` Command Configuration

Two `netsh` commands are defined:
- `$netshAddCommand`: Used to add an SSL certificate binding on port 9443.
- `$netshDeleteCommand`: Used to delete an existing SSL certificate binding on port 9443.

### 3.4. Logging Function

The `Write-Log` function appends log entries to the specified log file, with each entry formatted to include a timestamp.

### 3.5. Before Deleting SSL Bindings

The `logBeforeDeleteBindings` function captures information about the current SSL certificate binding on port 9443 using the `netsh` command. The output is parsed into a custom object and logged.

### 3.6. SSL Binding Deletion

The `deleteSageBinding` function removes the current SSL certificate binding on port 9443 using the `netsh delete` command. The process and success or failure are logged.

### 3.7. Exit Code Handling

The `f.lastExitCode` function checks the exit code of the last executed command and logs whether the SSL certificate binding was successful or not.

### 3.8. Service Restart

The `restartSage` function attempts to restart a service named "SagePeoplePublicAPIService.exe."

### 3.9. Main Script Execution

The `startScript` function is currently an empty placeholder for initiating the script's execution. Users can customize it based on their specific requirements.

### 3.10. Exception Handling

The script includes error handling to catch and log exceptions that may occur during execution.

### 3.11. Service Information

The `serviceInfo` function logs information about the service, including its name, display name, status, and related details.

## 4. Execution Flow

1. The script initiates by logging the start of execution.

2. Information about the current SSL binding on port 9443 is captured and logged.

3. The certificate thumbprint is extracted and logged.

4. The `netsh delete` command is constructed, executed, and logged. The SSL binding is removed.

5. If the certificate thumbprint is found:
   - The `netsh add` command is constructed, executed, and logged.
   - The exit code is checked to determine the success or failure of the SSL binding operation.
   - The service is restarted.

6. If the certificate thumbprint is not found or the search pattern does not match any certificates, an appropriate message is logged.

7. Service information is captured and logged.

8. The script handles exceptions and logs any errors that occur during execution.

## 5. Customization

Users can customize the script by adjusting variables, modifying functions, or adding additional logic to meet specific requirements.

## 6. Conclusion

This Technical Design Specification provides an in-depth understanding of the SSL certificate management script's architecture and functionality. It serves as a reference for users and administrators who wish to implement and customize the script for their environment. Careful testing and review of the script should be conducted before deploying it in a production setting.