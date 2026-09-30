# Trainer taint fix

Branch: `fix-trainer-taint-pet`

Skillwright hooks every trainer window and calls protected `BuyTrainerService()`, which taints the shared `ClassTrainerFrame` and blocks Blizzard's Train button — including hunter pet training.

See `Core/Trainer.lua` on this branch.
