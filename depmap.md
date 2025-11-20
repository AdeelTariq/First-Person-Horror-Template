digraph FOLDER_DEPS {
  rankdir=LR;
  node [shape=box, fontsize=10];
  node [style=filled, fillcolor=black, fontcolor=white, color=black]
  edge [color=white, fontcolor=white, penwidth=2]
  "/game_pieces/amnesia_door" [label="/game_pieces/amnesia_door"];
  "/game_pieces/drawer" [label="/game_pieces/drawer"];
  "/game_pieces/interactable_door" [label="/game_pieces/interactable_door"];
  "/game_pieces/lockable_door" [label="/game_pieces/lockable_door"];
  "/game_pieces/pickable" [label="/game_pieces/pickable"];
  "/interaction_system" [label="/interaction_system"];
  "/game_pieces/lockable_door" -> "/interaction_system";
  "/game_pieces/amnesia_door" -> "/interaction_system";
  "/game_pieces/interactable_door" -> "/interaction_system";
  "/game_pieces/pickable" -> "/interaction_system";
  "/game_pieces/drawer" -> "/interaction_system";
}