#include <raylib.h>
#include <stdio.h>

int main(void) {
  InitWindow(800, 600, "Bézier");
  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RED);
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
