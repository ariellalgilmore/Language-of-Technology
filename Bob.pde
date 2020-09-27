class Bob { 
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass =24;

  float damping = .99;

  // For mouse interaction
  PVector dragOffset;
  boolean dragging = false;
  float random_x;
  float random_y;
  String keyword;

  // Constructor
  Bob(float x, float y, float random_x_, float random_y_) {
    position = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    dragOffset = new PVector();
    random_x = random_x_;
    random_y = random_y_;
  } 
  void setKeyword(String keyword_) {
    keyword = keyword_;
  }

  // Standard Euler integration
  void update() { 
    velocity.add(acceleration);
    velocity.mult(damping);
    position.add(velocity);
    acceleration.mult(0);
  }

  // Newton's law: F = M * A
  void applyForce(PVector force) {
    PVector f = force.get();
    f.div(mass);
    acceleration.add(f);
  }


  // Draw the bob
  void display(String text, float alpha) { 
    pushMatrix();
    translate(0,0,3);
    rectMode(CENTER);
    fill(315);
    noStroke();
    rect(position.x,position.y,textWidth(text)+25, 20);
    fill(100, alpha);
    textSize(15);
    textAlign(CENTER);
    text("[ " + text+ " ]", position.x, position.y+5, 3);
    popMatrix();
  } 

  // The methods below are for mouse interaction

  // This checks to see if we clicked on the mover
  void clicked(float mx, float my) {
    println("CLICKED");
    float d = dist(mx, my, position.x, position.y);
    println(d, mass);
    //if (d < mass) {
    dragging = true;
    dragOffset.x = position.x-mx;
    dragOffset.y = position.y-my;
    //}
  }

  void stopDragging() {
    dragging = false;
  }

  void drag(float mx, float my) {
    if (dragging) {
      position.x = mx + dragOffset.x;
      position.y = my + dragOffset.y;
    }
  }
}