# Compositor FX Anim

Drive `WorldEnvironment` `CompositorEffect` properties from `AnimationPlayer`.

Godot cannot key nested `compositor.compositor_effects[i].property` paths, so this folder exposes flat floats on the `WorldEnvironment` that map to effect properties via `CompositorFxBinding` resources.

Lives under `addons/` for reuse across projects. Not an EditorPlugin — no enable step; attach the script or use the `CompositorFxAnim` / `CompositorFxBinding` class names.

## Usage

1. Attach `compositor_fx_anim.gd` to a `WorldEnvironment` (or instance a node with `class_name CompositorFxAnim`).
2. Add bindings: `anim_property` (track name), `effect_index`, `effect_property`.
3. Key `anim_property` on your `AnimationPlayer`.
