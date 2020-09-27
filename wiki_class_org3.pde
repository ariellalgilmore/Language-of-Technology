import peasy.*;
import controlP5.*;
import java.util.*;

ArrayList<PVector> r = new ArrayList();

PeasyCam cam;
ControlP5 cp5;
PFont font, control_font, backButton_font;

Table table, home_table;
StringList top_words = new StringList();
ArrayList<Word_info> words = new ArrayList<Word_info>();

JSONObject json, home_json;
JSONObject json_weights;

float sections = 2*PI/(2020-1987);
int count = 0;
int home_count = 0;

float rotations = 0;
//boolean toggle = false;
boolean ae_connections = false;
boolean acm_connections = false;
int current_year = 1987;
int front_year = 1995;
String file = "";
float first_color, second_color;
float max_x, max_y, max_z, wid, hei, dep;
Neighbor_info ni;
boolean next = false;
boolean unravel = false;

Textarea myTextarea, descriptions;
String caption, instructions;
Toggle neighbor_weights, show_words;
Button backButton;
MyScrollableList myScrollableList = null;
int text_alpha = 100;
int current_distance = 1000;

void setup() {
  cam = new PeasyCam(this, 1000);
  cam.setMaximumDistance(4000);
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  smooth(8);
  fullScreen(P3D, 2);

  colorMode(HSB, 360, 100, 100, 255);
  //font = createFont("Univers-light-normal.ttf",16, true);
  //control_font = createFont("Univers-light-normal.ttf",9, true);
  font = createFont("Arial", 16, true);
  control_font = createFont("Arial", 8, true);
  backButton_font = createFont("Arial", 12, true);
  textFont(font);


  home_table = loadTable("final.csv", "header");
  home_json = loadJSONObject("final_and_years.json");

  neighbor_weights = cp5.addToggle("neighbor_weights")
    .setPosition(width/100, height/10+35)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setColorLabel(color(0, 0, 0))
    .setLabel("Switch Mode").align(CENTER, 0, CENTER, cp5.BOTTOM_OUTSIDE)
    .setFont(control_font)
    .setColorBackground(color(315))
    .setColorActive(color(255));
  ;
  show_words = cp5.addToggle("show_words")
    .setPosition(width/100, height/10+35+40)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setColorLabel(color(0, 0, 0))
    .setLabel("Display Words").align(CENTER, 0, CENTER, cp5.BOTTOM_OUTSIDE)
    .setFont(control_font)
    .setColorBackground(color(315))
    .setColorActive(color(255));
  ;

  myScrollableList= new MyScrollableList(cp5, "myScrollableList");
  myScrollableList
    .setPosition(10, 100)
    .setSize(width/7, height-110) 
    .setItemHeight(30)
    .setBarHeight(30)
    .setFont(control_font)
    .setColorCaptionLabel(color(0))
    .setColorValueLabel(color(0))
    .setColorBackground(color(315))
    .setColorActive(color(255))
    .setColorForeground(color(255))
    .setCaptionLabel("Topic Words")
    .getCaptionLabel().toUpperCase(true)
    ;

  myTextarea = cp5.addTextarea("topic_word")
    .setPosition(70, height/3)
    .setSize(300, 200)
    .setFont(font)
    .setLineHeight(20)
    .setColor(100)
    .setWidth(200)
    ;
  descriptions = cp5.addTextarea("description")
    .setPosition(40, 3*height/5)
    .setSize(190, 200)
    //.setFont()
    .setLineHeight(20)
    .setColor(100)
    .setWidth(190)
    //.setText("Frequency shapes of colocated words. Click on a word to learn more.")
    ;
  backButton = cp5.addButton("button")
    .setValue(0)
    .setPosition(width/100, height/10-25)
    .setSize(20, 20)
    .setLabel("<")
    .setFont(backButton_font)
    .setColorBackground(color(255))
    .setColorLabel(color(360))
    .setColorForeground(color(270))
    .setColorActive(color(270))
    ;
  for (int i = 0; i < 100; i++) {
    bobs.add(new Bob(0, 0, random(2, 8), random(2, 8)));
  }
  for (int i =0; i < 100; i++) {
    myScrollableList.addItem(home_table.getString(i, 0), i);
    complete_ae += home_table.getInt(i, 1);
    complete_acm += home_table.getInt(i, 2);
  }
  for (int i = 0; i < 100; i++ ) {
    r.add(new PVector(random(-500, 500), random(-500, 500), random (-100, 100)));
  }
}

void draw() {
  background(315);
  if (cp5.getWindow(this).isMouseOver()) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
  if (!next) {
    gui_home();
    home();
  } else {
    gui();
    if (!neighbor_weights.getBooleanValue()) {
      textAlign(RIGHT);
      textSize(80);
      fill(100);
      //text("[ "+file.replace("_", " ")+" ]", -width-58, -1200);
      textSize(30);
      if (front_year > 2019) {
        front_year = 1987;
      }
      if (front_year < 1987) {
        front_year = 2019;
      }
      if (!unravel) {
        //textAlign(CENTER);
        //text(front_year, 0, 1050, 600);
        //text("|", 0, 1020, 600);
        pushMatrix();
        translate(width/3, map(top_words.size()+1, 0, top_words.size(), -1000, 1000));
        rotateX(PI/2);
        noFill();
        stroke(0, 50);
        strokeWeight(1);
        //arc(0, 0, 2000, 2000, 0, PI, OPEN);
        fill(0);
        rotateX(-PI/2);
        translate(0, 0, -100);
        textAlign(CENTER);
        PShape s = createShape();
        s.beginShape();
        s.noFill();
        s.stroke(0, 50);
        s.strokeWeight(1);
        s.curveVertex(cos(0*sections)*1000, 0, sin(0*sections)*1000);
        s.curveVertex(cos(0*sections)*1000, 0, sin(0*sections)*1000);
        for (int years = 0; years < 17; years ++) {
          if (current_year+years > 2019) {
            text(1986+(current_year+years-2019), cos(years*sections)*1000, 0, sin(years*sections)*1000);
            if ((1986+current_year+years-2019) % 2 == 0) {
              s.curveVertex(cos(years*sections)*1000, 0, sin(years*sections)*1000);
              line(cos(years*sections)*1000, 0, sin(years*sections)*1000, cos(years*sections)*1000, 2*map(-1, 0, top_words.size(), -1000, 1000), sin(years*sections)*1000);
            }
          } else {
            text(current_year+years, cos(years*sections)*1000, 0, sin(years*sections)*1000);            
            if ((current_year+years) % 2 == 0) {
              s.curveVertex(cos(years*sections)*1000, 0, sin(years*sections)*1000);
              line(cos(years*sections)*1000, 0, sin(years*sections)*1000, cos(years*sections)*1000, 2*map(-1, 0, top_words.size(), -1000, 1000), sin(years*sections)*1000);
            }
          }
        }
        s.curveVertex(cos(17*sections)*1000, 0, sin(17*sections)*1000);
        s.curveVertex(cos(17*sections)*1000, 0, sin(17*sections)*1000);
        s.endShape();
        shape(s);
        popMatrix();
      }
      for (Word_info w : words) {
        if (!neighbor_weights.getBooleanValue()) {
          if (!unravel) {
            pushMatrix();
            translate(width/3, 0);
            w.wordShape();
            popMatrix();
            pushMatrix();
            textSize(40);
            translate(-1050, w.y_pos);
            fill(100);
            textAlign(LEFT);
            if ( sq(mouseX-screenX(0, 0, 0))+sq(mouseY-screenY(0, 0, 0))<40) {
              if (mousePressed) {
                descriptions.setText("How colocated words are discussed together. Click on each line frequency to view a particular word.");
                caption = "frequency relationship \n between colocated words";
                instructions = "- Click on each frequency line and right click to view the related articles \n  Click on the topic word to return";
                unravel = true;
                count = w.index;
              } else {
                unravel = false;
                count = w.index;
                fill(150);
                text("[ " + w.word + " ]", 0, 0);
              }
            } else if (count == w.index) {
              fill(100);
              text("[ " + w.word + " ]", 0, 0);
            } else {
              fill(200, 150);
              text(w.word, 0, 0);
            }
            popMatrix();
          } else if (w.index == count) {
            pushMatrix();
            translate(width/4, 0);
            w.wordShape();
            w.displayYears();
            w.neighborConnections(w.neighbor_json);
            popMatrix();
          }
        }
      }
    }
    if (neighbor_weights.getBooleanValue()) {
      hint(DISABLE_DEPTH_TEST);
      cam.beginHUD();
      textAlign(LEFT);
      textSize(20);
      fill(100);
      //text("[ "+file.replace("_", " ")+" ]", 10, 80);
      hint(ENABLE_DEPTH_TEST);
      cam.endHUD();
      //for (Word_info w : words) {
      //  if (five.getBooleanValue()) {
      //    if (ni.current_word.hasValue(w.word)) {
      //      hint(DISABLE_DEPTH_TEST);
      //      cam.beginHUD();
      //      fill(100);
      //      textAlign(LEFT);
      //      textSize(15);
      //      text("[ " + w.word+ " ]", 10, map(w.y_pos, -1000, 1000, 100, 750));
      //      hint(ENABLE_DEPTH_TEST);
      //      cam.endHUD();
      //    } else {
      //      hint(DISABLE_DEPTH_TEST);
      //      cam.beginHUD();
      //      fill(100);
      //      textAlign(LEFT);
      //      textSize(15);
      //      text(w.word, 10, map(w.y_pos, -1000, 1000, 100, 750));
      //      hint(ENABLE_DEPTH_TEST);
      //      cam.endHUD();
      //    }
      //  }
      //}
      pushMatrix();
      translate(width/6+200, 0, 0);
      ni.figure();
      stroke(255);
      strokeWeight(1);
      noFill();
      box(wid*2, hei*2, dep*2);
      popMatrix();
    }
  }
}

void keyPressed() {
  if (keyCode == UP) {
    count--;
  }
  if (keyCode == DOWN) {
    count++;
  }
  if (keyCode == LEFT) {
    current_year++;
    front_year++;
    rotations+=sections;
  }
  if (keyCode == RIGHT) {
    current_year--;
    front_year--;
    rotations-=sections;
  }
  if (current_year < 1987) {
    current_year = 2019;
  }
  if (current_year > 2019) {
    current_year = 1987;
  }
  if (count == top_words.size()) {
    count = 0;
  }
  if (count == -1) {
    count = top_words.size()-1;
  }
  if (key == 'r') {
    println(current_distance);
    cam.setDistance(current_distance);
  }
}

void gui_home() {
  //one.hide();
  neighbor_weights.hide();
  backButton.hide();
  myTextarea.hide();
  descriptions.hide();
  show_words.hide();
  myScrollableList.show();
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  textAlign(LEFT);
  if (abs(mouseX-10) < 30 && abs(mouseY-20) < 40) {
    fill(200);
    text(" - Click to interact with topic \n words, double click on \n scrollbar to view topic, and \n press 'r' to reset cam", 40, 20);
  } else {
    fill(100);
  }
  textSize(16);
  text("[ ? ] ", 10, 20);
  stroke(255);
  strokeWeight(2);
  textAlign(CENTER);
  fill(100);
  textSize(30);
  text("Language of Technology", width/2+100, 50);
  textSize(16);
  text("a correlation study between Ars Electronica and ACM", width/2+100, 75);
  line(-width, 95, width, 95);
  line( (width/7+width/3)/3, 0, (width/7+width/3)/3, height);
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void gui() {

  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  fill(100);
  textSize(16);
  if (abs(mouseX-10) < 30 && abs(mouseY-20) < 40) {
    fill(200);
    text(instructions, 40, 20);
  } else {
    fill(100);
  }
  text("[ ? ] ", 10, 20);
  //one.hide();
  neighbor_weights.show();
  backButton.show();
  //myTextarea.show();
  //descriptions.show();
  myScrollableList.hide();
  if (neighbor_weights.getBooleanValue()) {
    show_words.show();
    rect(width/100+25, height/10+45+40, 50, 20);
  } else {
    show_words.hide();
  }
  ////stroke(0);
  //strokeWeight(1);
  noFill();
  rect(width/100+25, height/10+45, 50, 20);
  strokeWeight(1);
  setGradient(width/100+50, height-height/10, width/6-(width/6-200)/2-100, 30, 250, 110);
  textAlign(LEFT);
  fill(100);
  text("ACM", width/100, height-height/10+20);
  textAlign(RIGHT);
  text("AE", width/6-(width/6-200)/2, height-height/10+20);
  stroke(255);
  line(width/100+90, height/10+15, width/6, height/10+15);
  line(width/100+40, height/10+15-30, width/100+90, height/10+15-30);
  if (neighbor_weights.getBooleanValue()) {
    line(width/100+90, height/10+15-30, width/100+90, height/10+15+50);
    line(width/100+70, height/10+15+50, width/100+90, height/10+15+50);
  } else {
    line(width/100+90, height/10+15-30, width/100+90, height/10+15+30);
    line(width/100+70, height/10+15+30, width/100+90, height/10+15+30);
  }
  line(width/6, height/10+15, width/6, height/3+15);
  line(width/6, height/3+15, width/6-(width/6-200)/2, height/3+15);
  line(width/6-(width/6-200)/2, height/3+15-30, width/6-(width/6-200)/2-20, height/3+15-30);
  line(width/100+(width/6-200)/2+20, height/3+15-30, width/100+(width/6-200)/2, height/3+15-30);
  textAlign(CENTER);
  String temp = file.replace("_", " ");
  if (textWidth(temp) > 190) {
    int spaces = temp.length();
    temp = temp.replace(" ", "\n");
    spaces -= temp.replace("\n", "").length();
    line(width/6-(width/6-200)/2, height/3+15-30, width/6-(width/6-200)/2, height/3+15+30*spaces);
    line(width/100+(width/6-200)/2, height/3+15-30, width/100+(width/6-200)/2, height/3+15+30*spaces);
    line(width/100+(width/6-200)/2+20, height/3+15+30*spaces, width/100+(width/6-200)/2, height/3+15+30*spaces);
    line(width/6-(width/6-200)/2, height/3+15+30*spaces, width/6-(width/6-200)/2-20, height/3+15+30*spaces);
  } else {
    line(width/6-(width/6-200)/2, height/3+15-30, width/6-(width/6-200)/2, height/3+15+30);
    line(width/100+(width/6-200)/2, height/3+15-30, width/100+(width/6-200)/2, height/3+15+30);
    line(width/6-(width/6-200)/2, height/3+15+30, width/6-(width/6-200)/2-20, height/3+15+30);
    line(width/100+(width/6-200)/2+20, height/3+15+30, width/100+(width/6-200)/2, height/3+15+30);
  }
  fill(text_alpha);
  text(temp, (width/100+width/6)/2, height/3+15);
  line(width/100, height/3+15, width/100+(width/6-200)/2, height/3+15);
  line(width/100, height/3+15, width/100, 3*height/5);
  line(width/100, height/3+15, width/100, (3*height/5+4*height/6)/2);

  line(width/100, (3*height/5+4*height/6)/2, width/100+(width/6-230)/2, (3*height/5+4*height/6)/2);
  line(width/100+(width/6-230)/2, 3*height/5, width/100+(width/6-230)/2, 4*height/6);
  line(width/100+(width/6-230)/2+20, 3*height/5, width/100+(width/6-230)/2, 3*height/5);
  line(width/100+(width/6-230)/2+20, 4*height/6, width/100+(width/6-230)/2, 4*height/6);
  fill(100);
  text(caption, (width/100+width/6)/2, (3*height/5+4*height/6)/2-5);
  line(width/6-(width/6-230)/2-20, 3*height/5, width/6-(width/6-230)/2, 3*height/5);
  line(width/6-(width/6-230)/2-20, 4*height/6, width/6-(width/6-230)/2, 4*height/6);
  line(width/6-(width/6-230)/2, 3*height/5, width/6-(width/6-230)/2, 4*height/6);
  line(width/6, (3*height/5+4*height/6)/2, width/6-(width/6-230)/2, (3*height/5+4*height/6)/2);


  line(width/6, (3*height/5+4*height/6)/2, width/6, 9*height/10+15);
  line(width/6, 9*height/10+15, width/6-(width/6-200)/2+10, 9*height/10+15);
  line(width/6-(width/6-200)/2+10, 9*height/10+15-30, width/6-(width/6-200)/2+10, 9*height/10+15+30);
  line(width/6-(width/6-200)/2+10, 9*height/10+15-30, width/6-(width/6-200)/2-10, 9*height/10+15-30);
  line(width/6-(width/6-200)/2+10, 9*height/10+15+30, width/6-(width/6-200)/2-10, 9*height/10+15+30);
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void setGradient(int x, int y, float w, float h, int c2, int c1 ) {
  for (int i = x; i <= x+w; i++) {
    float inter = map(i, x, x+w, 0, 1);
    float hue = map(inter, 0, 1, c1, c2);
    float bri;

    if (hue > 179) {
      bri = map(hue, 250, 180, 100, 50);
    } else {
      bri = map(hue, 180, 110, 50, 100);
    }
    stroke(hue, 100, bri);
    line(i, y, i, y+h);
  }
}

void loadtables() {
  myTextarea.setText("[ " +file.replace("_", " ") + " ]");
  top_words.clear();
  words.clear();
  table = loadTable(file + "_neighbor_test.csv", "header");
  json = loadJSONObject(file + "_neighbor_to_neighbor.json");
  json_weights = loadJSONObject("final_neighbor_weights.json");
  wid = json_weights.getJSONObject("max-3d").getFloat("x")*5;
  hei = json_weights.getJSONObject("max-3d").getFloat("y")*5;
  dep = json_weights.getJSONObject("max-3d").getFloat("z")*5;
  ni = new Neighbor_info(json_weights.getJSONObject(file));

  for (int i = 0; i < table.getRowCount(); i++) {
    top_words.append(table.getString(i, 0));
  }

  for (int i = 0; i < table.getRowCount(); i++) {
    String word = table.getString(i, 0);
    FloatList ae_years = new FloatList();
    FloatList acm_years = new FloatList();
    for (int j = 0; j < (2019-1986); j++) {
      ae_years.append(float(table.getInt(i, str(1987+j)+" ae")));
      acm_years.append((float(table.getInt(i, str(1987+j)+" acm"))));
    }
    words.add(new Word_info(word, top_words.index(word), ae_years, acm_years, json.getJSONObject(word)));
  }
}
void button() {
  next= false;
  count = 0;
  unravel = false;
  //one.setValue(false);
  neighbor_weights.setValue(false);
  cam.reset();
}

void neighbor_weights(boolean theFlag) {
  if (next) {
    if (theFlag) {
      cam.setDistance(4000);
      current_distance = 4000;
      //descriptions.setText("The closer the words are in the space the more often they appeared together. Scroll over to see each word.");
      caption = "concurrence of words over \n time as a function of distance";
      instructions = "- Scroll over to see each word and click a point to learn more";
    } else {
      cam.setDistance(2800);
      current_distance = 2800;
    }
  }
}

//void show_words(boolean theFlag) {
//  if (theFlag) {

//  } else {
//  }
//}

void mousePressed() {
  if (unravel) {
    if (!neighbor_weights.getBooleanValue()) {
      //descriptions.setText("How colocated words are discussed together. Click on each line frequency to view a particular word.");
      caption = "frequency relationship \n between colocated words";
      instructions = "- Click on each frequency line and right click to view the related articles \n  Click on the topic word to return";
    }
  } else {
    if (!neighbor_weights.getBooleanValue()) {
      //descriptions.setText("Frequency shapes of colocated words. Click on a word to learn more.");
      caption = "geometric representations \n of colocated words";
      instructions = "- Click on a word to learn more and use arrow keys to loop through the years";
    }
  }
  if (!next) {
    for (int i =0; i < bobs.size(); i++) {
      if ((sq(mouseX-screenX(bobs.get(i).position.x, bobs.get(i).position.y, -(i+2)*10))+sq(mouseY-screenY(bobs.get(i).position.x, bobs.get(i).position.y, -(i+2)*10))<30)) {
        home_count = i;
        myScrollableList(i);
      }
    }
  }
}