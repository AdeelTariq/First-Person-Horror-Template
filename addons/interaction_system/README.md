A node based interaction system for Godot.

You can write your own InteractionControllers which control how you detect an interactables in the game world.
An InteractionController will usually be attached to the player but can also be attached to NPCs to let them do stuff.
I have included examples of two InteractionControllers, one for 2D and other for 3D.

Each interactable must have exacly one InteractionContainer, as a child of the Node detectable by the InteractionController.
For example, a collidable 3D node for a RayCast3D.
From here the editor will show you what to do via warnings in the node tree.

An InteractionContainer can have a mix of multiple Interactions or InteractionContexts.

InteractionContexts can be turned on or off depending on the context.

For example a door may have the following setup:
```
InteractionContainer
│
├── Inspect (Interaction)
│
├── Closed (InteractionContext)
│   ├── Open (Interaction)
│   └── Lock (Interaction)
│
├── Open (InteractionContext)
│   └── Close (Interaction)
│
└── Locked (InteractionContext)
	└── Unlock (Interaction)
```

As you can see each context will have different interactions. While the Inspect interaction will always be present.
Multiple contexts can be turned on at the same time too, by giving them the same context ID.
