# The CWLs composition table of the Benchmarking project.

The location of the Trimming CWL
```
/tools/trimming/
```

The location of the workflows CWL

```
/workflows/<workflow_name>/
```

1). BAT
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | BAT_workflow_start_with_trimmed.cwl | BAT_workflow.cwl |
| Swift | trim_galore.cwl | BAT_workflow_start_with_trimmed.cwl | BAT_workflow.cwl |
| T-WGBS | trim_galore.cwl | BAT_workflow_start_with_trimmed.cwl | BAT_workflow.cwl |
| EMseq | trim_galore.cwl | BAT_workflow_start_with_trimmed.cwl | BAT_workflow.cwl |

2). Biscuit
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | biscuit_singlelib_start_with_trimmed.cwl | biscuit_singlelib.cwl |
| Swift | trim_galore.cwl | biscuit_singlelib_start_with_trimmed.cwl | biscuit_singlelib.cwl |
| T-WGBS | trim_galore.cwl | biscuit_multilib_start_with_trimmed.cwl |biscuit_multilib.cwl |
| PBAT | trim_galore.cwl | biscuit_singlelib_start_with_trimmed.cwl | biscuit_singlelib.cwl |
| EMseq | trim_galore.cwl | biscuit_singlelib_start_with_trimmed.cwl | biscuit_singlelib.cwl |

3). Bismark
| Protocols       | Trimming | workflow CWL |
|-------------| -----:| :----: |
| WGBS | trim_galore.cwl | bismark_singlelib/CWL/workflows/Bismark_start_with_trimmed.cwl |
| Swift | trim_galore.cwl | bismark_singlelib/CWL/workflows/Bismark_start_with_trimmed.cwl |
| T-WGBS | trim_galore.cwl | bismark_multilib/CWL/workflows/Bismark_TWGBS_multilib.cwl |
| PBAT | trim_galore.cwl | bismark_singlelib/CWL/workflows/Bismark_start_with_trimmed.cwl |
| EMseq | trim_galore.cwl | bismark_singlelib/CWL/workflows/Bismark_start_with_trimmed.cwl |

4). BSBolt
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | bsbolt_singlelib_start_with_trimmed.cwl | bsbolt_singlelib.cwl |
| Swift | trim_galore.cwl | bsbolt_singlelib_start_with_trimmed.cwl | bsbolt_singlelib.cwl |
| T-WGBS | trim_galore.cwl | bsbolt_multilib_start_with_trimmed.cwl | bsbolt_multilib.cwl |
| PBAT | trim_galore.cwl | bsbolt_singlelib_start_with_trimmed.cwl | bsbolt_singlelib.cwl |
| EMseq | trim_galore.cwl | bsbolt_singlelib_start_with_trimmed.cwl | bsbolt_singlelib.cwl |

5). bwa-meth
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trimmomatic.cwl | bwameth_singlelib_start_with_trimmed.cwl | bwameth_singlelib.cwl |
| Swift | trimmomatic_Swift.cwl | bwameth_singlelib_start_with_trimmed.cwl | bwameth_singlelib.cwl | 
| T-WGBS | trimmomatic.cwl | bwameth_multilib_start_with_trimmed.cwl | bwameth_multilib.cwl |
| PBAT | trimmomatic_PBAT.cwl | bwameth_singlelib_start_with_trimmed.cwl | bwameth_singlelib.cwl |
| EMseq | trimmomatic.cwl | bwameth_singlelib_start_with_trimmed.cwl | bwameth_singlelib.cwl |

6). FAME
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | fame_workflow_start_with_trimmed.cwl | fame_workflow.cwl |
| Swift | trim_galore.cwl | fame_workflow_start_with_trimmed.cwl | fame_workflow.cwl |
| T-WGBS | trim_galore.cwl | fame_workflow_start_with_trimmed.cwl | fame_workflow.cwl |
| PBAT | trim_galore.cwl | fame_workflow_start_with_trimmed.cwl | fame_workflow.cwl |
| EMseq | trim_galore.cwl | fame_workflow_start_with_trimmed.cwl | fame_workflow.cwl |

7). GSNAP
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | gsnap_singlelib_start_with_trimmed.cwl | gsnap_singlelib.cwl |
| Swift | trim_galore.cwl | gsnap_singlelib_start_with_trimmed.cwl | gsnap_singlelib.cwl |
| T-WGBS | trim_galore.cwl | gsnap_multilib_start_with_trimmed.cwl | gsnap_multilib.cwl |
| PBAT | trim_galore.cwl | gsnap_singlelib_start_with_trimmed.cwl | gsnap_singlelib.cwl |
| EMseq | trim_galore.cwl | gsnap_singlelib_start_with_trimmed.cwl | gsnap_singlelib.cwl |

8). methylCtools
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trimmomatic.cwl | methylCtools_singlelib_start_with_trimmed.cwl | methylCtools_singlelib.cwl |
| Swift | trimmomatic_Swift.cwl | methylCtools_singlelib_start_with_trimmed.cwl | methylCtools_singlelib.cwl |
| T-WGBS | trimmomatic.cwl | methylCtools_multilib_start_with_trimmed.cwl | methylCtools_multilib.cwl |
| PBAT | trimmomatic_PBAT_methylCtools.cwl | methylCtools_singlelib_start_with_trimmed.cwl | methylCtools_singlelib.cwl |
| EMseq | trimmomatic.cwl | methylCtools_singlelib_start_with_trimmed.cwl | methylCtools_singlelib.cwl |

9). methylpy
| Protocols       | Trimming (1) | Aligning and Calling (2) | Combined (1)(2) | 
|-------------| -----:| :----: | :----: |
| WGBS | trim_galore.cwl | methylpy_singlelib_start_with_trimmed.cwl | methylpy_singlelib.cwl |
| Swift | trim_galore.cwl | methylpy_singlelib_start_with_trimmed.cwl | methylpy_singlelib.cwl |
| T-WGBS | trim_galore.cwl | methylpy_multilib_start_with_trimmed.cwl | methylpy_multilib.cwl |
| PBAT | trim_galore.cwl | methylpy_singlelib_start_with_trimmed.cwl | methylpy_singlelib.cwl |
| EMseq | trim_galore.cwl | methylpy_singlelib_start_with_trimmed.cwl | methylpy_singlelib.cwl |
