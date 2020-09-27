ArrayList<Bob> bobs = new ArrayList();
Float complete_ae = 0.0;
Float complete_acm = 0.0;
void home() {
  fill(100);
  textSize(20);
  text("ACM", -width/3+20, -430);
  text("AE", width/2-20, -430);
  textSize(15);
  stroke(100);
  strokeWeight(1);
  line(-width/3, -420, -width/3+40, -420);
  line(width/2, -420, width/2-40, -420);
  for (int i = 1987; i < 2020; i++) {
    fill(100);
    textAlign(LEFT);
    text(i, -width/3, map(i, 1987, 2020, -400, 600), 0);
    textAlign(RIGHT);
    text(i, width/2, map(i, 1987, 2020, -400, 600), 0);
    textAlign(CENTER);
  }
  for (int i =0; i < 100; i++) {
    String keyword = home_table.getString(i, 0);
    bobs.get(i).setKeyword(keyword);
    float total_ae = home_table.getInt(i, 1);
    float total_acm = home_table.getInt(i, 2);
    ArrayList<Spring> springs_acm = new ArrayList();
    ArrayList<Spring> springs_ae = new ArrayList();
    boolean here = false;
    pushMatrix();
    for (int j = 1987; j < 2020; j++) {
      float current_ae = home_json.getJSONObject(keyword).getJSONObject("ae").getInt(str(j));
      float current_acm = home_json.getJSONObject(keyword).getJSONObject("acm").getInt(str(j));
      here = true;
      Spring spring_acm = new Spring(-width/3+50, map(j, 1987, 2020, -400, 600), 0, current_acm/complete_acm, current_acm/total_acm);
      springs_acm.add(spring_acm);
      spring_acm.connect(bobs.get(i));
      Spring spring_ae = new Spring(width/2-50, map(j, 1987, 2020, -400, 600), 0, current_ae/complete_ae, current_acm/total_ae);
      springs_ae.add(spring_ae);
      spring_ae.connect(bobs.get(i));
      bobs.get(i).update();
      if (i == home_count) {
        hint(DISABLE_DEPTH_TEST);
        cam.beginHUD();
        bobs.get(i).drag(mouseX, mouseY);
        cam.endHUD();
        hint(ENABLE_DEPTH_TEST);
      }
    }
    if (here) {
      boolean active;
      if (home_count == i) {
        active = true;
        translate(0, 0, 10);
      } else {
        active = false;
        translate(0, 0, -(i+2)*10);
      }

      for (int j = 0; j< 2020-1987; j++) {
        springs_ae.get(j).displayLine(bobs.get(i), color(250, 100, 100), active);
        springs_acm.get(j).displayLine(bobs.get(i), color(110, 100, 100), active);
      }
      if (active) {
        bobs.get(i).display(keyword.replace("_", " "), 255);
      } else {
        bobs.get(i).display(keyword.replace("_", " "), 50);
      }
    }
    popMatrix();
  }
}