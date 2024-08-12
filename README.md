# SPICE: Smart Projection Interface for Cooking Enhancement

Welcome to the SPICE project! The **Smart Projection Interface for Cooking Enhancement** (SPICE) is a novel user interface that explores the integration of Tangible User Interfaces (TUIs) in a kitchen setting. Our goal is to transform the cooking experience from traditional text-based recipe following to a dynamic, interactive process.

## Context
This project was developed as a final Bachelor Thesis Project for the Bachelor of Computer Science and received a final cumulative grade of 9.3, and a 9.85 for the presentation. The project was developed by Vera Prohaska under the supervision of Dr. Prof. Eduardo Castello Ferrer. 


## Abstract
In recent times, Tangible User Interfaces (TUI) have introduced a new design paradigm for Human Computer Interaction (HCI). TUIs provide an interface to the digital world by providing physical representations of digital information with the aim to overcome the limitations of screen-based interfaces. Regardless of their potential, there is a lack of recent research in how to apply TUIs to daily physical processes, such as cooking. In response to this, we propose SPICE (Smart Projection Interface for Cooking Enhancement). SPICE investigates the integration of Tangible User Interfaces (TUIs) in a kitchen setting, aiming to transform cooking experiences from traditional text-based recipe-following to tangible interactive processes. SPICE consists of different elements such as a tracking system, an agent-based software, and vision large language models to create and interpret a kitchen environment where recipe information is projected onto the same cooking space. Experiments involved 30 participants to assess the efficiency, confidence, and taste perception when using SPICE compared to traditional methods. The result indicates that SPICE allowed participants to perform the recipe in less stops and shorter time, all whilst improving self-scored ratings of efficiency, confidence and even taste. This research offer insights about the potential use of TUIs to improve everyday activities, paving the way for future research in HCI and new computing interfaces.

## Video
[![SPICE Video](add youtube video)](add youtube video)

## Components

| Component | Description | Code |
| --- | --- | --- |
| OptiTrack | Tracking system for the tangible objects | [OptiTrack](./components/optitrack_ros_client/) |
| Projection | Projecting the interface on the kitchen surface | [Projection](./components/udp_ros_to_gama_sender/) |
| Vision | User interface for the cooking process | [Interface](./vision/) |
| Audio | Audio feedback for the cooking process | [Audio](./audio/) |
| Questionnaires | Questionnaires for the user study | [Questionnaires](./questionnaire/) |
| Recipe | Recipe used in the user study | [Recipe](./recipe/) |

## Paper 
The paper for this project can be found [here](link to paper).

## Contact

For any questions or inquiries, please contact me at `vera dot prohaska at gmail dot com`.


