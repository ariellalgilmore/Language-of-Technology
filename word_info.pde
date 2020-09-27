class Word_info {
  String word;
  int index;
  FloatList ae_years;
  FloatList acm_years;
  float ae_color;
  float acm_color;
  JSONObject neighbor_json = new JSONObject();
  float y_pos;
  FloatList dist_years = new FloatList();
  IntList json_years = new IntList();
  StringList selected_neighbors = new StringList();

  Word_info(String word_, int index_, FloatList ae_years_, FloatList acm_years_, JSONObject neighbor_json_) {
    word = word_;
    index = index_;
    y_pos = map(index, 0, top_words.size(), -1000, 1000);
    ae_years = ae_years_;
    acm_years = acm_years_;
    neighbor_json = neighbor_json_;
    dist_years = distYears(dist_years);
  }

  FloatList distYears(FloatList dist_years) {
    for (int i = 0; i < (2019-1986); i++) {
      dist_years.append(map(ae_years.get(i), ae_years.min(), ae_years.max()+1, 0, 500) + map(acm_years.get(i), acm_years.min(), acm_years.max()+1, 0, 500));
    }
    return dist_years;
  }

  JSONObject jsonOrg(JSONObject json) {
    for (String w : top_words) {
      if (!json.isNull(w)) {
        JSONObject years = new JSONObject();
        for (int i = 1987; i < 2020; i++) {
          if (!json.getJSONObject(w).isNull(str(i))) {
            if (json.getJSONObject(w).getJSONArray(str(i)).size() > 0) {
              years.setJSONArray(str(i), json.getJSONObject(w).getJSONArray(str(i)));
            }
          }
        }
        if (years.size() > 0 ) {
          json_years.append(years.size());
          json.setJSONObject(w, years);
        }
      }
    }
    return json;
  }

  void wordShape() {
    noFill();
    PShape s = createShape();
    PShape s2 = createShape();
    s.beginShape();
    s.curveVertex(cos(0*sections)*500, y_pos, sin(0*sections)*500);
    s2.beginShape();
    s2.curveVertex(-width, -1000, 0);
    for (int i = 0; i < (2019-1986); i++) {
      ae_color = map(ae_years.get(i), ae_years.min(), ae_years.max()+1, 0, 70);
      acm_color = map(acm_years.get(i), acm_years.min(), acm_years.max()+1, 0, 70);
      float bri = map(abs(acm_color-ae_color), 0, 70, 50, 100);
      float mapped_year = map(i, 0, 2019-1987, -width, width);
      s.curveVertex(cos(i*sections)*(500+dist_years.get(i)), y_pos, sin(i*sections)*(500+dist_years.get(i)));
      s2.curveVertex(mapped_year, -1000-dist_years.get(i)/1.5, 0);
      if (index == count) {
        s.stroke(180+ae_color-acm_color, 100, bri, 255);
        s.strokeWeight(7);
      } else {
        s.stroke(180+ae_color-acm_color, 100, bri, 50);
        s.strokeWeight(1);
      }
      s2.strokeWeight(4);
      if (acm_color == 0 && ae_color == 0) {
        s2.stroke(180+ae_color-acm_color, 100, bri, 10);
      } else {
        s2.stroke(180+ae_color-acm_color, 100, bri, 200);
      }
    }
    s2.curveVertex(width, -1000, 0);
    s2.endShape();
    s.curveVertex(cos(33*sections)*500, y_pos, sin(33*sections)*500);
    s.endShape(CLOSE);
    if (!unravel) {
      for (float i=1; i > 0; i-=.01) {
        pushMatrix();
        rotateY(rotations);
        scale(i, 1, i);
        shape(s);
        popMatrix();
      }
    } else {
      shape(s2);
    }
  }

  void dividerShape() {
    if (y_pos != -1000) {
      pushMatrix();
      rotateX(PI/2);
      translate(0, 0, -y_pos+30);
      strokeWeight(10);
      fill(100, 75);
      stroke(100, 75);
      ellipse(0, 0, 1000, 1000);
      popMatrix();
    }
  }

  void neighborConnections(JSONObject json) {
    float alpha = 150;
    for (String w : top_words) {
      if (!w.equals(word)) {
        if (selected_neighbors.size() == 0) {
          alpha = 150;
        } else if (selected_neighbors.hasValue(w)) {
          alpha = 255;
        } else {
          alpha = 20;
        }
        PShape s = createShape();
        s.beginShape();
        float x, y =0;
        for (int j =1987; j < 2020; j++) {
          x  = map(j, 1987, 2019, -width, width);
          for (int k = 0; k < json.getJSONArray(str(j)).size(); k++) {
            if (json.getJSONArray(str(j)).getJSONArray(k).getString(0).equals(w)) {
              y = map(k, 0, json.getJSONArray(str(j)).size(), -800, 1200);
              int ae = 0;
              int acm = 0;
              JSONArray db =json.getJSONArray(str(j)).getJSONArray(k).getJSONArray(1);
              for ( int l = 0; l < db.size(); l++) {
                if (db.getString(l).split("/")[0].equals("ae")) {
                  ae++;
                } else {
                  acm++;
                }
              }
              float ae_c = map(ae, 0, db.size()+1, 0, 70);
              float acm_c = map(acm, 0, db.size()+1, 0, 70);
              float bri = map(abs(acm_c-ae_c), 0, 70, 50, 100);
              if (j == 1987) {
                textAlign(RIGHT);
                text(w, -width-50, y);
                if (selected_neighbors.hasValue(w)) {
                  //stroke(50);
                  //strokeWeight(2);
                  text("[", -width-60-textWidth(w), y);
                  text("]", -width-30, y);
                }
              }
              if (j==2019) {
                textAlign(LEFT);
                text(w, width+50, y);
                if (selected_neighbors.hasValue(w)) {
                  //stroke(50);
                  //strokeWeight(2);
                  text("]", width+60+textWidth(w), y);
                  text("[", width+30, y);
                }
              }
              if (j == 1987 || j == 2019) {
                s.curveVertex(x, y, 0);
              }

              s.curveVertex(x, y, 0);
              if (acm_c == 0 && ae_c == 0) {
                if (alpha == 255) {
                  s.stroke(180+ae_c-acm_c, 100, bri, 75);
                } else {
                  s.stroke(180+ae_c-acm_c, 100, bri, 30);
                }
              } else {
                s.stroke(180+ae_c-acm_c, 100, bri, alpha);
              }
              //s.stroke(180+ae_c-acm_c, 100, bri, alpha);
              s.strokeWeight(json.getJSONArray(str(j)).getJSONArray(k).getJSONArray(1).size()+1);
              if (sq(mouseX-screenX(x, y, 0))+sq(mouseY-screenY(x, y, 0))<40) {
                if (selected_neighbors.hasValue(w)) {
                  textAlign(CENTER);
                  text(w, x, y, 5);
                }
                if (mousePressed) {
                  if (mouseButton == RIGHT) {
                    if ( acm > 0) {
                      link("https://dl.acm.org/action/doSearch?fillQuickSearch=false&expand=dl&field1=AllField&text1="+file+"+"+w+"+"+word+"&AfterYear="+j+"&BeforeYear="+j+"&sortBy=downloaded");
                    }
                  }
                  if (selected_neighbors.hasValue(w)) {
                    int index = selected_neighbors.index(w);
                    selected_neighbors.remove(index);
                  } else {
                    selected_neighbors.append(w);
                  }
                }
              }
            }
          }
        }
        s.endShape();
        shape(s);
      }
    }
  }

  void displayYears() {
    if ( abs(mouseX-(width/100+width/6)/2)<20 && abs(mouseY- height/3) < 20) {
      //myTextarea.setColor(200);
      text_alpha = 200;
      if (mousePressed) {
        unravel = false;
        caption =  "geometric representations \n of colocated words";
        instructions = "- Click on a word to learn more and use arrow keys to loop through the years";
        //descriptions.setText("Frequency shapes of colocated words. Click on a word to learn more.");
        //myTextarea.setColor(100);
        text_alpha = 100;
      }
    } else {
      //myTextarea.setColor(100);
      text_alpha = 100;
    }
    textSize(60);
    text("[ "+word+" ]", -width-60, -960);
    for (int i =1987; i < 2020; i ++) {
      pushMatrix();
      translate(map(i, 1987, 2019, -width, width), -920);
      rotateZ(PI/4);
      textAlign(CENTER);
      textSize(40);
      text(i, 0, 0);
      popMatrix();
    }
  }
}