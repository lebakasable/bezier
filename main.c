#include <raylib.h>
#include <stdio.h>

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

int main(void) {
  InitWindow(800, 600, "Bézier");
  SetTargetFPS(60);

  float value = 0.5f;

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RED);
    GuiSlider((Rectangle){96, 48, 216, 16}, TextFormat("%0.2f", value), NULL,
              &value, 0.0f, 1.0f);
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
