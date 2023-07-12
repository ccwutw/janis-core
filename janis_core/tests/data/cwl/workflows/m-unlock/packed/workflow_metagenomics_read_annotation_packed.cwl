{
    "$graph": [
        {
            "class": "CommandLineTool",
            "label": "Concatenate multiple files",
            "baseCommand": [
                "cat"
            ],
            "stdout": "$(inputs.outname)",
            "hints": [
                {
                    "dockerPull": "debian:buster",
                    "class": "DockerRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#concatenate.cwl/infiles"
                },
                {
                    "type": "string",
                    "id": "#concatenate.cwl/outname"
                }
            ],
            "id": "#concatenate.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential",
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.outname)"
                    },
                    "id": "#concatenate.cwl/output"
                }
            ]
        },
        {
            "class": "CommandLineTool",
            "label": "compress a file multithreaded with pigz",
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/pigz:2.6",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.6"
                            ],
                            "specs": [
                                "https://anaconda.org/conda-forge/pigz"
                            ],
                            "package": "pigz"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "baseCommand": [
                "pigz",
                "-c"
            ],
            "arguments": [
                {
                    "valueFrom": "$(inputs.inputfile)"
                }
            ],
            "stdout": "$(inputs.inputfile.basename).gz",
            "inputs": [
                {
                    "type": "File",
                    "id": "#pigz.cwl/inputfile"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 1,
                    "inputBinding": {
                        "prefix": "-p"
                    },
                    "id": "#pigz.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.inputfile.basename).gz"
                    },
                    "id": "#pigz.cwl/outfile"
                }
            ],
            "id": "#pigz.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Filter from reads",
            "doc": "Filter reads using BBmaps bbduk tool (paired-end only)\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/bbmap:39.01",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "39.01"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/bbmap"
                            ],
                            "package": "bbmap"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "in=",
                        "separate": false
                    },
                    "id": "#bbduk_filter.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#bbduk_filter.cwl/identifier"
                },
                {
                    "type": "int",
                    "inputBinding": {
                        "prefix": "k=",
                        "separate": false
                    },
                    "default": 31,
                    "id": "#bbduk_filter.cwl/kmersize"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 8,
                    "id": "#bbduk_filter.cwl/memory"
                },
                {
                    "doc": "Reference contamination fasta file (can be compressed)",
                    "label": "Reference contamination file",
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "ref=",
                        "separate": false
                    },
                    "id": "#bbduk_filter.cwl/reference"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "prefix": "in2=",
                        "separate": false
                    },
                    "id": "#bbduk_filter.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 1,
                    "inputBinding": {
                        "prefix": "threads=",
                        "separate": false
                    },
                    "id": "#bbduk_filter.cwl/threads"
                }
            ],
            "baseCommand": [
                "bbduk.sh"
            ],
            "arguments": [
                {
                    "prefix": "-Xmx",
                    "separate": false,
                    "valueFrom": "$(inputs.memory)M"
                },
                {
                    "prefix": "out=",
                    "separate": false,
                    "valueFrom": "$(inputs.identifier)_1.fq.gz"
                },
                {
                    "prefix": "out2=",
                    "separate": false,
                    "valueFrom": "$(inputs.identifier)_2.fq.gz"
                },
                {
                    "prefix": "stats=",
                    "separate": false,
                    "valueFrom": "$(inputs.identifier)_bbduk-stats.txt"
                }
            ],
            "stderr": "$(inputs.identifier)_bbduk-summary.txt",
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_1.fq.gz"
                    },
                    "id": "#bbduk_filter.cwl/out_forward_reads"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_2.fq.gz"
                    },
                    "id": "#bbduk_filter.cwl/out_reverse_reads"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_bbduk-stats.txt"
                    },
                    "id": "#bbduk_filter.cwl/stats_file"
                },
                {
                    "type": "File",
                    "id": "#bbduk_filter.cwl/summary",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_bbduk-summary.txt"
                    }
                }
            ],
            "id": "#bbduk_filter.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2020-00-00",
            "https://schema.org/dateModified": "2023-02-07",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/bbmap:38.98",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "38.98"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/bbmap"
                            ],
                            "package": "bbmap"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "label": "BBMap",
            "doc": "Read filtering using BBMap against a (contamination) reference genome\n",
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 1,
                        "prefix": "in=",
                        "separate": false
                    },
                    "id": "#bbmap_filter-reads.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#bbmap_filter-reads.cwl/identifier"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "maximum memory usage in megabytes",
                    "label": "memory usage (mb)",
                    "default": 8000,
                    "id": "#bbmap_filter-reads.cwl/memory"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#bbmap_filter-reads.cwl/output_mapped"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 3,
                        "prefix": "ref=",
                        "separate": false
                    },
                    "id": "#bbmap_filter-reads.cwl/reference"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "position": 2,
                        "prefix": "in2=",
                        "separate": false
                    },
                    "id": "#bbmap_filter-reads.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "number of threads to use for computational processes",
                    "label": "number of threads",
                    "inputBinding": {
                        "prefix": "threads=",
                        "separate": false
                    },
                    "default": 2,
                    "id": "#bbmap_filter-reads.cwl/threads"
                }
            ],
            "stderr": "$(inputs.identifier)_BBMap_log.txt",
            "outputs": [
                {
                    "label": "Coverage per contig",
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_BBMap_covstats.txt"
                    },
                    "id": "#bbmap_filter-reads.cwl/covstats"
                },
                {
                    "label": "BBMap log output",
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_BBMap_log.txt"
                    },
                    "id": "#bbmap_filter-reads.cwl/log"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_filtered_1.fq.gz"
                    },
                    "id": "#bbmap_filter-reads.cwl/out_forward_reads"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_filtered_2.fq.gz"
                    },
                    "id": "#bbmap_filter-reads.cwl/out_reverse_reads"
                },
                {
                    "label": "Mapping statistics",
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_BBMap_stats.txt"
                    },
                    "id": "#bbmap_filter-reads.cwl/stats"
                }
            ],
            "baseCommand": [
                "bbmap.sh"
            ],
            "arguments": [
                "-Xmx$(inputs.memory)M",
                "printunmappedcount",
                "overwrite=true",
                "bloom=t",
                "statsfile=$(inputs.identifier)_BBMap_stats.txt",
                "covstats=$(inputs.identifier)_BBMap_covstats.txt",
                "${\n  if (inputs.output_mapped){\n    return 'outm1='+inputs.identifier+'_filtered_1.fq.gz \\\n            outm2='+inputs.identifier+'_filtered_2.fq.gz';\n  } else {\n    return 'outu1='+inputs.identifier+'_filtered_1.fq.gz \\\n            outu2='+inputs.identifier+'_filtered_2.fq.gz';\n  }\n}\n"
            ],
            "id": "#bbmap_filter-reads.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2020-00-00",
            "https://schema.org/dateModified": "2022-04-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "label": "Prepare fasta DB",
            "doc": "Prepares fasta file for so it does not contain duplicate fasta headers.\nOnly looks at the first part of the header before any whitespace.\nAdds and incremental number in the header.\n\nExpects fasta file(s) or plaintext fasta(s). Not mixed!    \n",
            "requirements": [
                {
                    "listing": [
                        {
                            "entry": "$({class: 'Directory', listing: []})",
                            "entryname": "prepare_fasta_db",
                            "writable": true
                        },
                        {
                            "entryname": "script.sh",
                            "entry": "#!/bin/bash\necho -e \"\\\n#/usr/bin/python3\nimport sys\\n\\\nheaders = set()\\n\\\nc = 0\\n\\\nfor line in sys.stdin:\\n\\\n  splitline = line.split()\\n\\\n  if line[0] == '>':    \\n\\\n    if splitline[0] in headers:\\n\\\n      c += 1\\n\\\n      print(splitline[0]+'.x'+str(c)+' '+' '.join(splitline[1:]))\\n\\\n    else:\\n\\\n      print(line.strip())\\n\\\n    headers.add(splitline[0])\\n\\\n  else:\\n\\\n    print(line.strip())\" > ./dup.py\nout_name=$1\nshift\n\nif file $@ | grep gzip; then\n  zcat $@ | python3 ./dup.py | gzip > $out_name\nelse\n  cat $@ | python3 ./dup.py | gzip > $out_name\nfi"
                        }
                    ],
                    "class": "InitialWorkDirRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/python:3.10.6",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "3.10.6"
                            ],
                            "specs": [
                                "https://anaconda.org/conda-forge/python"
                            ],
                            "package": "python3"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "baseCommand": [
                "bash",
                "script.sh"
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "label": "fasta files",
                    "doc": "Fasta file(s) to be the prepared. Can also be gzipped (not mixe)",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#prepare_fasta_db.cwl/fasta_files"
                },
                {
                    "type": "string",
                    "label": "Output outfile",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#prepare_fasta_db.cwl/output_file_name"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.output_file_name)"
                    },
                    "id": "#prepare_fasta_db.cwl/fasta_db"
                }
            ],
            "id": "#prepare_fasta_db.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2022-07-00",
            "https://schema.org/dateModified": "2023-01-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "doc": "Diamond workflow implementation\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/diamond:2.0.15",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.0.15"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/diamond"
                            ],
                            "package": "diamond"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "string",
                    "doc": "Align amino acid (blastp) or DNA (blastx) sequences against a protein reference database",
                    "label": "Blast type",
                    "default": "blastx",
                    "id": "#diamond.cwl/align"
                },
                {
                    "type": "int",
                    "doc": "Block size in billions of sequence letters to be processed at a time. This is the main parameter for controlling the program\u2019s memory and disk space usage. Bigger numbers will increase the use of memory and temporary disk space, but also improve performance. The program can be expected to use roughly six times this number of memory (in GB).",
                    "label": "Block size",
                    "inputBinding": {
                        "prefix": "--block-size"
                    },
                    "default": 12,
                    "id": "#diamond.cwl/blocksize"
                },
                {
                    "type": "string",
                    "doc": "Path to the DIAMOND database file. Since v2.0.8, a BLAST database can also be used here.",
                    "label": "Database file path",
                    "inputBinding": {
                        "prefix": "--db"
                    },
                    "id": "#diamond.cwl/database"
                },
                {
                    "type": "File",
                    "doc": "forward sequence file locally",
                    "label": "forward reads",
                    "id": "#diamond.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#diamond.cwl/identifier"
                },
                {
                    "type": "int",
                    "doc": "The number of chunks for processing the seed index. This option can be additionally used to tune the performance. The default value is -c4, while setting this parameter to -c1 instead will improve the performance at the cost of increased memory use. Note that the very-sensitive and ultra-sensitive modes use -c1 by default.",
                    "label": "The number of chunks",
                    "inputBinding": {
                        "prefix": "--index-chunks"
                    },
                    "default": 1,
                    "id": "#diamond.cwl/indexchunks"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Scoring matrix. The following matrices are supported, with the default being BLOSUM62.",
                    "label": "scoring matrix",
                    "inputBinding": {
                        "prefix": "--matrix"
                    },
                    "default": "BLOSUM62",
                    "id": "#diamond.cwl/matrix"
                },
                {
                    "type": "int",
                    "doc": "maximum number of target sequences to report alignments for (default=25)",
                    "label": "Max target sequences",
                    "inputBinding": {
                        "prefix": "--max-target-seqs"
                    },
                    "default": 25,
                    "id": "#diamond.cwl/maxtargetseq"
                },
                {
                    "type": "string",
                    "doc": "Format of the output file. See the diamond manual for accepted output formats",
                    "label": "Output format",
                    "inputBinding": {
                        "prefix": "--outfmt"
                    },
                    "default": "100",
                    "id": "#diamond.cwl/outfmt"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Path to the output file. If this parameter is omitted, the results will be written to the standard output and all other program output will be suppressed.",
                    "label": "output file",
                    "inputBinding": {
                        "prefix": "--out"
                    },
                    "id": "#diamond.cwl/output"
                },
                {
                    "type": "File",
                    "doc": "reverse sequence file locally",
                    "label": "reverse reads",
                    "id": "#diamond.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 3,
                    "inputBinding": {
                        "prefix": "--threads"
                    },
                    "id": "#diamond.cwl/threads"
                }
            ],
            "baseCommand": [
                "/unlock/infrastructure/binaries/diamond/diamond_v2.0.8.146/diamond"
            ],
            "arguments": [
                "$(inputs.align)",
                "--query",
                "$(inputs.forward_reads.path)",
                "$(inputs.reverse_reads.path)",
                "--salltitles"
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.output).daa"
                    },
                    "id": "#diamond.cwl/output_diamond"
                }
            ],
            "id": "#diamond.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "doc": "Diamond workflow implementation\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/diamond:2.0.15",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.0.15"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/diamond"
                            ],
                            "package": "diamond"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Diamond binary result file",
                    "label": "input file",
                    "inputBinding": {
                        "prefix": "--daa"
                    },
                    "id": "#view.cwl/inputfile"
                }
            ],
            "baseCommand": [
                "diamond"
            ],
            "arguments": [
                "view",
                "--outfmt",
                "6",
                "qseqid",
                "sseqid",
                "pident",
                "length",
                "mismatch",
                "gapopen",
                "qstart",
                "qend",
                "sstart",
                "send",
                "evalue",
                "bitscore",
                "stitle",
                "--out",
                "$(inputs.inputfile.basename).tsv"
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.inputfile.basename).tsv"
                    },
                    "id": "#view.cwl/output_diamond_tabular"
                }
            ],
            "id": "#view.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "ExpressionTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "label": "Convert an array of 1 file to a file object",
            "doc": "Converts the array and returns the first file in the array. \nShould only be used when 1 file is in the array.\n",
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#array_to_file.cwl/files"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "id": "#array_to_file.cwl/file"
                }
            ],
            "expression": "${\n  var first_file = inputs.files[0];\n  return {'file': first_file}\n}",
            "id": "#array_to_file.cwl"
        },
        {
            "class": "ExpressionTool",
            "doc": "Transforms the input files to a mentioned directory\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "string",
                    "id": "#files_to_folder.cwl/destination"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "id": "#files_to_folder.cwl/files"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "Directory"
                        }
                    ],
                    "id": "#files_to_folder.cwl/folders"
                }
            ],
            "expression": "${\n  var array = []\n  if (inputs.files != null) {\n    array = array.concat(inputs.files)\n  }\n  if (inputs.folders != null) {\n    array = array.concat(inputs.folders)\n  }\n  var r = {\n     'results':\n       { \"class\": \"Directory\",\n         \"basename\": inputs.destination,\n         \"listing\": array\n       } \n     };\n   return r; \n }\n",
            "outputs": [
                {
                    "type": "Directory",
                    "id": "#files_to_folder.cwl/results"
                }
            ],
            "id": "#files_to_folder.cwl",
            "http://schema.org/citation": "https://m-unlock.nl",
            "http://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "http://schema.org/dateCreated": "2020-00-00",
            "http://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "http://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "doc": "Modified from https://github.com/ambarishK/bio-cwl-tools/blob/release/fastp/fastp.cwl\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/fastp:0.23.2",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "0.23.2"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/fastp"
                            ],
                            "package": "fastp"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "inputBinding": {
                        "prefix": "--correction"
                    },
                    "id": "#fastp.cwl/base_correction"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "inputBinding": {
                        "prefix": "--dedup"
                    },
                    "id": "#fastp.cwl/deduplicate"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "inputBinding": {
                        "prefix": "--disable_trim_poly_g"
                    },
                    "id": "#fastp.cwl/disable_trim_poly_g"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "inputBinding": {
                        "prefix": "--trim_poly_g"
                    },
                    "id": "#fastp.cwl/force_polyg_tail_trimming"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "--in1"
                    },
                    "id": "#fastp.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#fastp.cwl/identifier"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "inputBinding": {
                        "prefix": "--merge"
                    },
                    "id": "#fastp.cwl/merge_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "inputBinding": {
                        "prefix": "--length_required"
                    },
                    "id": "#fastp.cwl/min_length_required"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 20,
                    "inputBinding": {
                        "prefix": "--qualified_quality_phred"
                    },
                    "id": "#fastp.cwl/qualified_phred_quality"
                },
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "--in2"
                    },
                    "id": "#fastp.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 1,
                    "inputBinding": {
                        "prefix": "--thread"
                    },
                    "id": "#fastp.cwl/threads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 20,
                    "inputBinding": {
                        "prefix": "--unqualified_percent_limit"
                    },
                    "id": "#fastp.cwl/unqualified_phred_quality"
                }
            ],
            "arguments": [
                {
                    "prefix": "--out1",
                    "valueFrom": "$(inputs.identifier)_fastp_1.fq.gz"
                },
                "${\n  if (inputs.reverse_reads){\n    return '--out2';\n  } else {\n    return '';\n  }\n}\n",
                "${\n  if (inputs.reverse_reads){\n    return inputs.identifier + \"_fastp_2.fq.gz\";\n  } else {\n    return '';\n  }\n}\n",
                "${\n  if (inputs.reverse_reads_path){\n    return '--out2';\n  } else {\n    return '';\n  }\n}\n",
                "${\n  if (inputs.reverse_reads_path){\n    return inputs.identifier + \"_fastp_2.fq.gz\";\n  } else {\n    return '';\n  }\n}\n",
                "${\n  if (inputs.merge_reads){\n    return '--merged_out';\n  } else {\n    return '';\n  }\n}\n",
                "${\n  if (inputs.merge_reads){\n    return inputs.identifier + \"merged_fastp.fq.gz\";\n  } else {\n    return '';\n  }\n}\n",
                {
                    "prefix": "-h",
                    "valueFrom": "$(inputs.identifier)_fastp.html"
                },
                {
                    "prefix": "-j",
                    "valueFrom": "$(inputs.identifier)_fastp.json"
                }
            ],
            "baseCommand": [
                "fastp"
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_fastp.html"
                    },
                    "id": "#fastp.cwl/html_report"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_fastp.json"
                    },
                    "id": "#fastp.cwl/json_report"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_merged_fastp.fq.gz"
                    },
                    "id": "#fastp.cwl/merged_reads"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_fastp_1.fq.gz"
                    },
                    "id": "#fastp.cwl/out_forward_reads"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_fastp_2.fq.gz"
                    },
                    "id": "#fastp.cwl/out_reverse_reads"
                }
            ],
            "id": "#fastp.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2020-00-00",
            "https://schema.org/dateModified": "2022-02-22",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "label": "fastq to fasta",
            "doc": "Convert fastq file(s) to fasta format.\nzcat $@ | sed -n '1~4s/^@/>/p;2~4p'\n",
            "requirements": [
                {
                    "listing": [
                        {
                            "entry": "$({class: 'Directory', listing: []})",
                            "entryname": "fastq_to_fasta",
                            "writable": true
                        },
                        {
                            "entryname": "script.sh",
                            "entry": "#!/bin/bash\nzcat $@ | sed -n '1~4s/^@/>/p;2~4p'"
                        }
                    ],
                    "class": "InitialWorkDirRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "bash",
                "script.sh"
            ],
            "stdout": "$(inputs.identifier).fasta",
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "file list to be concatenated",
                    "label": "file list",
                    "inputBinding": {
                        "position": 0
                    },
                    "id": "#fastq_to_fasta.cwl/fastq_files"
                },
                {
                    "type": "string",
                    "doc": "Name of the output file",
                    "label": "output file name",
                    "id": "#fastq_to_fasta.cwl/identifier"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "id": "#fastq_to_fasta.cwl/fasta_out",
                    "outputBinding": {
                        "glob": "$(inputs.identifier).fasta"
                    }
                }
            ],
            "id": "#fastq_to_fasta.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "fastqc"
            ],
            "label": "FASTQC",
            "doc": "Performs quality control on FASTQ files\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "InitialWorkDirRequirement",
                    "listing": [
                        {
                            "entry": "$({class: 'Directory', listing: []})",
                            "entryname": "FASTQC",
                            "writable": true
                        }
                    ]
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/fastqc:0.11.9",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "0.11.9"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/fastqc"
                            ],
                            "package": "fastp"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "arguments": [
                "--outdir",
                "FASTQC"
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "doc": "FastQ file list",
                    "label": "FASTQ file list",
                    "inputBinding": {
                        "position": 100
                    },
                    "id": "#fastqc.cwl/fastq"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "FastQ files list",
                    "label": "FASTQ files list",
                    "inputBinding": {
                        "position": 101,
                        "prefix": "--nano"
                    },
                    "id": "#fastqc.cwl/nanopore_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 1,
                    "inputBinding": {
                        "prefix": "--threads"
                    },
                    "id": "#fastqc.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "FASTQC/*.html"
                    },
                    "id": "#fastqc.cwl/html_files"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "FASTQC/*.zip"
                    },
                    "id": "#fastqc.cwl/zip_files"
                }
            ],
            "id": "#fastqc.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0002-5516-8391",
                    "https://schema.org/email": "mailto:german.royvalgarcia@wur.nl",
                    "https://schema.org/name": "Germ\u00e1n Royval"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-11-26",
            "https://schema.org/dateModified": "2022-04-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "label": "HUMAnN Analysis",
            "doc": "Runs the HUMAnN meta-omics taxonomic and functional profiling tool.\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/humann2:2.8.1",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.8.1"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/humann2"
                            ],
                            "package": "humann2"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "FASTA of unaligned sequences",
                    "label": "Input fasta",
                    "inputBinding": {
                        "prefix": "-i"
                    },
                    "id": "#humann.cwl/fasta"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#humann.cwl/identifier"
                },
                {
                    "type": "string",
                    "doc": "location of a indexed metaphlan database",
                    "label": "metaphlan database",
                    "default": "--bowtie2db /unlock/references/databases/HUMAnN/metaphlan_databases/",
                    "inputBinding": {
                        "prefix": "--metaphlan-options"
                    },
                    "id": "#humann.cwl/metaphlan_db"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 2,
                    "inputBinding": {
                        "prefix": "--threads"
                    },
                    "id": "#humann.cwl/threads"
                }
            ],
            "baseCommand": [
                "humann"
            ],
            "arguments": [
                {
                    "prefix": "-o",
                    "valueFrom": "$(inputs.identifier)_HUMAnN"
                },
                {
                    "prefix": "--o-log",
                    "valueFrom": "$(inputs.identifier)_HUMAnN.log"
                }
            ],
            "stdout": "$(inputs.identifier)_HUMAnN.stdout.log",
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_HUMAnN/$(inputs.identifier)_genefamilies.tsv"
                    },
                    "id": "#humann.cwl/genefamilies_out"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_HUMAnN.log"
                    },
                    "id": "#humann.cwl/log_out"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_HUMAnN/$(inputs.identifier)_pathabundance.tsv"
                    },
                    "id": "#humann.cwl/pathabundance_out"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_HUMAnN/$(inputs.identifier)_pathcoverage.tsv"
                    },
                    "id": "#humann.cwl/pathcoverage_out"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_HUMAnN.stdout.log"
                    },
                    "id": "#humann.cwl/stdout_out"
                }
            ],
            "id": "#humann.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "baseCommand": [
                "kraken2"
            ],
            "label": "Kraken2",
            "doc": "Kraken2 metagenomics taxomic read classification.\n\nUpdated databases available at: https://benlangmead.github.io/aws-indexes/k2 (e.g. PlusPF-8)\nOriginal db: https://ccb.jhu.edu/software/kraken2/index.shtml?t=downloads\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/kraken2:2.1.2",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.1.2"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/kraken2"
                            ],
                            "package": "kraken2"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "$(inputs.identifier)_$(inputs.database.path.split( '/' ).pop())_kraken2.txt",
                    "prefix": "--output"
                },
                {
                    "valueFrom": "$(inputs.identifier)_$(inputs.database.path.split( '/' ).pop())_kraken2_report.txt",
                    "prefix": "--report"
                },
                "--report-zero-counts",
                "--use-names"
            ],
            "inputs": [
                {
                    "type": "boolean",
                    "doc": "input data is gzip compressed",
                    "inputBinding": {
                        "position": 3,
                        "prefix": "--bzip2-compressed"
                    },
                    "default": false,
                    "id": "#kraken2.cwl/bzip2"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "label": "Confidence",
                    "doc": "Confidence score threshold (default 0.0) must be in [0, 1]",
                    "inputBinding": {
                        "position": 4,
                        "prefix": "--confidence"
                    },
                    "id": "#kraken2.cwl/confidence"
                },
                {
                    "type": "Directory",
                    "label": "Database",
                    "doc": "Database location of kraken2",
                    "inputBinding": {
                        "prefix": "--db"
                    },
                    "id": "#kraken2.cwl/database"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "label": "Forward reads",
                    "doc": "Illumina forward read file",
                    "inputBinding": {
                        "position": 100
                    },
                    "id": "#kraken2.cwl/forward_reads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "doc": "input data is gzip compressed",
                    "inputBinding": {
                        "position": 3,
                        "prefix": "--gzip-compressed"
                    },
                    "default": false,
                    "id": "#kraken2.cwl/gzip"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#kraken2.cwl/identifier"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "label": "Nanopore reads",
                    "doc": "Oxford Nanopore Technologies reads in FASTQ",
                    "inputBinding": {
                        "position": 102
                    },
                    "id": "#kraken2.cwl/nanopore_reads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "label": "Paired end",
                    "doc": "Data is paired end (separate files)",
                    "inputBinding": {
                        "position": 2,
                        "prefix": "--paired"
                    },
                    "default": false,
                    "id": "#kraken2.cwl/paired_end"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "label": "Reverse reads",
                    "doc": "Illumina reverse read file",
                    "inputBinding": {
                        "position": 101
                    },
                    "id": "#kraken2.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 1,
                    "inputBinding": {
                        "prefix": "--threads"
                    },
                    "id": "#kraken2.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_$(inputs.database.path.split( '/' ).pop())_kraken2_report.txt"
                    },
                    "id": "#kraken2.cwl/sample_report"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.identifier)_$(inputs.database.path.split( '/' ).pop())_kraken2.txt"
                    },
                    "id": "#kraken2.cwl/standard_report"
                }
            ],
            "id": "#kraken2.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0002-5516-8391",
                    "https://schema.org/email": "mailto:german.royvalgarcia@wur.nl",
                    "https://schema.org/name": "Germ\u00e1n Royval"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-11-25",
            "https://schema.org/dateModified": "2021-11-04",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "hints": [
                {
                    "dockerPull": "docker-registry.wur.nl/m-unlock/docker/krona:2.8.1",
                    "class": "DockerRequirement"
                },
                {
                    "packages": [
                        {
                            "version": [
                                "2.8.1"
                            ],
                            "specs": [
                                "https://anaconda.org/bioconda/krona"
                            ],
                            "package": "krona"
                        }
                    ],
                    "class": "SoftwareRequirement"
                }
            ],
            "baseCommand": [
                "ktImportTaxonomy"
            ],
            "label": "Krona",
            "doc": "Visualization of Kraken2 report results.\nktImportText -o $1 $2\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "InitialWorkDirRequirement",
                    "listing": [
                        {
                            "entry": "$({class: 'Directory', listing: []})",
                            "entryname": "krona_output",
                            "writable": true
                        }
                    ]
                }
            ],
            "arguments": [
                {
                    "prefix": "-o",
                    "valueFrom": "krona_output/$(inputs.kraken.nameroot)_krona.html"
                }
            ],
            "inputs": [
                {
                    "type": "int",
                    "label": "Counts column",
                    "doc": "Column number for count information (default for kraken)",
                    "default": 3,
                    "inputBinding": {
                        "position": 2,
                        "prefix": "-m"
                    },
                    "id": "#krona.cwl/counts"
                },
                {
                    "type": "File",
                    "label": "Tab-delimited text file",
                    "inputBinding": {
                        "position": 10
                    },
                    "id": "#krona.cwl/kraken"
                },
                {
                    "type": "int",
                    "label": "Taxon column",
                    "doc": "Column number for taxon information (default for kraken)",
                    "default": 5,
                    "inputBinding": {
                        "position": 1,
                        "prefix": "-t"
                    },
                    "id": "#krona.cwl/taxonomy"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "krona_output/$(inputs.kraken.nameroot)_krona.html"
                    },
                    "id": "#krona.cwl/krona_html"
                }
            ],
            "id": "#krona.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0002-5516-8391",
                    "https://schema.org/email": "mailto:german.royvalgarcia@wur.nl",
                    "https://schema.org/name": "Germ\u00e1n Royval"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-12-10",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "CommandLineTool",
            "doc": "Samsa2 conversion workflow\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#convert.cwl/identifier"
                },
                {
                    "type": "File",
                    "doc": "diamond refseq or seed result table with salltitles",
                    "label": "diamond tabular file",
                    "id": "#convert.cwl/inputfile"
                }
            ],
            "baseCommand": [
                "python3"
            ],
            "arguments": [
                "/unlock/infrastructure/scripts/samsa2/manager.py",
                "$(inputs.inputfile.path)",
                "$(inputs.identifier)"
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*_function.tsv"
                    },
                    "id": "#convert.cwl/output_refseq_function"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*_organism.tsv"
                    },
                    "id": "#convert.cwl/output_refseq_organism"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*.hierarchy"
                    },
                    "id": "#convert.cwl/output_seed"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*.reduced"
                    },
                    "id": "#convert.cwl/output_seed_reduced"
                }
            ],
            "id": "#convert.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-00-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "label": "Illumina read quality control, trimming and contamination filter.",
            "doc": "**Workflow for Illumina paired read quality control, trimming and filtering.**<br />\nMultiple paired datasets will be merged into single paired dataset.<br />\nSummary:\n- FastQC on raw data files<br />\n- fastp for read quality trimming<br />\n- BBduk for phiX and (optional) rRNA filtering<br />\n- Kraken2 for taxonomic classification of reads (optional)<br />\n- BBmap for (contamination) filtering using given references (optional)<br />\n- FastQC on filtered (merged) data<br />\n\nOther UNLOCK workflows on WorkflowHub: https://workflowhub.eu/projects/16/workflows?view=default<br><br>\n\n**All tool CWL files and other workflows can be found here:**<br>\n  Tools: https://gitlab.com/m-unlock/cwl<br>\n  Workflows: https://gitlab.com/m-unlock/cwl/workflows<br>\n\n**How to setup and use an UNLOCK workflow:**<br>\nhttps://m-unlock.gitlab.io/docs/setup/setup.html<br>\n",
            "outputs": [
                {
                    "type": "File",
                    "label": "Filtered forward read",
                    "doc": "Filtered forward read",
                    "outputSource": "#workflow_illumina_quality.cwl/phix_filter/out_forward_reads",
                    "id": "#workflow_illumina_quality.cwl/QC_forward_reads"
                },
                {
                    "type": "File",
                    "label": "Filtered reverse read",
                    "doc": "Filtered reverse read",
                    "outputSource": "#workflow_illumina_quality.cwl/phix_filter/out_reverse_reads",
                    "id": "#workflow_illumina_quality.cwl/QC_reverse_reads"
                },
                {
                    "type": "Directory",
                    "label": "Filtering reports folder",
                    "doc": "Folder containing all reports of filtering and quality control",
                    "outputSource": "#workflow_illumina_quality.cwl/reports_files_to_folder/results",
                    "id": "#workflow_illumina_quality.cwl/reports_folder"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "doc": "Remove exact duplicate reads with fastp",
                    "label": "Deduplicate reads",
                    "default": false,
                    "id": "#workflow_illumina_quality.cwl/deduplicate"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "label": "Output Destination",
                    "doc": "Optional output destination only used for cwl-prov reporting.",
                    "id": "#workflow_illumina_quality.cwl/destination"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "doc": "References fasta file(s) for filtering",
                    "label": "Filter reference file(s)",
                    "loadListing": "no_listing",
                    "id": "#workflow_illumina_quality.cwl/filter_references"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "doc": "Optionally remove rRNA sequences from the reads (default false)",
                    "label": "filter rRNA",
                    "default": false,
                    "id": "#workflow_illumina_quality.cwl/filter_rrna"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Forward sequence fastq file(s) locally",
                    "label": "Forward reads",
                    "loadListing": "no_listing",
                    "id": "#workflow_illumina_quality.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#workflow_illumina_quality.cwl/identifier"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "doc": "Keep with reads mapped to the given reference (default false)",
                    "label": "Keep mapped reads",
                    "default": false,
                    "id": "#workflow_illumina_quality.cwl/keep_reference_mapped_reads"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "label": "Kraken2 confidence threshold",
                    "doc": "Confidence score threshold (default 0.0) must be between [0, 1]",
                    "id": "#workflow_illumina_quality.cwl/kraken2_confidence"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "Directory"
                        }
                    ],
                    "label": "Kraken2 database",
                    "doc": "Kraken2 database location, multiple databases is possible",
                    "default": [],
                    "loadListing": "no_listing",
                    "id": "#workflow_illumina_quality.cwl/kraken2_database"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "Maximum memory usage in MegaBytes",
                    "label": "Maximum memory in MB",
                    "default": 4000,
                    "id": "#workflow_illumina_quality.cwl/memory"
                },
                {
                    "type": "boolean",
                    "doc": "Prepare references to a single fasta file and unique headers (default true).\nWhen false a single fasta file as reference is expected with unique headers\n",
                    "label": "Prepare references",
                    "default": true,
                    "id": "#workflow_illumina_quality.cwl/prepare_reference"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Reverse sequence fastq file(s) locally",
                    "label": "Reverse reads",
                    "loadListing": "no_listing",
                    "id": "#workflow_illumina_quality.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "doc": "Skip FastQC analyses of raw input data (default false)",
                    "label": "Skip FastQC before",
                    "default": false,
                    "id": "#workflow_illumina_quality.cwl/skip_fastqc_before"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "Step number for output folder numbering (default 1)",
                    "label": "Output Step number",
                    "default": 1,
                    "id": "#workflow_illumina_quality.cwl/step"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "Number of threads to use for computational processes",
                    "label": "Number of threads",
                    "default": 2,
                    "id": "#workflow_illumina_quality.cwl/threads"
                }
            ],
            "steps": [
                {
                    "label": "fastp",
                    "doc": "Read quality filtering and (barcode) trimming.",
                    "run": "#fastp.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/deduplicate",
                            "id": "#workflow_illumina_quality.cwl/fastp/deduplicate"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/fastq_merge_fwd/output",
                                "#workflow_illumina_quality.cwl/fastq_fwd_array_to_file/file"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/fastp/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "id": "#workflow_illumina_quality.cwl/fastp/identifier"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/fastq_merge_rev/output",
                                "#workflow_illumina_quality.cwl/fastq_rev_array_to_file/file"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/fastp/reverse_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/fastp/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastp/out_forward_reads",
                        "#workflow_illumina_quality.cwl/fastp/out_reverse_reads",
                        "#workflow_illumina_quality.cwl/fastp/html_report",
                        "#workflow_illumina_quality.cwl/fastp/json_report"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastp"
                },
                {
                    "label": "Fwd reads array to file",
                    "doc": "Forward file of single file array to file object",
                    "when": "$(inputs.forward_reads.length === 1)",
                    "run": "#array_to_file.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/forward_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_fwd_array_to_file/files"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/forward_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_fwd_array_to_file/forward_reads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastq_fwd_array_to_file/file"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastq_fwd_array_to_file"
                },
                {
                    "label": "Merge forward reads",
                    "doc": "Merge multiple forward fastq reads to a single file",
                    "when": "$(inputs.forward_reads.length > 1)",
                    "run": "#concatenate.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/forward_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_fwd/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/forward_reads",
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_fwd/infiles"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self)_illumina_merged_1.fq.gz",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_fwd/outname"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastq_merge_fwd/output"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastq_merge_fwd"
                },
                {
                    "label": "Merge reverse reads",
                    "doc": "Merge multiple reverse fastq reads to a single file",
                    "when": "$(inputs.reverse_reads.length > 1)",
                    "run": "#concatenate.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/reverse_reads",
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_rev/infiles"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self)_illumina_merged_2.fq.gz",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_rev/outname"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/reverse_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_merge_rev/reverse_reads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastq_merge_rev/output"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastq_merge_rev"
                },
                {
                    "label": "Rev reads array to file",
                    "doc": "Forward file of single file array to file object",
                    "when": "$(inputs.reverse_reads.length === 1)",
                    "run": "#array_to_file.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/reverse_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_rev_array_to_file/files"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/reverse_reads",
                            "id": "#workflow_illumina_quality.cwl/fastq_rev_array_to_file/reverse_reads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastq_rev_array_to_file/file"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastq_rev_array_to_file"
                },
                {
                    "label": "FastQC after",
                    "doc": "Quality assessment and report of reads",
                    "run": "#fastqc.cwl",
                    "in": [
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/phix_filter/out_forward_reads",
                                "#workflow_illumina_quality.cwl/phix_filter/out_reverse_reads"
                            ],
                            "id": "#workflow_illumina_quality.cwl/fastqc_illumina_after/fastq"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/fastqc_illumina_after/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastqc_illumina_after/html_files",
                        "#workflow_illumina_quality.cwl/fastqc_illumina_after/zip_files"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastqc_illumina_after"
                },
                {
                    "label": "FastQC before",
                    "doc": "Quality assessment and report of reads",
                    "run": "#fastqc.cwl",
                    "when": "$(inputs.skip_fastqc_before == false)",
                    "in": [
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/forward_reads",
                                "#workflow_illumina_quality.cwl/reverse_reads"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_illumina_quality.cwl/fastqc_illumina_before/fastq"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/skip_fastqc_before",
                            "id": "#workflow_illumina_quality.cwl/fastqc_illumina_before/skip_fastqc_before"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/fastqc_illumina_before/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/fastqc_illumina_before/html_files",
                        "#workflow_illumina_quality.cwl/fastqc_illumina_before/zip_files"
                    ],
                    "id": "#workflow_illumina_quality.cwl/fastqc_illumina_before"
                },
                {
                    "label": "Kraken2",
                    "doc": "Taxonomic classification of FASTQ reads",
                    "when": "$(inputs.database !== null && inputs.database.length !== 0)",
                    "run": "#kraken2.cwl",
                    "scatter": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/database",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/kraken2_confidence",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/confidence"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/kraken2_database",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/database"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/rrna_filter/out_forward_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_forward_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self+\"illumina_quality_filtered\")",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/identifier"
                        },
                        {
                            "default": true,
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/paired_end"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/rrna_filter/out_reverse_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_reverse_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/reverse_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/illumina_quality_kraken2/sample_report"
                    ],
                    "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2"
                },
                {
                    "label": "Krona",
                    "doc": "Visualization of Kraken2 classification with Krona",
                    "when": "$(inputs.kraken2_database !== null && inputs.kraken2_database.length !== 0)",
                    "run": "#krona.cwl",
                    "scatter": "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona/kraken",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/illumina_quality_kraken2/sample_report",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona/kraken"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/kraken2_database",
                            "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona/kraken2_database"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona/krona_html"
                    ],
                    "id": "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona"
                },
                {
                    "label": "PhiX filter (bbduk)",
                    "doc": "Filters illumina spike-in PhiX sequences from reads using bbduk",
                    "run": "#bbduk_filter.cwl",
                    "in": [
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/reference_filter_illumina/out_forward_reads",
                                "#workflow_illumina_quality.cwl/rrna_filter/out_forward_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_forward_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self+\"_illumina_filtered\")",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/identifier"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/memory",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/memory"
                        },
                        {
                            "valueFrom": "/venv/opt/bbmap-39.01-0/resources/phix174_ill.ref.fa.gz",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/reference"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/reference_filter_illumina/out_reverse_reads",
                                "#workflow_illumina_quality.cwl/rrna_filter/out_reverse_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_reverse_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/reverse_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/phix_filter/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/phix_filter/out_forward_reads",
                        "#workflow_illumina_quality.cwl/phix_filter/out_reverse_reads",
                        "#workflow_illumina_quality.cwl/phix_filter/summary",
                        "#workflow_illumina_quality.cwl/phix_filter/stats_file"
                    ],
                    "id": "#workflow_illumina_quality.cwl/phix_filter"
                },
                {
                    "label": "Prepare references",
                    "doc": "Prepare references to a single fasta file and unique headers",
                    "when": "$(inputs.fasta_input !== null && inputs.fasta_input.length !== 0)",
                    "run": "#workflow_prepare_fasta_db.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/filter_references",
                            "id": "#workflow_illumina_quality.cwl/prepare_fasta_db/fasta_input"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/prepare_reference",
                            "id": "#workflow_illumina_quality.cwl/prepare_fasta_db/make_headers_unique"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "id": "#workflow_illumina_quality.cwl/prepare_fasta_db/output_name"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/prepare_fasta_db/fasta_db"
                    ],
                    "id": "#workflow_illumina_quality.cwl/prepare_fasta_db"
                },
                {
                    "label": "Reference read mapping",
                    "doc": "Map reads against references using BBMap",
                    "when": "$(inputs.filter_references !== null && inputs.filter_references.length !== 0)",
                    "run": "#bbmap_filter-reads.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/filter_references",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/filter_references"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/rrna_filter/out_forward_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_forward_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self+\"_ref-filter\")",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/identifier"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/memory",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/memory"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/keep_reference_mapped_reads",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/output_mapped"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/prepare_fasta_db/fasta_db",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/reference"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/rrna_filter/out_reverse_reads",
                                "#workflow_illumina_quality.cwl/fastp/out_reverse_reads"
                            ],
                            "pickValue": "first_non_null",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/reverse_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/reference_filter_illumina/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/reference_filter_illumina/out_forward_reads",
                        "#workflow_illumina_quality.cwl/reference_filter_illumina/out_reverse_reads",
                        "#workflow_illumina_quality.cwl/reference_filter_illumina/log",
                        "#workflow_illumina_quality.cwl/reference_filter_illumina/stats",
                        "#workflow_illumina_quality.cwl/reference_filter_illumina/covstats"
                    ],
                    "id": "#workflow_illumina_quality.cwl/reference_filter_illumina"
                },
                {
                    "label": "Reports to folder",
                    "doc": "Preparation of fastp output files to a specific output folder",
                    "run": "#files_to_folder.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/step",
                            "valueFrom": "$(self+\"_Illumina_Read_Quality\")",
                            "id": "#workflow_illumina_quality.cwl/reports_files_to_folder/destination"
                        },
                        {
                            "source": [
                                "#workflow_illumina_quality.cwl/fastqc_illumina_before/html_files",
                                "#workflow_illumina_quality.cwl/fastqc_illumina_before/zip_files",
                                "#workflow_illumina_quality.cwl/fastqc_illumina_after/html_files",
                                "#workflow_illumina_quality.cwl/fastqc_illumina_after/zip_files",
                                "#workflow_illumina_quality.cwl/fastp/html_report",
                                "#workflow_illumina_quality.cwl/fastp/json_report",
                                "#workflow_illumina_quality.cwl/reference_filter_illumina/stats",
                                "#workflow_illumina_quality.cwl/reference_filter_illumina/covstats",
                                "#workflow_illumina_quality.cwl/reference_filter_illumina/log",
                                "#workflow_illumina_quality.cwl/illumina_quality_kraken2/sample_report",
                                "#workflow_illumina_quality.cwl/illumina_quality_kraken2_krona/krona_html",
                                "#workflow_illumina_quality.cwl/phix_filter/summary",
                                "#workflow_illumina_quality.cwl/phix_filter/stats_file",
                                "#workflow_illumina_quality.cwl/rrna_filter/summary",
                                "#workflow_illumina_quality.cwl/rrna_filter/stats_file"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_illumina_quality.cwl/reports_files_to_folder/files"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/reports_files_to_folder/results"
                    ],
                    "id": "#workflow_illumina_quality.cwl/reports_files_to_folder"
                },
                {
                    "label": "rRNA filter (bbduk)",
                    "doc": "Filters rRNA sequences from reads using bbduk",
                    "when": "$(inputs.filter_rrna)",
                    "run": "#bbduk_filter.cwl",
                    "in": [
                        {
                            "source": "#workflow_illumina_quality.cwl/filter_rrna",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/filter_rrna"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/fastp/out_forward_reads",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/forward_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/identifier",
                            "valueFrom": "$(self+\"_rRNA-filter\")",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/identifier"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/memory",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/memory"
                        },
                        {
                            "valueFrom": "/venv/opt/bbmap-39.01-0/resources/riboKmers.fa.gz",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/reference"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/fastp/out_reverse_reads",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/reverse_reads"
                        },
                        {
                            "source": "#workflow_illumina_quality.cwl/threads",
                            "id": "#workflow_illumina_quality.cwl/rrna_filter/threads"
                        }
                    ],
                    "out": [
                        "#workflow_illumina_quality.cwl/rrna_filter/out_forward_reads",
                        "#workflow_illumina_quality.cwl/rrna_filter/out_reverse_reads",
                        "#workflow_illumina_quality.cwl/rrna_filter/summary",
                        "#workflow_illumina_quality.cwl/rrna_filter/stats_file"
                    ],
                    "id": "#workflow_illumina_quality.cwl/rrna_filter"
                }
            ],
            "id": "#workflow_illumina_quality.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2020-00-00",
            "https://schema.org/dateModified": "2023-01-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "label": "Metagenomics workflow",
            "doc": "Workflow for Metagenomics from raw reads to annotated bins.\nSteps:\n  - workflow_illumina_quality.cwl:\n    - FastQC (control)\n    - fastp (trimming)\n  - Diamond read blastx\n    - Refseq\n    - SEED\n  - SAMSA2 processing\n  - HUMAnN read annotation\n",
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "bbmap reference fasta file for contamination filtering",
                    "label": "contamination reference file",
                    "default": "/unlock/references/databases/bbduk/GCA_000001405.28_GRCh38.p13_genomic.fna.gz",
                    "id": "#main/bbmap_reference"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "label": "Output Destination",
                    "doc": "Optional Output destination used for cwl-prov reporting.",
                    "id": "#main/destination"
                },
                {
                    "type": "boolean",
                    "doc": "rRNA read filtering using ...",
                    "label": "rRNA filtering",
                    "default": false,
                    "id": "#main/filter_rrna"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "forward sequence file locally",
                    "label": "forward reads",
                    "id": "#main/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#main/identifier"
                },
                {
                    "type": "string",
                    "doc": "database location of kraken2",
                    "label": "Kraken2 database",
                    "id": "#main/kraken_database"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "maximum memory usage in megabytes",
                    "label": "memory usage (mb)",
                    "default": 4000,
                    "id": "#main/memory"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "reverse sequence file locally",
                    "label": "reverse reads",
                    "id": "#main/reverse_reads"
                },
                {
                    "type": "boolean",
                    "label": "Run SAMSA2",
                    "doc": "Run SAMSA2 functional read classification",
                    "default": false,
                    "id": "#main/run_samsa2"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "label": "CWL base step number",
                    "doc": "Step number for order of steps",
                    "default": 1,
                    "id": "#main/step"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "number of threads to use for computational processes",
                    "label": "number of threads",
                    "default": 2,
                    "id": "#main/threads"
                }
            ],
            "outputs": [
                {
                    "label": "Filtered statistics",
                    "doc": "Statistics on quality and preprocessing of the reads",
                    "type": "Directory",
                    "outputSource": "#main/workflow_quality/reports_to_folder",
                    "id": "#main/filtered_stats"
                },
                {
                    "label": "HUMAnN",
                    "doc": "HUMAnN output",
                    "type": "Directory",
                    "outputSource": "#main/humann_files_to_folder/results",
                    "id": "#main/humann_output"
                },
                {
                    "label": "Kraken2",
                    "doc": "Classification output folder by kraken2",
                    "type": "Directory",
                    "outputSource": "#main/kraken_files_to_folder/results",
                    "id": "#main/kraken2_output"
                },
                {
                    "label": "samsa2",
                    "doc": "samsa2 output",
                    "type": [
                        "null",
                        "Directory"
                    ],
                    "outputSource": "#main/workflow_samsa2/samsa2_output",
                    "id": "#main/samsa2_output"
                }
            ],
            "steps": [
                {
                    "label": "Compress large kraken2 output file",
                    "doc": "Converts the diamond binary output file into a tabular output file",
                    "run": "#pigz.cwl",
                    "in": [
                        {
                            "source": "#main/workflow_kraken2/kraken",
                            "id": "#main/compress_kraken2/inputfile"
                        },
                        {
                            "source": "#main/threads",
                            "id": "#main/compress_kraken2/threads"
                        }
                    ],
                    "out": [
                        "#main/compress_kraken2/outfile"
                    ],
                    "id": "#main/compress_kraken2"
                },
                {
                    "label": "Compress large kraken2 output file",
                    "doc": "Converts the diamond binary output file into a tabular output file",
                    "run": "#fastq_to_fasta.cwl",
                    "in": [
                        {
                            "source": [
                                "#main/workflow_quality/QC_forward_reads",
                                "#main/workflow_quality/QC_reverse_reads"
                            ],
                            "id": "#main/fastq_to_fasta/fastq_files"
                        },
                        {
                            "source": "#main/identifier",
                            "id": "#main/fastq_to_fasta/identifier"
                        }
                    ],
                    "out": [
                        "#main/fastq_to_fasta/fasta_out"
                    ],
                    "id": "#main/fastq_to_fasta"
                },
                {
                    "doc": "Preparation of HUMAnN output files to a specific output folder",
                    "label": "HUMAnN output folder",
                    "run": "#files_to_folder.cwl",
                    "in": [
                        {
                            "valueFrom": "${\n  var step = inputs.step;\n  step = step + 1;\n  return step+\"_HUMAnN\";\n}\n",
                            "id": "#main/humann_files_to_folder/destination"
                        },
                        {
                            "source": [
                                "#main/workflow_humann/genefamilies_out",
                                "#main/workflow_humann/pathabundance_out",
                                "#main/workflow_humann/pathcoverage_out",
                                "#main/workflow_humann/log_out",
                                "#main/workflow_humann/stdout_out"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#main/humann_files_to_folder/files"
                        },
                        {
                            "source": "#main/step",
                            "id": "#main/humann_files_to_folder/step"
                        }
                    ],
                    "out": [
                        "#main/humann_files_to_folder/results"
                    ],
                    "id": "#main/humann_files_to_folder"
                },
                {
                    "doc": "Preparation of kraken output files to a specific output folder",
                    "label": "Kraken2 output folder",
                    "run": "#files_to_folder.cwl",
                    "in": [
                        {
                            "valueFrom": "${\n  var step = inputs.step;\n  step = step + 1;\n  return step+\"_Kraken2\";\n}\n",
                            "id": "#main/kraken_files_to_folder/destination"
                        },
                        {
                            "source": [
                                "#main/compress_kraken2/outfile",
                                "#main/workflow_kraken2/report"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#main/kraken_files_to_folder/files"
                        },
                        {
                            "source": "#main/step",
                            "id": "#main/kraken_files_to_folder/step"
                        }
                    ],
                    "out": [
                        "#main/kraken_files_to_folder/results"
                    ],
                    "id": "#main/kraken_files_to_folder"
                },
                {
                    "label": "HUMAnN",
                    "doc": "Taxonomic and functional classification using HUMAnN",
                    "run": "#humann.cwl",
                    "in": [
                        {
                            "source": "#main/fastq_to_fasta/fasta_out",
                            "id": "#main/workflow_humann/fasta"
                        },
                        {
                            "source": "#main/identifier",
                            "id": "#main/workflow_humann/identifier"
                        },
                        {
                            "source": "#main/threads",
                            "id": "#main/workflow_humann/threads"
                        }
                    ],
                    "out": [
                        "#main/workflow_humann/genefamilies_out",
                        "#main/workflow_humann/pathabundance_out",
                        "#main/workflow_humann/pathcoverage_out",
                        "#main/workflow_humann/log_out",
                        "#main/workflow_humann/stdout_out"
                    ],
                    "id": "#main/workflow_humann"
                },
                {
                    "label": "Kraken2 workflow",
                    "doc": "Read classification using the kraken2 database",
                    "run": "#kraken2.cwl",
                    "in": [
                        {
                            "source": "#main/kraken_database",
                            "id": "#main/workflow_kraken2/database"
                        },
                        {
                            "source": "#main/workflow_quality/QC_forward_reads",
                            "id": "#main/workflow_kraken2/forward_reads"
                        },
                        {
                            "source": "#main/identifier",
                            "id": "#main/workflow_kraken2/identifier"
                        },
                        {
                            "source": "#main/workflow_quality/QC_reverse_reads",
                            "id": "#main/workflow_kraken2/reverse_reads"
                        },
                        {
                            "source": "#main/threads",
                            "id": "#main/workflow_kraken2/threads"
                        }
                    ],
                    "out": [
                        "#main/workflow_kraken2/kraken",
                        "#main/workflow_kraken2/report"
                    ],
                    "id": "#main/workflow_kraken2"
                },
                {
                    "label": "Quality and filtering workflow",
                    "doc": "Quality assessment of illumina reads with rRNA filtering option",
                    "run": "#workflow_illumina_quality.cwl",
                    "in": [
                        {
                            "source": "#main/bbmap_reference",
                            "id": "#main/workflow_quality/bbmap_reference"
                        },
                        {
                            "source": "#main/filter_rrna",
                            "id": "#main/workflow_quality/filter_rrna"
                        },
                        {
                            "source": "#main/forward_reads",
                            "id": "#main/workflow_quality/forward_reads"
                        },
                        {
                            "source": "#main/identifier",
                            "id": "#main/workflow_quality/identifier"
                        },
                        {
                            "source": "#main/memory",
                            "id": "#main/workflow_quality/memory"
                        },
                        {
                            "source": "#main/reverse_reads",
                            "id": "#main/workflow_quality/reverse_reads"
                        },
                        {
                            "source": "#main/step",
                            "id": "#main/workflow_quality/step"
                        },
                        {
                            "source": "#main/threads",
                            "id": "#main/workflow_quality/threads"
                        }
                    ],
                    "out": [
                        "#main/workflow_quality/QC_reverse_reads",
                        "#main/workflow_quality/QC_forward_reads",
                        "#main/workflow_quality/reports_to_folder"
                    ],
                    "id": "#main/workflow_quality"
                },
                {
                    "label": "SAMSA2",
                    "doc": "functional read classification using SAMSA2",
                    "when": "$(inputs.run_samsa2)",
                    "run": "#workflow_samsa2.cwl",
                    "in": [
                        {
                            "source": "#main/workflow_quality/QC_forward_reads",
                            "id": "#main/workflow_samsa2/forward_reads"
                        },
                        {
                            "source": "#main/identifier",
                            "id": "#main/workflow_samsa2/identifier"
                        },
                        {
                            "source": "#main/workflow_quality/QC_reverse_reads",
                            "id": "#main/workflow_samsa2/reverse_reads"
                        },
                        {
                            "source": "#main/run_samsa2",
                            "id": "#main/workflow_samsa2/run_samsa2"
                        },
                        {
                            "valueFrom": "${\n  var step = inputs.step;\n  return step + 1;\n}\n",
                            "id": "#main/workflow_samsa2/step"
                        },
                        {
                            "source": "#main/threads",
                            "id": "#main/workflow_samsa2/threads"
                        }
                    ],
                    "out": [
                        "#main/workflow_samsa2/samsa2_output"
                    ],
                    "id": "#main/workflow_samsa2"
                }
            ],
            "id": "#main",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2020-00-00",
            "https://schema.org/dateModified": "2022-05-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "label": "Prepare (multiple) fasta files to one file.",
            "doc": "Prepare (multiple) fasta files to one file. \nWith option to make unique headers to avoid same fasta headers, which can break some tools.\n",
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "label": "Fasta input",
                    "doc": "Fasta file(s) to prepare",
                    "id": "#workflow_prepare_fasta_db.cwl/fasta_input"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "label": "Make headers unique",
                    "doc": "Make fasta headers unique avoiding same fasta headers, which can break some tools.",
                    "default": false,
                    "id": "#workflow_prepare_fasta_db.cwl/make_headers_unique"
                },
                {
                    "type": "string",
                    "doc": "Output name for this dataset used",
                    "label": "identifier used",
                    "id": "#workflow_prepare_fasta_db.cwl/output_name"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "label": "Prepared fasta file",
                    "doc": "Prepared fasta file",
                    "outputSource": [
                        "#workflow_prepare_fasta_db.cwl/fasta_array_to_file/file",
                        "#workflow_prepare_fasta_db.cwl/merge_input/output",
                        "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/fasta_db"
                    ],
                    "pickValue": "first_non_null",
                    "id": "#workflow_prepare_fasta_db.cwl/fasta_db"
                }
            ],
            "steps": [
                {
                    "label": "Array to file",
                    "doc": "Pick first file of filter_reference when make_headers_unique input is false",
                    "when": "$(inputs.make_headers_unique === false && inputs.fasta_input.length === 1)",
                    "run": "#array_to_file.cwl",
                    "in": [
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/fasta_array_to_file/fasta_input"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/fasta_array_to_file/files"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/make_headers_unique",
                            "id": "#workflow_prepare_fasta_db.cwl/fasta_array_to_file/make_headers_unique"
                        }
                    ],
                    "out": [
                        "#workflow_prepare_fasta_db.cwl/fasta_array_to_file/file"
                    ],
                    "id": "#workflow_prepare_fasta_db.cwl/fasta_array_to_file"
                },
                {
                    "label": "Merge reference files",
                    "doc": "Only merge input when make unique is false.",
                    "when": "$(inputs.make_headers_unique === false && inputs.fasta_input.length > 1)",
                    "run": "#concatenate.cwl",
                    "in": [
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/merge_input/fasta_input"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/merge_input/infiles"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/make_headers_unique",
                            "id": "#workflow_prepare_fasta_db.cwl/merge_input/make_headers_unique"
                        },
                        {
                            "valueFrom": "$(inputs.output_name)_filter-reference_merged.fa",
                            "id": "#workflow_prepare_fasta_db.cwl/merge_input/outname"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/output_name",
                            "id": "#workflow_prepare_fasta_db.cwl/merge_input/output_name"
                        }
                    ],
                    "out": [
                        "#workflow_prepare_fasta_db.cwl/merge_input/output"
                    ],
                    "id": "#workflow_prepare_fasta_db.cwl/merge_input"
                },
                {
                    "label": "Prepare references",
                    "doc": "Prepare references to a single fasta file and unique headers",
                    "when": "$(inputs.make_headers_unique)",
                    "run": "#prepare_fasta_db.cwl",
                    "in": [
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/fasta_files"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/fasta_input",
                            "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/fasta_input"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/make_headers_unique",
                            "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/make_headers_unique"
                        },
                        {
                            "valueFrom": "$(inputs.output_name)_filter-reference_uniq.fa.gz",
                            "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/output_file_name"
                        },
                        {
                            "source": "#workflow_prepare_fasta_db.cwl/output_name",
                            "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/output_name"
                        }
                    ],
                    "out": [
                        "#workflow_prepare_fasta_db.cwl/prepare_fasta_db/fasta_db"
                    ],
                    "id": "#workflow_prepare_fasta_db.cwl/prepare_fasta_db"
                }
            ],
            "id": "#workflow_prepare_fasta_db.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2023-01-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "label": "SAMSA2 pipeline",
            "doc": "SAMSA2 complete workflow for meta-omics read annotation\nSteps:\n  - Diamond read blastx\n    - Refseq\n    - SEED\n  - SAMSA2 processing\n",
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "label": "Output Destination",
                    "doc": "Optional Output destination used for cwl-prov reporting.",
                    "id": "#workflow_samsa2.cwl/destination"
                },
                {
                    "type": "File",
                    "doc": "forward sequence file locally",
                    "label": "forward reads",
                    "id": "#workflow_samsa2.cwl/forward_reads"
                },
                {
                    "type": "string",
                    "doc": "Identifier for this dataset used in this workflow",
                    "label": "identifier used",
                    "id": "#workflow_samsa2.cwl/identifier"
                },
                {
                    "type": "File",
                    "doc": "reverse sequence file locally",
                    "label": "reverse reads",
                    "id": "#workflow_samsa2.cwl/reverse_reads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "label": "CWL base step number",
                    "doc": "Step number for order of steps",
                    "default": 3,
                    "id": "#workflow_samsa2.cwl/step"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "number of threads to use for computational processes",
                    "label": "number of threads",
                    "default": 2,
                    "id": "#workflow_samsa2.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "label": "SAMSA2",
                    "doc": "functional and classification output folder by samsa2",
                    "type": "Directory",
                    "outputSource": "#workflow_samsa2.cwl/samsa2_files_to_folder/results",
                    "id": "#workflow_samsa2.cwl/samsa2_output"
                }
            ],
            "steps": [
                {
                    "label": "Compress large output files",
                    "doc": "Converts the diamond binary output file into a tabular output file",
                    "run": "#pigz.cwl",
                    "scatter": [
                        "#workflow_samsa2.cwl/compress_diamond/inputfile"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": [
                                "#workflow_samsa2.cwl/workflow_diamond_refseq/output_diamond",
                                "#workflow_samsa2.cwl/workflow_diamond_seed/output_diamond"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_samsa2.cwl/compress_diamond/inputfile"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/threads",
                            "id": "#workflow_samsa2.cwl/compress_diamond/threads"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/compress_diamond/outfile"
                    ],
                    "id": "#workflow_samsa2.cwl/compress_diamond"
                },
                {
                    "doc": "Preparation of samsa2 output files to a specific output folder",
                    "label": "SAMSA2 output files",
                    "run": "#files_to_folder.cwl",
                    "in": [
                        {
                            "valueFrom": "${inputs.step+\"_SAMSA2\"}",
                            "id": "#workflow_samsa2.cwl/samsa2_files_to_folder/destination"
                        },
                        {
                            "source": [
                                "#workflow_samsa2.cwl/compress_diamond/outfile",
                                "#workflow_samsa2.cwl/samsa2_postscripts/output_refseq_function",
                                "#workflow_samsa2.cwl/samsa2_postscripts/output_refseq_organism",
                                "#workflow_samsa2.cwl/samsa2_postscripts/output_seed",
                                "#workflow_samsa2.cwl/samsa2_postscripts/output_seed_reduced"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_samsa2.cwl/samsa2_files_to_folder/files"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/step",
                            "id": "#workflow_samsa2.cwl/samsa2_files_to_folder/step"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/samsa2_files_to_folder/results"
                    ],
                    "id": "#workflow_samsa2.cwl/samsa2_files_to_folder"
                },
                {
                    "label": "Run SAMSA2 post scripts",
                    "doc": "Converts the diamond output file to samsa2 tables",
                    "run": "#convert.cwl",
                    "scatter": [
                        "#workflow_samsa2.cwl/samsa2_postscripts/inputfile"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": "#workflow_samsa2.cwl/identifier",
                            "id": "#workflow_samsa2.cwl/samsa2_postscripts/identifier"
                        },
                        {
                            "source": [
                                "#workflow_samsa2.cwl/workflow_diamond_view/output_diamond_tabular"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_samsa2.cwl/samsa2_postscripts/inputfile"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/samsa2_postscripts/output_refseq_function",
                        "#workflow_samsa2.cwl/samsa2_postscripts/output_refseq_organism",
                        "#workflow_samsa2.cwl/samsa2_postscripts/output_seed",
                        "#workflow_samsa2.cwl/samsa2_postscripts/output_seed_reduced"
                    ],
                    "id": "#workflow_samsa2.cwl/samsa2_postscripts"
                },
                {
                    "label": "Diamond refseq workflow",
                    "doc": "Read mapping using the refseq database",
                    "run": "#diamond.cwl",
                    "in": [
                        {
                            "default": "/unlock/references/databases/ncbi/Refseq_Bacterial/diamond/ncbi-bact-refseq_28-01-2020_proteins.dmnd",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/database"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/forward_reads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/forward_reads"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/identifier",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/identifier"
                        },
                        {
                            "default": 1,
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/maxtargetseq"
                        },
                        {
                            "valueFrom": "$(inputs.identifier)_refseq",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/output"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/reverse_reads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/reverse_reads"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/threads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_refseq/threads"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/workflow_diamond_refseq/output_diamond"
                    ],
                    "id": "#workflow_samsa2.cwl/workflow_diamond_refseq"
                },
                {
                    "label": "Diamond seed workflow",
                    "doc": "Read mapping using the seed database",
                    "run": "#diamond.cwl",
                    "in": [
                        {
                            "default": "/unlock/references/databases/SEED/diamond/seed_subsystems_db.dmnd",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/database"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/forward_reads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/forward_reads"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/identifier",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/identifier"
                        },
                        {
                            "default": 1,
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/maxtargetseq"
                        },
                        {
                            "valueFrom": "$(inputs.identifier)_seed",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/output"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/reverse_reads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/reverse_reads"
                        },
                        {
                            "source": "#workflow_samsa2.cwl/threads",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_seed/threads"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/workflow_diamond_seed/output_diamond"
                    ],
                    "id": "#workflow_samsa2.cwl/workflow_diamond_seed"
                },
                {
                    "label": "Change view of diamond binary to tabular",
                    "doc": "Converts the diamond binary output file into a tabular output file",
                    "run": "#view.cwl",
                    "scatter": [
                        "#workflow_samsa2.cwl/workflow_diamond_view/inputfile"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": [
                                "#workflow_samsa2.cwl/workflow_diamond_refseq/output_diamond",
                                "#workflow_samsa2.cwl/workflow_diamond_seed/output_diamond"
                            ],
                            "linkMerge": "merge_flattened",
                            "pickValue": "all_non_null",
                            "id": "#workflow_samsa2.cwl/workflow_diamond_view/inputfile"
                        }
                    ],
                    "out": [
                        "#workflow_samsa2.cwl/workflow_diamond_view/output_diamond_tabular"
                    ],
                    "id": "#workflow_samsa2.cwl/workflow_diamond_view"
                }
            ],
            "id": "#workflow_samsa2.cwl",
            "https://schema.org/author": [
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-8172-8981",
                    "https://schema.org/email": "mailto:jasper.koehorst@wur.nl",
                    "https://schema.org/name": "Jasper Koehorst"
                },
                {
                    "class": "https://schema.org/Person",
                    "https://schema.org/identifier": "https://orcid.org/0000-0001-9524-5964",
                    "https://schema.org/email": "mailto:bart.nijsse@wur.nl",
                    "https://schema.org/name": "Bart Nijsse"
                }
            ],
            "https://schema.org/citation": "https://m-unlock.nl",
            "https://schema.org/codeRepository": "https://gitlab.com/m-unlock/cwl",
            "https://schema.org/dateCreated": "2021-09-00",
            "https://schema.org/dateModified": "2022-05-00",
            "https://schema.org/license": "https://spdx.org/licenses/Apache-2.0",
            "https://schema.org/copyrightHolder": "UNLOCK - Unlocking Microbial Potential"
        }
    ],
    "cwlVersion": "v1.2",
    "$namespaces": {
        "s": "https://schema.org/"
    }
}