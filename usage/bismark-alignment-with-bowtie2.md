# Bismark Alignment with bowtie2

| Option                 | Functionality                                                               |
| ---------------------- | --------------------------------------------------------------------------- |
| `-q`                   | Quiet mode: suppresses detailed output.                                     |
| `--score-min L,0,-0.2` | Sets a linear minimum score for valid alignments (moderate stringency).     |
| `--ignore-quals`       | Ignores base quality scores during alignment.                               |
| `--no-mixed`           | Ensures both ends of paired reads align properly; no single-end alignments. |
| `--no-discordant`      | Prevents discordant alignments; enforces proper orientation and distance.   |
| `--dovetail`           | Allows overlapping or extended alignments in paired-end reads.              |
| `--maxins 500`         | Sets the maximum allowed distance between paired-end reads to 500 bases.    |
