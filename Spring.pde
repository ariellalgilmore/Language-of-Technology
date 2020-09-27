
class Spring { 

  // position
  PVector anchor;

  // Rest length and spring constant
  float len;
  float k = 0.2;
  float alpha;

  // Constructor
  Spring(float x, float y, float l, float k_, float alpha_) {
    anchor = new PVector(x, y);
    len = l;
    k = k_;
    alpha = alpha_;
  } 

  // Calculate spring force
  void connect(Bob b) {
    // Vector pointing from anchor to bob position
    PVector force = PVector.sub(b.position, anchor);
    // What is distance
    float d = force.mag();
    // Stretch is difference between current distance and rest length
    float stretch = d - len;

    // Calculate force according to Hooke's Law
    // F = k * stretch
    force.normalize();
    force.mult(-1 * k * stretch);
    b.applyForce(force);
  }

  // Constrain the distance between bob and anchor between min and max
  void constrainLength(Bob b, float minlen, float maxlen) {
    PVector dir = PVector.sub(b.position, anchor);
    float d = dir.mag();
    // Is it too short?
    if (d < minlen) {
      dir.normalize();
      dir.mult(minlen);
      // Reset position and stop from moving (not realistic physics)
      b.position = PVector.add(anchor, dir);
      b.velocity.mult(0);
      // Is it too long?
    } else if (d > maxlen) {
      dir.normalize();
      dir.mult(maxlen);
      // Reset position and stop from moving (not realistic physics)
      b.position = PVector.add(anchor, dir);
      b.velocity.mult(0);
    }
  }

  void display() { 
    stroke(0);
    fill(175);
    strokeWeight(2);
    rectMode(CENTER);
    rect(anchor.x, anchor.y, 10, 10);
  }

  void displayLine(Bob b, color c, boolean active) {
    if (k == 0) {
      strokeWeight(0);
    } else {
      strokeWeight(2);
    }
    if (active) {
      if (c == color(110, 100, 100)) {
        stroke(c, map(alpha, 0, .1, 0, 255));
      } else {
        stroke(c, map(alpha, 0, 1, 0, 255));
      }
    } else {
      stroke(c, 10);
    }
    noFill();
    beginShape();
    curveVertex(anchor.x, anchor.y);
    curveVertex(anchor.x, anchor.y);
    float diff_x = abs(anchor.x-b.position.x)/b.random_x;
    float diff_y = abs(anchor.y-b.position.y)/b.random_y;
    if (c == color(250, 100, 100)) {
      if (anchor.y < b.position.y) {
        curveVertex(b.position.x+diff_x, b.position.y-diff_y);
      } else {
        curveVertex(b.position.x+diff_x, b.position.y+diff_y);
      }
      curveVertex(b.position.x, b.position.y);
      curveVertex(b.position.x, b.position.y);
    } else {
      if (anchor.y < b.position.y) {
        curveVertex(b.position.x-diff_x, b.position.y-diff_y);
      } else {
        curveVertex(b.position.x-diff_x, b.position.y+diff_y);
      }
      curveVertex(b.position.x, b.position.y);
      curveVertex(b.position.x, b.position.y);
    }
    endShape();
  }
}