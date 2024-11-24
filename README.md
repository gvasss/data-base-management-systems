# DBMS Project: Ship Positions Analysis

## Overview

The project involves working with real-world Automatic Identification System (AIS) data, analyzing the positions of ships in the Piraeus and Saronic Gulf areas during August 2019. The project uses PostgreSQL to manage the data and optimize query performance.

## Project Goals

The primary objectives of this project are:
1. Importing real-world AIS data into PostgreSQL.
2. Executing SQL queries to analyze ship movements and vessel information.
3. Optimizing the performance of database queries through memory management, parallel processing, indexing, and partitioning.

## Dataset

The dataset consists of three CSV files:
1. **Positions.csv**: Contains ship position records, including longitude, latitude, speed, and timestamp.
2. **Vessels.csv**: Provides static information about ships, such as the flag and type of each vessel.
3. **VesselTypes.csv**: Describes various types of vessels, mapping type codes to human-readable descriptions.

The dataset is available for download from the [University of Piraeus AIS Data Visualization](https://datastories.cs.unipi.gr/index.php/s/ZEM86Fe6i4FeJCj).

### Database Schema

- **Positions** (`id`, `t`, `lon`, `lat`, `heading`, `course`, `speed`, `vessel_id`)
- **Vessels** (`id`, `flag`, `type`)
- **VesselTypes** (`code`, `description`)
