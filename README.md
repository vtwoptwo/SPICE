# SPICE: Smart Projector Interface for Cooking Enhancement

Welcome to the SPICE project! The **Smart Projector Interface for Cooking Enhancement** (SPICE) is a novel user interface that explores the integration of Tangible User Interfaces (TUIs) in a kitchen setting. Our goal is to transform the cooking experience from traditional text-based recipe following to a dynamic, interactive process.

## Context
This project was developed as a final Bachelor Thesis Project for the Bachelor of Computer Science and received a final cumulative grade of 9.3, and a 9.85 for the presentation. The project was developed by Vera Prohaska under the supervision of Dr. Prof. Eduardo Castello Ferrer. 


## Abstract



## Components

| Component | Description | Code |
| --- | --- | --- |
| OptiTrack | Tracking system for the tangible objects | [OptiTrack](./components/optitrack_ros_client/) |
| Projection | Projecting the interface on the kitchen surface | [Projection](./components/udp_ros_to_gama_sender/) |
| Vision | User interface for the cooking process | [Interface](./vision/) |
| Audio | Audio feedback for the cooking process | [Audio](./audio/) |

## DataFlow Diagrams

### OptiTrack DataFlow
<img src="./static/images/optitrack_component.png" width="800">

### Vision DataFlow 
<img src="./static/images/vision_component.png" width="800">

## Getting Started
To get started with the SPICE project, follow these steps:
1. Fork [the repository](https://github.com/vtwoptwo/spice.git)
2. Clone the repository: `git clone https://github.com/vtwoptwo/spice.git`
3. Install the necessary dependencies for each component by following the instructions in their respective directories.


## License

This project is licensed under the GNU GPL License. See the [LICENSE](./LICENSE.gpl) file for details.

## Contact

For any questions or inquiries, please contact me at `vera dot prohaska at gmail dot com`.


