class Matrix4x4{
	float[][] a = new float[4][4];

	Matrix4x4(){
		setIdentity();
	}

	void setIdentity(){
		a[0][0] = 1.0;	a[0][1] = 0.0;	a[0][2] = 0.0;	a[0][3] = 0.0;
		a[1][0] = 0.0;	a[1][1] = 1.0;	a[1][2] = 0.0;	a[1][3] = 0.0;
		a[2][0] = 0.0;	a[2][1] = 0.0;	a[2][2] = 1.0;	a[2][3] = 0.0;
		a[3][0] = 0.0;	a[3][1] = 0.0;	a[3][2] = 0.0;	a[3][3] = 1.0;	
	}

	void setScale(float x, float y, float z){
		setIdentity();
		a[0][0] = x;
		a[1][1] = y;
		a[2][2] = z;
	}

	void setTranslate(float x, float y, float z){
		setIdentity();
		a[0][3] = x;
		a[1][3] = y;
		a[2][3] = z;
	}

	void setRotateX(float theta){
		setIdentity();
		a[1][1] = cos(theta);	a[1][2] =  sin(theta);
		a[2][1] = -sin(theta);	a[2][2] =  cos(theta);	
	}
	void setRotateY(float theta){
		setIdentity();
		a[0][0] = cos(theta);	a[0][2] = -sin(theta);
		a[2][0] = sin(theta);	a[2][2] =  cos(theta);	
	}
	void setRotateZ(float theta){
		setIdentity();
		a[0][0] = cos(theta);	a[0][1] =  sin(theta);
		a[1][0] = -sin(theta);	a[1][1] =  cos(theta);	
	}


	// --- MATRIX CALCULATION ---
	// result.x 	a[0][0] a[0][1] a[0][2] a[0][3] 	input.x
	// result.y 	a[1][0] a[1][1] a[1][2] a[1][3] 	input.y
	// result.z  = 	a[2][0] a[2][1] a[2][2] a[2][3]  * 	input.z
	// result.w 	a[3][0] a[3][1] a[3][2] a[3][3]		input.w


	float[] mult(float[] p){
		float[] result = new float[4];
		result[0] = a[0][0]*p[0] + a[0][1]*p[1] + a[0][2]*p[2] + a[0][3]*p[3];
		result[1] = a[1][0]*p[0] + a[1][1]*p[1] + a[1][2]*p[2] + a[1][3]*p[3];
		result[2] = a[2][0]*p[0] + a[2][1]*p[1] + a[2][2]*p[2] + a[2][3]*p[3];
		result[3] = a[3][0]*p[0] + a[3][1]*p[1] + a[3][2]*p[2] + a[3][3]*p[3];
		return result;
	}

	Matrix4x4 mult(Matrix4x4 m){
		Matrix4x4 result = new Matrix4x4();
		for(int row = 0; row < 4; row++){
			for(int col = 0; col < 4; col++){
				result.a[row][col] = a[row][0]*m.a[0][col]
									+a[row][1]*m.a[1][col]
									+a[row][2]*m.a[2][col]
									+a[row][3]*m.a[3][col];
			}
		}
		return result;
	}

	String toString() {
        return String.format("%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f",
        a[0][0],a[0][1],a[0][2],a[0][3],a[1][0],a[1][1],a[1][2],a[1][3],a[2][0],a[2][1],a[2][2],a[2][3],a[3][0],a[3][1],a[3][2],a[3][3]);
    }
};

// --- Gaussian Elimination ---
//　evaluate x array
//
// A[0][0] A[0][1] A[0][2] A[0][3]		x[0]	=	B[0]
// A[1][0] A[1][1] A[1][2] A[1][3]		x[1]	=	B[1]
// A[2][0] A[2][1] A[2][2] A[2][3]	*	x[2]	=	B[2]
// A[3][0] A[3][1] A[3][2] A[3][3]		x[3]	=	B[3]

void Gauss(Matrix4x4 A, float[] x, float[] B){
	float[][] mat = new float[4][5];
	// copy value to mat
	for(int i = 0; i < 4; i++){
		for(int j = 0; j < 4; j++){
			mat[i][j] = A.a[i][j];
		}
		mat[i][4] = B[i];
	}


	// gaussian elimination
	for(int row = 0; row < 4; row++){
		
		float diagonal_element = mat[row][row];
		
		// divide this row element with this row's diagonal_element
		// left element of the diagonal_element is already eliminated
		// so loop is start from diagonal_element (and step to right)
		for(int col = row; col < 5; col++){
			mat[row][col] = mat[row][col]/diagonal_element;
		}

		// elimination
		for(int below = row+1; below < 4; below++){
			float elimination_target = mat[below][row];
			mat[below][row] = 0; // eliminated, means target -= target * 1
			// other element of this row, also subtracted
			for(int col = row+1; col < 5; col++){
				mat[below][col] -= elimination_target * mat[row][col];
			}
		}
	}
	// check
	// Matrix4x4 check = new Matrix4x4();
	// for(int i = 0; i < 4; i++){
	// 	for(int j = 0; j < 4; j++){
	// 		check.a[i][j] = mat[i][j];
	// 	}
	// }
	// println(check.toString());


	// evaluate x
	for(int row = 3; row >= 0; row--){
		x[row] = mat[row][4];
		for(int col = 3; col > row; col--){
			x[row] -= mat[row][col]*x[col];
		}
	}

}




