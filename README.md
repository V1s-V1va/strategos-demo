## Strategos

### Status and scope
This repository currently contains the system code only (Python/Cython). It does not yet include build scripts, run scripts, tests, etc. This README is descriptive: it explains what the algorithm does and how this codebase is organized. Usage/build instructions, benchmarks, and full docs to be added as needed.

### Overview
Strategos trains a transformer model to estimate per‑action values (aka advantages) for heads‑up no‑limit Texas Hold'em. Instead of learning an explicit state‑action strategy table, the system approximates the game's value function with a transformer‑style model, then derives strategies from these estimated advantages in real time as it plays the game. This removes the need for lossy compression of state/action descriptions while still enabling improvement via iterative self‑play and advantage updates. The actual algorithm implemented by Strategos is a version of Single Deep Counterfactual Regret Minimization (SD‑CFR) with external sampling.

This process is done in two phases: first a self-play phase where the system plays through hands using its current strategy, records how hands resolve, and computes training targets for the neural net; then a training phase where the neural net's weights are updated with this newly-collected data. This constitutes one iteration of the algorithm - the process is then repeated, alternating which player's perspective we play from on each iteration.

### Algorithm loop
- Collection phase (DFS game-tree traversal & target calculation)
	- Traversal subphase (game trajectory collection)
		- Parallel workers explore the game tree with external sampling: at the point‑of‑view (POV) player's nodes, explore all actions; at opponent nodes, sample actions according to current strategy; at dealer nodes, deal with uniform randomness.
		- Each traversal plays a single hand to termination (one "traversal" == one simulated hand).
		- When terminal (i.e. endgame) nodes are reached, store their payoff and the game path leading to them; add terminal node & its payoff to each predecessor node's reachable endgame map.
	- Calculation subphase (target derivation)
		- For solvable subgames (subtrees where all nodes have had all their branches traversed), compute counterfactual reaches (probabilities of arriving at that node given all possible opponent hands) and forward reaches (probabilities of arriving at each reachable endgame) aligned to the recorded terminal sets.
		- Derive per‑action advantages at POV nodes from reach‑weighted payoffs (aka expected values); write resulting advantage samples to disk.
- Training phase (model learning)
	- Advantage samples from each collection worker are unified into a single training data pool, then split into training and validation sets and used to train the advantage network.*
			* Model training code exists under `strategos_tools/AIOps/`; the actual model architecture is intentionally left private, but is available on request.

### Repository structure (module‑level)
- `strategos_deuces/` — Cythonized derivative of Worldveil's Deuces library (MIT; [worldveil/deuces](https://github.com/worldveil/deuces)); used for the hand evaluator it contains.
- `strategos_tools/core/` — Core constants and shared containers used by other modules (`CONSTS.*`, `containers.*`, `PYCONSTS.py`).
- `strategos_tools/env/` — Texas Hold'em simulation environment, contains all game logic and entities needed for simulating hands:
	- `player_ops.*`: various simple operations related to player identification
	- `card_ops.*`: operations related to card/hand representation, interfaces with Deuces's hand evaluator
	- `event_ops.*`: player/dealer action representation
	- `gamenode_ops.*`: all operations related to tracking/querying/evolving game state
	- `infoset_ops.*`: implements concept of hidden information; an infoset is basically a game state as observed by a specific player
	- `actionset_ops.*`: operations related to deriving sets of available actions for a given game position
- `strategos_tools/utils/` — Various helpful numerical and data-management tools/operations (`funcs.*`, `data_structs.*`, `data_ops.*`).
- `strategos_tools/AIOps/` — All neural net code, including training loop logic and math for advantage estimation and strategy calculation (`EstimatorOps.*`, `nn_utils.py`, `training.py`).*
		* Note: Model architecture lives in `models.py` which is excluded from this public repo but available on request.
- `strategos_tools/CFR/` — CFR logic which conducts tree traversal and target calculation (`CollectionOps.*`).
- `scripts/` — TO BE ADDED. This will contain orchestration scripts for collection/monitoring/training, and form the algorithm's shell entry points.

### Reading guide (entry points)
If skimming the codebase to understand behavior, suggested reading order:
1. `strategos_tools/CFR/CollectionOps.pyx` — Highest-level logic, constitutes overall algorithm behaviour. Traversal orchestration, game trajectory recording, reach computation, and advantage derivation (`CFRCollector` and `GTNode`).
2. `strategos_tools/env/gamenode_ops.pyx` — How the game state is represented; state representation as action history + querying ops, state evolution via successor generation, and endgame payoff calculation logic.
3. `strategos_tools/env/infoset_ops.pyx` — Handling of poker's inherent imperfect information; how an objective game state subjectively looks to a given player, ultimately used by the estimator to produce action probabilities from state observations.
5. `strategos_tools/AIOps/EstimatorOps.pyx` — The actual math that translates state observations into advantage estimates.
6. `strategos_tools/utils/data_structs.pyx` — The data structures which store/batch/expose training samples for the model.
7. `strategos_deuces/evaluator.pyx` — Logic by which hands are scored for games that don't end in folds.

### CFR implementation specifics
- Variant: SD‑CFR with external sampling (single actions sampled at opponent and chance nodes; POV nodes fully explored).
- Advantages: action values computed via reach‑weighted terminal payoffs and counterfactual reaches; action advantages derived relative to node value and aggregated across iterations.
- Strategy extraction: action probabilities proportional to estimated advantages (via estimator outputs). Multi‑iteration estimators are accessible during traversal to form connection weights.

### Scope of this initial public repo
Included:
- All system logic implemented in Python/Cython, with the exception of specific model architecture code.

Deferred (to be added as required):
- Build instructions (Cython extension compilation), run scripts, and configuration.
- Testing suites.
- Benchmarks and performance notes.
- Per‑module READMEs and API references.

### Limitations and assumptions
- Game is strictly heads‑up (2‑player) no‑limit Texas Hold'em; code is poker‑specific in evaluator and encodings.
- Strategos's AIOps are explicitly GPU-bound; no CPU-only option is provided. Users must ensure they have a working CUDA-enabled PyTorch install.  
- Thread/process safety is limited to the intended "parallel worker" collection pattern; broader concurrency guarantees are not provided.
- Memory usage scales with explored subgames and terminal sets; extremely large exploration budgets will require careful resource planning.
- The above is particularly acute during model training. Logic is intentionally designed to sacrifice memory space for speed; no option is currently provided to load training data from disk during training - the full set is stored in memory. As CFR iterations expand the training data set, more memory will be needed to hold the collected set. 

### References & acknowledgements
- Hand evaluator derived from Deuces (MIT) by Will Drevo. Original repository: [worldveil/deuces](https://github.com/worldveil/deuces). In Strategos, this component was ported and optimized via Cython; any defects are ours. Copyright (c) 2013 Will Drevo.
- Lisý, V., Lanctot, M., & Bowling, M. (2015). CFR with imperfect recall and sampling variants. (external sampling background)
- Schmid, M., Moravčík, M., et al. (2019). Single Deep CFR. arXiv:1901.07621.  

### License
License to be added. Until then, all rights reserved.

### Roadmap (short‑term)
- Publish build/run documentation and lightweight quickstart.
- Add tests and minimal benchmarks.
- Provide full usage docs and diagrams for CFR data flow and target calculations.
