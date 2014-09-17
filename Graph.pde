class Graph{
	// Function's variable
	ArrayList<PVector> points; // local point position
	Matrix4x4 x_values;
	float[] coefficients;
	// cubic function
	// points(0).x^0	points(0).x^1	points(0).x^2	points(0).x^3		coefficients[0] 		points(0).y
	// points(1).x^0	points(1).x^1	points(1).x^2	points(1).x^3		coefficients[1] 		points(1).y
	// points(2).x^0	points(2).x^1	points(2).x^2	points(2).x^3	*	coefficients[2] 	=	points(2).y
	// points(3).x^0	points(3).x^1	points(3).x^2	points(3).x^3		coefficients[3] 		points(3).y
	// result function >> y = coef[3]*x^3 + coef[2]*x^2 + coef[1]*x^1 + coef[0]

	// quadratic function
	// points(0).x^0	points(0).x^1 	points(0).x^2				0		coefficients[0] 		points(0).y
	// points(1).x^0	points(1).x^1 	points(1).x^2				0		coefficients[1] 		points(1).y
	// points(2).x^0	points(2).x^1 	points(2).x^2				0	*	coefficients[2] 	=	points(2).y
	// 			   0 				0				0				1		coefficients[3] 				  0
	// result function >> y = coef[2]*x^2 + coef[1]*x^1 + coef[0]

	// Graph variables
	PVector area; // drawing area size
	PVector pos; //  graph's left-top global position
	PVector zero; // local position of zero
	float min_x, min_y, max_x, max_y; // min and max value of graph area's x, y

	// control variables
	int selected;
	boolean controlling;

	Graph(){
		points = new ArrayList<PVector>();
		x_values = new Matrix4x4();
		coefficients = new float[4];

		selected = -1;
		controlling = false;
	}

	void setGraphArea(PVector _pos, PVector _area){
		pos = _pos;
		area = _area;
	}

	void setMinMax(float _min_x, float _min_y, float _max_x, float _max_y){
		min_x = _min_x;
		min_y = _min_y;
		max_x = _max_x;
		max_y = _max_y;

		float local_zero_x = area.x*(0 - min_x)/(max_x - min_x);
		float local_zero_y = area.y*(0 - min_y)/(max_y - min_y);
		zero = new PVector(local_zero_x, local_zero_y);
	}

	// *********** COORDINATE CONVERTER ************ 
	// screen >> local >> graph  
	// local coordinate means that (0, 0) is graph area's bottom-left
	PVector screen_to_local(PVector global){
		PVector local = new PVector();
		local.x =  global.x - pos.x;
		local.y = -global.y + pos.y + area.y;
		return local;
	}

	// graph coordinate means min=bottom-left to max=top-right on graph area
	PVector local_to_graph(PVector local){
		PVector graph = new PVector();
		graph.x = (local.x*(max_x-min_x))/area.x + min_x;
		graph.y = (local.y*(max_y-min_y))/area.y + min_y;
		return graph;
	}

	float x_local_to_graph(float local_x){
		return (max_x-min_x)*(local_x-zero.x)/area.x;
	}

	PVector screen_to_graph(PVector global){
		return local_to_graph(screen_to_local(global));
	}

	// *********** COORDINATE CONVERTER ************ 
	// screen << local << graph
	PVector graph_to_local(PVector graph){
		PVector local = new PVector();
		local.x = area.x*(graph.x-min_x)/(max_x-min_x);
		local.y = area.y*(graph.y-min_y)/(max_y-min_y);
		return local;
	}

	PVector local_to_screen(PVector local){
		PVector global = new PVector();
		global.x = local.x + pos.x;
		global.y = -local.y + pos.y + area.y;
		return global;
	}

	PVector graph_to_screen(PVector graph){
		return local_to_screen(graph_to_local(graph));
	}


	// return f(x), x is graph coordinate
	float f(float x){
		float result = 0;
		for(int i = 0; i < points.size(); i++){
			result += coefficients[i]*pow(x, i);
		}
		return result;
	}

	void differential(Graph I){
		coefficients[0] = I.coefficients[1];
		coefficients[1] = I.coefficients[2]*2;
		coefficients[2] = I.coefficients[3]*3;
		for(int i = 0; i < points.size(); i++){
			points.set(i, new PVector(points.get(i).x, f(points.get(i).x)));
		}
	}

	void integral(Graph D){
		coefficients[1] = D.coefficients[0];
		coefficients[2] = D.coefficients[1]/2;
		coefficients[3] = D.coefficients[2]/3;

		// detect coefficients[0] from p0
		PVector p0 = (PVector)points.get(0);
		coefficients[0] = p0.y;
		for(int i = 1; i < points.size(); i++){
			coefficients[0] -= coefficients[i] * pow(p0.x, i);
		}

		for(int i = 0; i < points.size(); i++){
			points.set(i, new PVector(points.get(i).x, f(points.get(i).x)));
		}
	}

	boolean onThisGraph(float x, float y){
		if((pos.x < x && x < pos.x+area.x)&&(pos.y < y && y < pos.y+area.y)) return true;
		else return false;
	}

	void updatePoint(){
		if(controlling && selected >= 0){
			points.set(selected, screen_to_graph(new PVector(mouseX, mouseY)));
		}
	}

	void updateCoefficients(){
		x_values.setIdentity();
		float[] y_values = new float[4];
		for(int i = 0; i < points.size(); i++){
			PVector p = (PVector)points.get(i);
			for(int j = 0; j < points.size(); j++){
				x_values.a[i][j] = pow(p.x, j);
			}
			y_values[i] = p.y;
		}

		Gauss(x_values, coefficients, y_values);
	}

	void addControlPoint(float x, float y){
		if(points.size() < 4){
			points.add(new PVector(x, y));
		}
	}

	void drawOutline(){
		noFill();
		rect(pos.x, pos.y, area.x, area.y);
	}

	void drawAxis(){
		PVector global_zero = graph_to_screen(new PVector(0.0, 0.0));
		strokeWeight(0.5);
		for(int x = 0; x < area.x; x+=10){
			PVector x_point = local_to_screen(new PVector(x, x));
			if(local_to_graph(new PVector(x, 0.0)).x % 5 == 0) stroke(0);
			else	stroke(210);
			line(pos.x, x_point.y, pos.x+area.x, x_point.y);
			line(x_point.x, pos.y, x_point.x, pos.y+area.y);
		}
		
		stroke(0);
		strokeWeight(1.0);
		line(pos.x, global_zero.y, pos.x+area.x, global_zero.y);
		line(global_zero.x, pos.y, global_zero.x, pos.y+area.y);
	}

	void drawGraph(){
		PVector p1 = new PVector();
		PVector p2 = new PVector();
		stroke(0);
		for(float x = 0; x < area.x; x++){
			p1.x = x_local_to_graph(x);
			p1.y = f(p1.x);
			p2.x = x_local_to_graph(x+1);
			p2.y = f(p2.x);

			if(p1.y < min_y) continue; // out of outline
			if(p1.y > max_y) continue; // out of outline
			if(p2.y < min_y) continue; // out of outline
			if(p2.y > max_y) continue; // out of outline

			p1 = graph_to_screen(p1);
			p2 = graph_to_screen(p2);

			line(p1.x, p1.y, p2.x, p2.y);
		}
		for(int x = 0; x < area.x; x+=10){
			p1.x = x_local_to_graph(x);
			p1.y = f(p1.x);
			p2.x = x_local_to_graph(x+10);
			p2.y = f(p2.x);
			p1 = graph_to_screen(p1);
			p2 = graph_to_screen(p2);
			PVector p0 = graph_to_screen(new PVector(0, 0));
			PVector min_point = graph_to_screen(new PVector(min_x, min_y));
			PVector max_point = graph_to_screen(new PVector(max_x, max_y));
			if(p0.y-max(p1.y-p2.y, 0.0) < max_point.y) continue; // out of outline
			if(p0.y-max(p1.y-p2.y, 0.0) > min_point.y) continue; // out of outline
			if(p0.y-max(p1.y-p2.y, 0.0)+abs(p2.y-p1.y) < max_point.y) continue; // out of outline
			if(p0.y-max(p1.y-p2.y, 0.0)+abs(p2.y-p1.y) > min_point.y) continue; // out of outline
			//rect(p1.x, min(p1.y, p2.y), abs(p2.x-p1.x), abs(p2.y-p1.y));
			fill(210, 50);
			rect(p1.x, p0.y-max(p1.y-p2.y, 0.0), abs(p2.x-p1.x), abs(p2.y-p1.y));
		}
	}

	void drawControlPoints(){
		for(int i = 0; i < points.size(); i++){
			PVector p = graph_to_screen((PVector)points.get(i));
			if(onThisGraph(p.x, p.y)){
				ellipse(p.x, p.y, 3, 3);	
			}
		}
	}

	void drawLabel(){
		fill(0);
		String str = "d = ";
		str += coefficients[0];
		str += "\nc = ";
		str += coefficients[1];
		str += "\nb = ";
		str += coefficients[2];
		str += "\na = ";
		str += coefficients[3];

		text(str, pos.x+8, pos.y+area.y+12);
	}

	boolean onPoints(float x, float y){
		for(int i = 0; i < points.size(); i++){
			if(points.get(i).dist(screen_to_graph(new PVector(x, y))) < 1.0){
				selected = i;
				controlling = true;
			}
		}
		return controlling;
	}
	void releaseControl(){
		controlling = false;
		selected = -1;
	}
};