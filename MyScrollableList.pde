public class MyScrollableList extends ScrollableList {
  MyScrollableList (ControlP5 controlp5, String name) {
    super(controlp5, name);
  }
}

void myScrollableList(int n) {
  Map<String, Object> item = myScrollableList.getItem(n);
  myScrollableList.setCaptionLabel(item.get("name").toString());
  for (Bob b : bobs) {
    b.position.x = 0;
    b.position.y = 0;
  }
  home_count = n;
  myScrollableList.onRelease(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      myScrollableList.setOpen(true);
    }
  }
  );
  myScrollableList.onDoublePress(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      file = myScrollableList.getItem(home_count).get("name").toString().replace(" ", "_");
      next = true;
      loadtables();
      cam.setDistance(2800);
      current_distance = 2800;
    }
  }
  );
}