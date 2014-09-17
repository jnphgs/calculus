Graph[] graphs;
boolean controlling = false;
int control_mode = 0;

void setup() {
	size(900, 400);
	graphs = new Graph[3];

	for(int i = 0; i < 3; i++){
		graphs[i] = new Graph();
		graphs[i].setGraphArea(	new PVector(300*i+10, 10), new PVector(280, 280) );
		graphs[i].setMinMax(-5, -5, 23, 23);
	}

	graphs[0].addControlPoint(0.0, 0.0);
	graphs[0].addControlPoint(20.0, 5.0);

	graphs[1].addControlPoint(0.0, 0.0);
	graphs[1].addControlPoint(10.0, 0.0);
	graphs[1].addControlPoint(20.0, 0.0);

	graphs[2].addControlPoint(0.0, 0.0);
	graphs[2].addControlPoint(5.0, 0.0);
	graphs[2].addControlPoint(10.0, 0.0);
	graphs[2].addControlPoint(15.0, 0.0);

}

void draw() {
	update();
	background(255);

	for(int i = 0; i < 3; i++){
		graphs[i].drawOutline();
		graphs[i].drawAxis();
		graphs[i].drawGraph();
		graphs[i].drawControlPoints();
		graphs[i].drawLabel();
	}
	saveFrame();
}

void update(){
	for(int i = 0; i < 3; i++){
		graphs[i].updatePoint();
		graphs[i].updateCoefficients();
		switch (control_mode) {
			case 0:
			graphs[1].integral(graphs[0]);
			graphs[2].integral(graphs[1]);
			break;
			case 1:
			graphs[0].differential(graphs[1]);
			graphs[2].integral(graphs[1]);
			break;
			case 2:
			graphs[1].differential(graphs[2]);
			graphs[0].differential(graphs[1]);
			default:
			break;
		}
	}
}

void mousePressed(){
	for(int i = 0; i < 3; i++){
		if(graphs[i].onThisGraph(mouseX, mouseY)){
			if(graphs[i].onPoints(mouseX, mouseY)){
				controlling = true;
				control_mode = i;
			}
		}
	}
}

void mouseReleased(){
	if(controlling){
		controlling = false;
		for(int i = 0; i < 3; i++){
			graphs[i].releaseControl();
		}
	
	}
}

// -----------------------------for check gaussian elimination ---------------------------------
// Matrix4x4 mat;
// float[] x;
// float[] b;

// void setup() {
// 	size(900, 400);
// 	mat = new Matrix4x4();
// 	mat.a[0][0] = 1.0;	mat.a[0][1] = 2.0;	mat.a[0][2] = 4.0;	mat.a[0][3] = 0.0;
// 	mat.a[1][0] = 1.0;	mat.a[1][1] = 1.0;	mat.a[1][2] = 1.0;	mat.a[1][3] = 0.0;
// 	mat.a[2][0] = 1.0;	mat.a[2][1] = -1.0;	mat.a[2][2] = 1.0;	mat.a[2][3] = 0.0;
// 	mat.a[3][0] = 0.0;	mat.a[3][1] = 0.0;	mat.a[3][2] = 0.0;	mat.a[3][3] = 1.0;	

// 	x = new float[4];
// 	b = new float[4];
// 	b[0] = 21.0; b[1] = 7.0; b[2] = 3.0; b[3] = 0.0;

// 	Gauss(mat, x, b);

// 	println("x >>");
// 	for(int i = 0; i < 4; i++){
// 		println(x[i]);
// 	}

// 	float[] result = new float[4];
// 	result = mat.mult(x);
// 	println("check >>");
// 	for(int i = 0; i < 4; i++){
// 		println(result[i]);
// 	}
// }

// void draw() {
// 	background(255);
// }
