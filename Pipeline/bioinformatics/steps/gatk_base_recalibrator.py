from Pipeline.bioinformatics.data_types.bed import Bed
from Pipeline.bioinformatics.data_types.fasta import Fasta
from Pipeline import File, String, Array, CommandTool, ToolOutput, ToolInput


class GatkBaseRecalibrator(CommandTool):

    inputBam_BaseRecalibrator = ToolInput("inputBam_BaseRecalibrator", File())
    outputfile_BaseRecalibrator = ToolInput("outputfile_BaseRecalibrator", String())
    reference = ToolInput("reference", Fasta())
    known = ToolInput("known", Array(File()))
    bedFile = ToolInput("bedFile", Bed())

    out = ToolOutput("out", File())

    @staticmethod
    def tool():
        return "gatk-base-recalibrator"

    @staticmethod
    def base_command():
        return "javac"
