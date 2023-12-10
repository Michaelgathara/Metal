# Metal
Apple Metal Experiments

This will act as a home for some GPU programming experiments I'm running in order to learn how GPUs on Apple's M chips work.

## Architecture
```html
                  +-----------------------+
                  |                       |
+-----------+     |     +-----------+ +---+-----+
|           |     |     |           | |         |
|           |     |     |           | |         |
|           |     |     |           | |         |
|           | +---+---+ |           | |         |
|           | |       | |           | |         |
|   CPU     +-+FABRIC +-+   GPU     | |  DRAM   |
|           | |       | |           | |         |
|           | +---+---+ |           | |         |
|           |     |     |           | |         |
|           |     |     |           | |         |
+-----------+     |     +-----------+ |         |
                  |                   |         |
+-----------------+-----+             |         |
|                       |             |         |
|      CACHE            |             |         |
|                       |             |         |
+-----------------------+             +---------+
```
Apple uses a UMA (Unified Memory Architecture). This allows for memory to be shared across devices, thus the CPU and GPU can access the same memory address. The UMA approach reduces the volatility that RAM brings, allows the storage of long-term data, thus increasing speed. 