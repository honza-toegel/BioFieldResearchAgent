# BioFieldResearchAgent

## Overview
**BioFieldResearchAgent** is an advanced research assistant designed to explore the bio-fields of trees and plants, particularly in interaction with humans. Built with [LangGraph](https://github.com/langchain-ai/langgraph), this smart research agent autonomously plans and executes bio-field research, leveraging the latest insights from scientific literature and real-time sensor data.

Researcher can interact with the agent using natural language to define research goals, such as:
> *"Figure out if the trees can predict weather, lets focus on bio-field of the pine trees at freq between 1kHz and 10kHz, lets see if there is any correlation with the captured temperature"*

> *"Today we will be meditating close to oak trees between 10:00-10:30. The focus is to check if that has some impact on the tree bio-fields (electric and magnetic activity) compared with a control group."*

> *"Please investigate whether there is a circadian rhythm in the biofield of banana trees, focusing on the electric and magnetic fields in relation to daylight and astronomical time (position of the sun and moon)"*

> *"Today we cut the grass around the anon tree around 2-3 pm, is there any special activity recorded in the bio-field of the anon trees at this time? After 3 pm we moved to the banana trees, was this observable from the records taken?"*

The agent then formulates a comprehensive research plan, collects and processes relevant data using connected bio-field sensing devices, conducts analyses, and generates reports and communicates interactivelly with researchers.

![Research Diagram](assets/BioFieldSignalResearch-BusinessSchema.drawio.svg)

---
## Features
### 🌿 Research Planning
- Generates structured research plans based on user input
- Proposes multiple research options, incorporating insights from the latest research
- Design experiments with proper control groups

### 📡 Sensor Raw-Data Collection 
- Configures bio-field sensing devices (electric, magnetic, quantum, humidity, temp, light, ...)
- Determines optimal data resolution 
- Ensures seamless integration with past collected data 
  - Offline data pre-collection when outside
  - Online-backup of pre-collected data for the deep-analysis

### :chart_with_upwards_trend: Data Pre-Processing
- Plan suitable data processing pipeline
  - Like graph where the nodes represent data-transformation, and edges data-flow
- Possible pre-processing functions:
  - Data filtering (low-pass, denoise,..)
  - FFT fast fourier transform 
  - Standard deviations
  - Mean square
  
### 📊 Data Processing & Analysis
- Identifies and extracts key features from bio-field data
- Prepares data-analysis pipelines
  - Like graph where the nodes represent data-analysis, and edges data-flow
- Possible data analysis functions:
  - Detecting rhythms
  - Detecting correlations
  - Detecting anomalies
  - Detecting synchronicities
  - Detecting action/reaction behaviour

### 🔍 Real-Time Adjustments
- Monitors data streams and adjusts collection parameters in real-time
- Ensures optimal data acquisition for accurate analysis
- Ensures capacities of offline-data storages, data stream speeds,..

### 📢 Live Reporting
- Provides intermediary results and insights during research execution
- Suggest researchers to adjust focus on some specific aspect of experiment during execution
- Highlights unexpected trends or anomalies

### 📄 Summary Reports
- Generates structured reports summarizing findings
- Compares results against prior experiments
- Suggests further research directions

---
## Data Model
- The data model must be capable to persist following data:
- Research experiment intention, description and used participants and devices/sensors
- Metadata about devices and sensors used for data collection (sometimes hardcoded in firmware of device)
- Collected data from sensors - can be used in multiple experiments (split into batches and stored on fs or minio)
- Data send to sensors (split into batches and stored on fs or minio)
  
![Research Diagram](assets/BioFieldSignalResearch-DataModel.drawio.svg)
---
## Contributing
Contributions are welcome! Feel free to:
- Report issues via GitHub Issues
- Submit feature requests
- Fork the repo and create pull requests

---
## License
This project is licensed under the [MIT LICENSE](https://mit-license.org/).

---
## Future Roadmap
- 🧠 AI-driven hypothesis generation
- 📡 Integration with additional bio-field sensors
- 🌍 Cloud-based research collaboration
- 📈 Advanced visualization tools for data interpretation

