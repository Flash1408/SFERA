# SFERA Tool

**SFERA** is a MATLAB-based tool designed for signal analysis and effect control through a user-friendly interface developed in **App Designer**.  
This repository contains the core code, auxiliary functions, and the user manual needed to install and use the tool.

---

## 🗂 Repository Structure

```text
├── Buck_BLDC_2023a_4.slx                   # Model on which the tool is tested
├── Buck_BLDC_2023a_4_faultInfo.xml         # XML containing faults activation states
├── User Manual.pdf                         # Basic user guide and instructions
├── sfera_tool/                             # Main MATLAB code directory
│   ├── SFERA beta.mlappinstall             # Installation package (beta version)
│   ├── SFERA beta.prj                      # Installation project file
│   ├── SFERA.mlapp                         # App Designer main interface
│   ├── segmentations/                      # Signal segmentation routines
│   ├── images/                             # Tool-related images (e.g., logo)
│   ├── Effects Library/                    # Functions and Simulink library for effect control
│       ├── functions/                      # Core analysis logic
│           ├── isDivergent.m               # Main analysis logic file
│           ├── isCustomDivergent.m         # Custom analysis prototype (in testing phase)
|           ├── ...                         # Base effects checking functions
|           ├── options/                    # MATLAB class hierarchy: abstract 'options' and subclasses for each checking function
|           └── aux_functions/              # Auxiliary functions used during analysis (e.g., cleanSignal)
├── developer_corner/                       # Useful documents for developers to  modify code
```
## 🔍 Key Components 

### `sfera_tool/`
This is the main folder containing all MATLAB code and resources required to run SFERA.

- **`SFERA.mlapp`** – The App Designer file providing the main graphical interface.  
- **`SFERA beta.mlappinstall`** and **`SFERA_beta.prj`** – Files used for installing and deploying the tool.  
- **`help_functions/`** – Includes utility functions such as signal cleaning routines.  
- **`segmentations/`** – Contains algorithms for different signal segmentation strategies.  
- **`images/`** – Stores visual assets like the tool’s logo.  
- **`Effects_Library/`** – Contains both the functions for effect control and the Simulink block library implementing them.  
- **`functions/`** – Houses the logic for the base analysis.  
  - `isDivergent.m` summarizes the logic behind the core analysis.  
  - `isCustomDivergent.m` enables custom analysis functions, but it is currently under testing and **not yet accessible** through the tool interface.

---

## 📘 User Manual

The **`User_Manual.pdf`** provides all the basic instructions needed to install and start using the SFERA tool.  
Please refer to it before running the app for the first time.

---

## ⚙️ Installation & Usage

1. Open **MATLAB**.  
2. Install the tool by running the provided `.mlappinstall` package or using the `.prj` file in **App Designer**.  
3. Launch the **SFERA App** from the MATLAB Apps tab or directly from the `SFERA_App.mlapp` file.  
4. Follow the steps described in the **User Manual** to begin analyzing your signals.

---

## 🚧 Notes

- The **custom function interface** (`isCustomDivergent`) is still under development and **not yet available** in the current release.  
- The current version supports **base effect analysis** only.  
- Future releases will extend functionality to include user-defined functions and expanded effect libraries.

---

## 📄 License

This project is distributed for research and educational purposes.  
