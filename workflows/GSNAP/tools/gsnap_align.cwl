cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["gsnap", "--gunzip",  "-O", "-A", "sam"] 
arguments:
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: samtools
    position: 7
  - valueFrom: view
    position: 8
  - prefix: "-@"
    valueFrom: $(inputs.threads)
    position: 9
  - prefix: "-o"
    valueFrom: $(inputs.output_name).bam
    position: 10
  - valueFrom: "-"
    position: 11
  - valueFrom: ${
                  return inputs.index_dir.path.substring(inputs.index_dir.path.lastIndexOf('/') + 1,
                                                         inputs.index_dir.path.length);
                }
    position: 1
    prefix: -d

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/gsnap

stdout: stderr
stderr: $(inputs.output_name + ".gsnap.aln.log")

inputs: 
  - id: read1
    doc: read1.fa.gz
    type: File
    inputBinding:
      position: 4
  - id: read2
    doc: read2.fa.gz
    type: File
    inputBinding:
      position: 5
  - id: output_name
    type: string
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2
  - id: index_dir
    type: Directory
    inputBinding:
      prefix: -D
      position: 3
  - id: pbat
    type: boolean
    inputBinding:
      position: 1
      valueFrom: ${if(inputs.pbat) return "--mode=cmet-nonstranded"; else return "--mode=cmet-stranded"}


outputs:
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
  log:
    type: stderr

## OUTPUT PART      
#outputs: 
#  sam:
#    type: stdout
#  log:
#    type: stderr
#
#stdout: $(inputs.output_name).sam
#stderr: $(inputs.output_name).log

