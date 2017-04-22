# Pooling vs. Creating
This example explores the difference between generating and deleting game objects using factory.create() and maintaining and using a pool of previously created but inactive game objects.

The example shows that there's only a marginal difference time and memory-wise. Do however note that there is a potential cost of having the game objects disabled but in a pool (since not all component types can be disabled).