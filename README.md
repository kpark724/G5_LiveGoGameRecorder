#LIVE GO GAME RECORDER (LGGR)

#Description of the project
	The Live Go Game Recorder (LGGR) converts video frames of Go game into an SGF file on Xilinx Nexys video board. SGF file is widely used in online Go communities to keep record of the games. Therefore, main objective of the LGGR is to convert a physical Go game video into a SGF file for accurate reviewing of the game later.

#Requirements
	Vivado 2015.3
	Xilinx SDK 2015.3
	Xilinx Nexys Video board

#How to Use
   There are 2 projects attached to this repository:
      - HDMI                  <project dir>
      - SDTest                <project dir>

   The Java source codes in *HDMI* directory should be created as Java projects separately as shown later in Repository structure.
   These Java programs are needed to calibrate the board and to output a SGF file from *HDMI* project.

#Repository Structure
- G5_LiveGoGameRecorder <dir>
   - HDMI <project dir>
      -src <dir>
         - Overlay.java
         - PuttySGFWriter.java
   - SDTest <dir>
      -src <dir>
   - docs <dir> = contains all the documents to this project

#Authors
- Jesse Barcelos
- Fadime Dimmy Bekmambetova
- Chaehyun Kevin Park

#Acknowledgements
We would like to thank Professor Paul Chow for genuine interest in our project and teaching us how to properly design hardwares. We would also like to thank Charles Lo for giving us exceptional support and suggesting many ideas to make this project work. 
