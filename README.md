CS4732 Spider Coaster! 
=====================

Simpler roller coaster, programmed in Dart, using three.dart, and rendering for WebGL.

Live demo: http://users.wpi.edu/~nican/coaster/
Project source: https://github.com/Nican/cs4732-roller-coaster

Building:
* Download the Dart editor at: http://www.dartlang.org/tools/
* Download, and import, the source for this project.
* Run! :D

Commands:
* In the rider
	* T = Toggles between First person/Chase Camera/Free Camera (WASDQE and mouse look, right mouse forward, left mouse backward)
* In the editor
	* Click on a cube face to move the cube in the direction of the face normal.
	* While dragging a cube, press D, to duplicate the cube.
	* While dragging a cube, press delete, to delete the cube.

Herique Polido:
* Coaster spline calculation
* Rail mesh creation
* Rail editor
* Chase Camera
* Part of coaster rider 
* Fixed numerous bugs in the Three.dart library

Andrew Feeney: 
* Cart Controller
	* Energy based velocity
	* Force calculations
* SparkParticleHandler
* SparkParticle
* Third Person camera in CoasterRider
* Spark Particle System handling in CoasterRider

