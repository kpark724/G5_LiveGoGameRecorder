#LIVE GO GAME RECORDER (LGGR)

#Description of the project
	The Live Go Game Recorder (LGGR) converts video frames of Go game into an SGF file on Xilinx Nexys video board. SGF file is widely used in online Go communities to keep record of the games. Therefore, main objective of the LGGR is to convert a physical Go game video into a SGF file for accurate reviewing of the game later.

#Requirements
	Vivado 2015.3
	Xilinx SDK 2015.3
	Xilinx Nexys Video board
   CGoban3
   Netbeans

#How to Use
   There are 2 projects attached to this repository:
      - HDMI                  <project dir>
      - SDTest                <project dir>

   The Java source codes in *HDMI* directory should be created as Java projects separately as shown later in Repository structure.
   These Java programs are needed to calibrate the board and to output a SGF file from *HDMI* project.

   1. Open hdmi > proj > hdmi.xpr
      - The bitstream should already be generated.
   2. Launch SDK from Vivado 2015.3
   3. Program FPGA
   4. Run Overlay Java program
   5. Fit the gridlines of the physical Go board to the Overlay Java program
      - You may need to disconnect and connect the HDMI cable several times to see the output of the hdmi project on computer monitor
   6. Run Configuration on SDK
   7. Press 9 to initialize the StoneDetect IP
   8. Press c when hand is not in the way of the board to detect moves.
   9. Press m when done and print the sequence of the moves
   10. Run PuttySGFWriter and copy and paste into temp.txt in the same directory as PuttySGFWriter.java
   11. Open SGF file named "Test.sgf" to see the record of the game


#Repository Structure
- G5_LiveGoGameRecorder <dir>
   - HDMI <project dir> = converts video frame of physical Go board into sequences of moves
      -src <dir>
         - Overlay.java
         - PuttySGFWriter.java
         - proj <dir> = stores the hdmi vivado project
            - hdmi.xpr = vivado project file
            - hdmi.sdk <dir> = stores the MicroBlaze code and board support package for running hdmi project
               - videodemo <dir> = stores the MicroBlaze C code
         - constraints <dir> = stores the constraints file

      - ip_repo <dir> = contains the custom IP: GoStoneDetect IP

   - SDTest <dir> = writes SGF file on microSD card
      -src <dir> = stores all sources
         - SDTest.srcs <dir> = stores the constraints file
         - SDTest.sim <dir> = stores the simulation
         - SDTest.sdk / FileSystemDev / src <dir> = stores the MicroBlaze code for reading and writing from microSD card
   - docs <dir> = contains all the documents to this project

#Authors
- Jesse Barcelos
- Fadime Dimmy Bekmambetova
- Chaehyun Kevin Park

#Acknowledgements
We would like to thank Professor Paul Chow for genuine interest in our project and teaching us how to properly design hardwares. We would also like to thank Charles Lo for giving us exceptional support and suggesting many ideas to make this project work. 
