class myPoint{
  float x, y;
  
  myPoint(float xInit, float yInit)
  {
    this.x = xInit;
    this.y = yInit;
    
  }
  
  void normalize(){
    float length = (float)Math.sqrt(x*x + y*y);
    if(length != 0){
      x /= length;
      y /= length;
    }
     
  }
}

class myTriangle{
  float x0, y0, x1, y1, x2, y2;
  int colorR, colorG, colorB;
  
  
  myTriangle(myPoint Point0, myPoint Point1, myPoint Point2){
    this.x0 = Point0.x;
    this.y0 = Point0.y;
    this.x1 = Point1.x;
    this.y1 = Point1.y;
    this.x2 = Point2.x;
    this.y2 = Point2.y;
    
    colorR = (int)(random(256));
    colorG = (int)(random(256));
    colorB = (int)(random(256));
  }
}

void createPolygon(meta_polygon MetaPolygon, int numOfPoints, int radius){
    MetaPolygon.Polygons.add(new polygon(MetaPolygon, numOfPoints, radius));
   
   
}

class myLine{
  float x1, y1, x2, y2;
  
  myLine(myPoint point1, myPoint point2){
    x1 = point1.x;
    y1 = point1.y;
    x2 = point2.x;
    y2 = point2.y;
    
  }
}

class meta_polygon{
  
  ArrayList<polygon> Polygons;
  int pointIndexAt;
  polygon RotatePolygon;
  float xPos, yPos;
  float roadY;
  
  float radiusAt;
  float rotateSpeed;
  int numOfPoints;
  
  int myLineCount;
  int myLineIndexPastMostRecent;
  myLine[] linesToStamp;
 
  void Init(int numOfPoints){
    Polygons.clear();
    myLineCount = 0;
    myLineIndexPastMostRecent = 0;
    this.numOfPoints = numOfPoints;
    createPolygon(this, numOfPoints, 20);
    createPolygon(this, numOfPoints, 40);
    createPolygon(this, numOfPoints, 60);
    RotatePolygon = Polygons.get(2);
    pointIndexAt = 0;
    float maxHeight = 0;
    
    radiusAt = 0;
    
  
    
    for(int i = 0; i < numOfPoints; ++i){
      myPoint Point = RotatePolygon.Points[i];
      
      if(Point.y > maxHeight){
        pointIndexAt = i;
        maxHeight = Point.y; 
      }
    }
    
    roadY = maxHeight;

  }
  
  meta_polygon(){
    
    Polygons = new ArrayList<polygon>();
    linesToStamp = new myLine[32];
    xPos = 100;
    yPos = 100;
    rotateSpeed = -1;
    Init(4);
    
    
    
    
    
    
    
    
    
  }
  
  void UpdateAndRender(){
    int pointIndex = pointIndexAt; 
    int nextIndex = wrap(pointIndexAt + (int)SignOf(rotateSpeed), numOfPoints);
    myPoint thisPoint = RotatePolygon.Points[pointIndexAt];
    myPoint nextPoint = RotatePolygon.Points[nextIndex];
    myPoint relPoint = new myPoint(nextPoint.x - thisPoint.x, nextPoint.y - thisPoint.y);
    
    boolean addLine = false;
    //turn shape
    if(Inner(relPoint, 0, 1) >= 0.0f){
      //if(relPoint.y >= 0.0f){
      pointIndexAt = nextIndex;
      thisPoint.y = roadY;
      nextPoint.y = roadY;
      addLine = true;

    }
    myPoint uprightRotatePoint = RotatePolygon.upRightPoints[pointIndexAt];
    myPoint worldRotatePoint = RotatePolygon.Points[pointIndexAt];
          
      radiusAt += rotateSpeed*dt;
      
      if(radiusAt > 2*PI){ radiusAt -= 2*PI; } 
      
      float xAxisX = cos(radiusAt);
      float xAxisY = sin(radiusAt);
      float yAxisX = -sin(radiusAt);
      float yAxisY = cos(radiusAt);
      
      //object space
       float transformX = -(uprightRotatePoint.x);
        float transformY = -(uprightRotatePoint.y); 

        // upright space
        float xPosAfter = (transformX * xAxisX) + (transformY * xAxisY);
        float yPosAfter = (transformX * yAxisX) + (transformY * yAxisY);
        
        // world space
        xPos = xPosAfter + worldRotatePoint.x;
        yPos = yPosAfter + worldRotatePoint.y;
      fill(0, 255, 255);
      stroke(192);
      
      ellipse(xPos, yPos, 5, 5);
    
    for(int i = 0; i < Polygons.size(); ++i){
          
          
          polygon Polygon = Polygons.get(i); 
          
          if(addLine){
            myPoint p1 = Polygon.Points[pointIndex];
            myPoint p2 = Polygon.Points[nextIndex];
            
            myLine stampLine = new myLine(p1, p2);
            linesToStamp[myLineIndexPastMostRecent++] = stampLine;
            myLineCount++;
            if(myLineCount > linesToStamp.length){
              myLineCount = linesToStamp.length;
            }
            
            myLineIndexPastMostRecent = wrap(myLineIndexPastMostRecent, linesToStamp.length);
          }
          Polygon.updateAndRender(dt, uprightRotatePoint, worldRotatePoint);
          float heightPos = roadY;
          line(0, heightPos, width, heightPos);
          
          

    }
    
    for(int i = 0; i < myLineCount; ++i){
      myLine LineToDraw = linesToStamp[i];
      stroke(255, 204, 204);
      line(LineToDraw.x1, LineToDraw.y1, LineToDraw.x2, LineToDraw.y2);
    }
    
  }
}

class polygon {
  int POINT_SIZE = 64;  
  int pointCount;
  myPoint Points[];
  
  float radius;

  meta_polygon parent;
  
  myPoint trailBuffer[];
  int trailCount;
  int onePastMostRecentIndex;
  
  myPoint upRightPoints[];
  
  polygon(meta_polygon parent, int numOfPoints, int radius){
    Points = new myPoint[POINT_SIZE];
    this.radius = radius;
    

    this.parent = parent;
    trailCount = 0;
    trailBuffer = new myPoint[32];
    onePastMostRecentIndex = 0;
    upRightPoints = new myPoint[numOfPoints];
    float FullCircle = 2*PI;
    
    for(int pointIndex = 0; pointIndex < numOfPoints; ++pointIndex){
        float angle = (FullCircle * ((float)pointIndex / (float)numOfPoints));
       
        int xOffset = (int)(radius*cos(angle));
        int yOffset = (int)(radius*sin(angle));
        
        upRightPoints[pointIndex] = new myPoint((xOffset), (yOffset));
        Points[pointCount++] = new myPoint(xOffset + parent.xPos, yOffset + parent.yPos); 
    }
    
    
    
  }
  
  void updateAndRender(float dt, myPoint rotatePoint, myPoint worldRotatePoint){
    

      if(parent.xPos > width){  parent.xPos = width - 1; parent.rotateSpeed *= -1;}
      if(parent.xPos < 0){  parent.xPos = 0; parent.rotateSpeed *= -1;}
     
      float xAxisX = cos(parent.radiusAt);
      float xAxisY = sin(parent.radiusAt);
      float yAxisX = -sin(parent.radiusAt);
      float yAxisY = cos(parent.radiusAt);

      
      for(int pointIndex = 0; pointIndex < parent.numOfPoints; ++pointIndex){

        myPoint upRightPoint = upRightPoints[pointIndex];
        myPoint Point = Points[pointIndex];
        
        
        float transformX = upRightPoint.x - (rotatePoint.x);
        float transformY = upRightPoint.y - (rotatePoint.y); // - parent.yPos
        
        
        Point.x = (transformX * xAxisX) + (transformY * xAxisY) + worldRotatePoint.x;
        Point.y = (transformX * yAxisX) + (transformY * yAxisY) + worldRotatePoint.y;
      }    
      
      for(int j = 0; j < pointCount; ++j){
        myPoint Point = Points[j];
        stroke(192);
        fill(192);
       
        if(j == parent.pointIndexAt){
            fill(0, 255, 255);
        }
        if(j == wrap(parent.pointIndexAt + 1, parent.numOfPoints))
        {
          fill(0, 255, 0);
        }
        ellipse(Point.x, Point.y, 5, 5);
        
        myPoint nextPoint = Points[wrap(j + 1, pointCount)];
        line(Point.x, Point.y, nextPoint.x, nextPoint.y);
      }
      
      trailBuffer[onePastMostRecentIndex++] = new myPoint(Points[parent.pointIndexAt].x, Points[parent.pointIndexAt].y);
      if(trailCount < trailBuffer.length){
        trailCount++;
      }
      
      
      onePastMostRecentIndex = wrap(onePastMostRecentIndex, trailBuffer.length);
        
      
          
      for(int j = 0; j < trailCount; ++j){
        myPoint Point = trailBuffer[j];
        ellipse(Point.x, Point.y, 2, 2);
      }
  }
  
}

boolean wasDown;
rect2 RestartButton;




class rect2 {
  float minX, minY, maxX, maxY;
  
  rect2(int x, int y, int width, int height){
    float halfWidth = 0.5f*width;
    float halfHeight = 0.5f*height;
    
    minX = x - halfWidth;
    minY = y - halfHeight;
    
    maxX = minX + width;
    maxY = minY + height;
  }
  
  float getWidth(){
    return maxX - minX;
  }
  
  float getHeight(){
    return maxY - minY;
  }
  
  boolean inBounds(int x, int y){
    boolean result = 
    (x >= minX && 
    y >= minY && 
    x < maxX && 
    y < maxY); 
    
    return result;
  }

}


int wrapValue(int value, int Count){
  if(value < 0){ value = Count - 1; }
  else if(value >= Count){ value = 0; }
  
  if(value < 0) value = 0;
  return value;
}

myPoint Perp(myPoint A){
  return new myPoint(A.y, -A.x);
}

float Inner(myPoint A, myPoint B){
  float result = (float)(A.x*B.x + A.y*B.y);
  return result;
}

float Inner(myPoint A, int B_x, int B_y){
  float result = (float)(A.x*B_x + A.y*B_y);
  return result;
}

int wrap(int value, int count){
  if(value >= count){
    value = 0;
  }
  else if(value < 0){
    value = count - 1;
  }
  
  else if(value < 0){ value = 0; }
  return value;
}
final static int FRAMES_PER_SECOND = 30;
meta_polygon MetaPolygon;
float dt = 1.0f / (float)FRAMES_PER_SECOND;
void setup() {
  size(480, 280);
  frameRate(FRAMES_PER_SECOND);
  
  
  RestartButton = new rect2(400, 100, 40, 40);
  wasDown = mousePressed;
  MetaPolygon = new meta_polygon();
  
     
  
}

float SignOf(float value){
  float result = (value >= 0.0f) ? 1.0f : -1.0f;
  return result;
}

boolean wasPressed(boolean WasDown, boolean IsDown){
  return !WasDown && IsDown;
}

void draw() {
  boolean isDown = mousePressed;
  boolean wasMousePressed = wasPressed(wasDown,isDown);
  background(255, 255, 255);
  
   if(wasMousePressed){
     int addend = 1;
     if(mouseButton == RIGHT){
       addend = -1;
     }
     
     int newIndex = MetaPolygon.numOfPoints + addend;
     if(newIndex <= 0) { newIndex = 1; }
     MetaPolygon.Init(newIndex);
   
     
   }

  
  MetaPolygon.UpdateAndRender();

  wasDown = isDown;
  
}