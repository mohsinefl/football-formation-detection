# Data Directory

## Overview

This directory is intended to store the datasets required for preprocessing, model training, and evaluation.

The original tracking data used in this project is **not included** in this repository.

## Why is the data unavailable?

The datasets are excluded for the following reasons:

* Licensing restrictions
* Copyright protection
* Data ownership by third parties
* Repository size limitations

Therefore, only the source code, preprocessing pipeline, model architecture, and documentation are provided.


## Supported Data Format

The preprocessing pipeline expects tracking data containing player positions over time. Typical columns include:

| Column | Description               |
| ------ | ------------------------- |
| Frame  | Frame number              |
| Time   | Match timestamp           |
| Team   | Team identifier           |
| Player | Player identifier         |
| X      | X-coordinate on the pitch |
| Y      | Y-coordinate on the pitch |

## Reproducibility

Although the original dataset cannot be shared, this repository contains all components required to reproduce the methodology:

* Data preprocessing pipeline
* Feature engineering
* Team shape extraction
* Formation clustering
* Machine learning models
* Backend API
* Mobile application

Users with access to compatible tracking datasets can reproduce the complete workflow by following the project documentation.

## Disclaimer

This repository is intended for educational, research, and portfolio purposes. The data ownership remains with the respective rights holders.
