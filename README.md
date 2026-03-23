# Integrating BarTender Cloud with SAP S/4HANA Cloud

## Description

This plugin is designed to allow customers to print.

This integration showcases:

- Querying data from S/4HANA Cloud CDS views
- Serializing data to JSON format
- Querying BarTender Cloud APIs for eligible printers
- Querying BarTender Cloud APIs for available BarTender label templates
- Submitting print jobs to BarTender Cloud REST APIs with data from S/4HANA in response to SAP business events
- Submitting print jobs to Bartender Cloud REST APIs in response to manual user requests

## Business Scenario

In specific focus regions, we would like to follow up with newly created customers or existing customers that have had their data updated in our SAP S/4HANA Cloud backend. External call center employees should do this follow up for us by contacting relevant customers by phone. At the same time, the call center employees have no access to our SAP S/4HANA system. We therefore provide a custom built extension application that is specifically designed and optimized for the task and that is supplied with relevant data in real time using an event-driven approach. 

**Current Position - What is the challenge?**

- Business Partner data is available only in SAP S/4HANA system.
- Call center personnel need SAP S/4HANA access for their work.
- No custom UI for specific geo marketing use case.

**Destination - What is the outcome?**

- Changes in S/4HANA communicated via events in real time to the extension application.
- Custom extension application works independently from SAP S/4HANA.
- Call center personnel only needs access to custom app.

## Architecture

### Architecture Diagram

![solution diagram](./documentation/images/architecture_diagram.png)

The BarTender Print Connector for S/4HANA Cloud application is developed in ABAP within the Eclipse IDE and runs on SAP S/4HANA Public Cloud. The application queries SAP CDS views and uses BarTender Cloud REST APIs to submit print jobs with data from the S/4HANA Cloud system.

## Requirements
* SAP S/4HANA Public Cloud system

### For local development you would require the following:
* A Git platform and a repository for the custom pliugin
* [Eclipse IDE with ABAP Development Tools (ADT)](https://developers.sap.com/tutorials/abap-install-adt..html)

## Installation

### Step 1: [Importing the Plugin Code](/documentation/importing_code.md)

### Step 2: [Configuring the Plugin](/documentation/configuring_plugin.md)

### Step 3: [Extending the Code](/documentation/extending_code.md)

## Known Issues

- Label Format and Printer selection dialogs are limited to 500 records. If your tenant has more than 500 label formats or printers, they may not show in the dialogs.
- BarTender Cloud endpoint URL is hard-coded in ABAP class in 3 locations.

### [Uninstalling the Plugin](/documentation/uninstall.md)

## How to Obtain Support

If you find a bug or you need additional support, please [contact support](https://support.seagullsoftware.com/hc/en-us) on Seagull's Support Portal.