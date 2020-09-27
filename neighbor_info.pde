class Neighbor_info {
  JSONObject json;
  JSONArray top_words;
  JSONArray points;
  JSONArray ae_size;
  JSONArray acm_size;
  int size;
  float max, min, ae_max, ae_min, acm_max, acm_min;
  StringList current_word = new StringList();

  Neighbor_info(JSONObject json_) {
    json = json_;
    top_words = json.getJSONArray("top_words");
    points = json.getJSONArray("points");
    acm_size = json.getJSONArray("acm_size");
    ae_size = scaleAE(json.getJSONArray("ae_size"));
    getMaxMin();
    size = points.size();
  }

  void figure() {
    current_word.clear();
    StringList display_words = new StringList();
    for (int i = 0; i < size; i++) {
      float x = ni.points.getJSONArray(i).getFloat(0)*5;
      float y = ni.points.getJSONArray(i).getFloat(1)*5;
      float z = ni.points.getJSONArray(i).getFloat(2)*5;
      fill(100);
      String alternative_text = "";
      for (int j = 0; j < size; j++) {
        float x_ = ni.points.getJSONArray(j).getFloat(0)*5;
        float y_ = ni.points.getJSONArray(j).getFloat(1)*5;
        float z_ = ni.points.getJSONArray(j).getFloat(2)*5;
        if ( x == x_ && y == y_ && z == z_ ) {
          alternative_text += "[ " + top_words.getString(j) + " ] \n";
        }
      }
      if (display_words.hasValue(alternative_text)) {
        alternative_text = " ";
      } else {
        display_words.append(alternative_text);
      }
      if (sq(mouseX-screenX(x, y, z))+sq(mouseY-screenY(x, y, z)) < 30) {
        current_word.append(top_words.getString(i));
        if (mousePressed) {
          caption =  "frequency relationship \n between colocated words";
          instructions = "click on each frequency line to view a particular word and right click to view the related articles. \n click on  the topic word to return ";
          neighbor_weights.setValue(false);
          unravel=true;
          count = i;
        }
        textAlign(LEFT);
        hint(DISABLE_DEPTH_TEST);
        cam.beginHUD();
        if (alternative_text.length() > 0) {
          text(alternative_text, mouseX+10, mouseY-10);
        } else {
          text("[ " + top_words.getString(i) + " ]", mouseX+10, mouseY-10);
        }
        hint(ENABLE_DEPTH_TEST);
        cam.endHUD();

        stroke(100);
        strokeWeight(1);
        line(x, y, z, wid, y, z);
        line(x, y, z, -wid, y, z);
        line(x, y, z, x, hei, z);
        line(x, y, z, x, -hei, z);
        line(x, y, z, x, y, dep);
        line(x, y, z, x, y, -dep);
      } else if (show_words.getBooleanValue()) {
        if (alternative_text.length() > 0) {
          text(alternative_text, x, y, z);
        } else {
          text("[ " + top_words.getString(i) + " ]", x, y, z);
        }
      }
      float ae_c = map(ae_size.getFloat(i), ae_min, ae_max, 0, 70);
      float acm_c = map(acm_size.getFloat(i), acm_min, acm_max, 0, 70);
      float bri = map(abs(acm_c-ae_c), 0, 70, 50, 100);
      stroke(180+ae_c-acm_c, 100, bri, 150);
      strokeWeight(map(ae_size.getFloat(i)+acm_size.getFloat(i), min, max, 20, 60));
      point(x, y, z);
      //pushMatrix();
      //noStroke();
      //translate(x, y, z);
      //fill(180+ae_c-acm_c, 100, bri, 150);
      //sphereDetail(10);
      //sphere(map(ae_size.getFloat(i)+acm_size.getFloat(i), min, max, 20, 60)*2);
      //popMatrix();
    }
  }
  void getMaxMin() {
    max = 0;
    ae_max = 0;
    acm_max = 0;
    min= acm_size.getFloat(0)+ae_size.getFloat(0);
    ae_min = ae_size.getFloat(0);
    acm_min = acm_size.getFloat(0);
    for (int i =0; i < top_words.size(); i++) {
      if (ae_size.getFloat(i)+ acm_size.getFloat(i)< min) {
        min = ae_size.getFloat(i)+ acm_size.getFloat(i);
      }
      if (ae_size.getFloat(i)+ acm_size.getFloat(i) > max) {
        max = ae_size.getFloat(i)+ acm_size.getFloat(i);
      }
      if (ae_size.getFloat(i) < ae_min) {
        ae_min = ae_size.getFloat(i);
      }
      if (ae_size.getFloat(i) > ae_max) {
        ae_max = ae_size.getFloat(i);
      }
      if (acm_size.getFloat(i) < acm_min) {
        acm_min = acm_size.getFloat(i);
      }
      if (acm_size.getFloat(i) > acm_max) {
        acm_max = acm_size.getFloat(i);
      }
    }
  }

  JSONArray scaleAE(JSONArray json) {
    JSONArray scaled_json = new JSONArray();
    for (int i =0; i < top_words.size(); i++) {
      scaled_json.setFloat(i, json.getFloat(i)*(acm_size.getFloat(acm_size.size()-1))/(json.getFloat(json.size()-1)));
    }
    return scaled_json;
  }
}