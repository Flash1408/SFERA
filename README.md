# SFERA Tool

**SFERA** is a MATLAB-based tool designed for signal analysis and effect control through a user-friendly interface developed in **App Designer**.  
This repository contains the core code, auxiliary functions, and the user manual needed to install and use the tool.

---

## 🗂 Repository Structure

```text
├── Model/                        # Model on which the tool is tested
├── User_Manual.pdf               # Basic user guide and instructions
├── mathworks/                    # Main MATLAB code directory
│   ├── SFERA_beta.mltbx          # Installation package (beta version)
│   ├── SFERA_beta.prj            # Installation project file
│   ├── SFERA_App.mlapp           # App Designer main interface
│   ├── help_functions/           # Auxiliary functions (e.g., signal cleaning)
│   ├── segmentations/            # Signal segmentation routines
│   ├── images/                   # Tool-related images (e.g., logo)
│   ├── Effects_Library/          # Functions and Simulink library for effect control
│   └── functions/                # Core analysis logic
│       ├── isDivergent.m         # Main analysis logic file
│       └── isGenericDiv.m        # Custom analysis prototype (in testing phase)
|       └── ...                   # Base effects checking functions
```
## 🔍 Key Components 

### `mathworks/`
This is the main folder containing all MATLAB code and resources required to run SFERA.

- **`SFERA_App.mlapp`** – The App Designer file providing the main graphical interface.  
- **`SFERA_beta.mltbx`** and **`SFERA_beta.prj`** – Files used for installing and deploying the tool.  
- **`help_functions/`** – Includes utility functions such as signal cleaning routines.  
- **`segmentations/`** – Contains algorithms for different signal segmentation strategies.  
- **`images/`** – Stores visual assets like the tool’s logo.  
- **`Effects_Library/`** – Contains both the functions for effect control and the Simulink block library implementing them.  
- **`functions/`** – Houses the logic for the base analysis.  
  - `isDivergent.m` summarizes the logic behind the core analysis.  
  - `isGenericDiv.m` enables custom analysis functions, but it is currently under testing and **not yet accessible** through the tool interface.

---

## 📘 User Manual

The **`User_Manual.pdf`** provides all the basic instructions needed to install and start using the SFERA tool.  
Please refer to it before running the app for the first time.

---

## ⚙️ Installation & Usage

1. Open **MATLAB**.  
2. Install the tool by running the provided `.mltbx` package or using the `.prj` file in **App Designer**.  
3. Launch the **SFERA App** from the MATLAB Apps tab or directly from the `SFERA_App.mlapp` file.  
4. Follow the steps described in the **User Manual** to begin analyzing your signals.

---

## 🚧 Notes

- The **custom function interface** (`isGenericDiv`) is still under development and **not yet available** in the current release.  
- The current version supports **base effect analysis** only.  
- Future releases will extend functionality to include user-defined functions and expanded effect libraries.

---

## 📄 License

This project is distributed for research and educational purposes.  
