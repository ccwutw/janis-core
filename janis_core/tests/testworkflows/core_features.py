

from janis_core import (
    Workflow,
    ScatterDescription,
    ScatterMethods
)

from janis_core.types import (
    String,
    File,
    Array,
    Int,
    Boolean,
)
from janis_bioinformatics.data_types.bam import BamBai
from janis_core.tests.testtools import (
    FileTestTool,
    StringTestTool,
    IntTestTool,
    ComponentsTestTool,
    SecondariesTestTool,

    ArrayFileTestTool,
    ArrayIntTestTool,
    ArrayStringTestTool,

    ArrayComponentsTestTool,
    ArraySecondariesTestTool,
)



# ------------- #
#  BASIC TYPES  #
# ------------- #

# BasicInTypesTestWF 
# File, String, Int workflow inputs & tool inputs 

class BasicIOTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)

        self.step(
            "stp1", 
            FileTestTool(inp=self.inFile)
        )
        self.step(
            "stp2", 
            StringTestTool(inp=self.inString)
        )
        self.step(
            "stp3", 
            IntTestTool(inp=self.inInt)
        )

        self.output("outFile", File, source=self.stp1.out)
        self.output("outString", File, source=self.stp1.out)
        self.output("outInt", File, source=self.stp3.out)

    def friendly_name(self):
        return "TEST: BasicIOTestWF"

    def id(self) -> str:
        return self.__class__.__name__


# StepInputsTestWF
# calling same tool with different step inputs

class StepInputsTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)
        self.input('inBool', Boolean)

        # full inputs
        self.step(
            "stp1", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                pos_default=self.inInt,
                pos_optional=self.inString,
                flag_true=self.inBool,
                flag_false=self.inBool,
                opt_basic=self.inString,
                opt_default=self.inInt,
                opt_optional=self.inString,
            )
        )
        # full inputs static
        self.step(
            "stp2", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                pos_default=100,
                pos_optional="static",
                flag_true=False,
                flag_false=True,
                opt_basic="static",
                opt_default=100,
                opt_optional='',
            )
        )
        # partial inputs static
        self.step(
            "stp3", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                opt_basic="static",
                opt_default=100,
                opt_optional='',
            )
        )
        # minimal inputs
        self.step(
            "stp4", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                opt_basic=self.inString,
            )
        )

        self.output("outFile1", File, source=self.stp1.out)
        self.output("outFile2", File, source=self.stp2.out)
        self.output("outFile3", File, source=self.stp3.out)
        self.output("outFile4", File, source=self.stp4.out)

    def friendly_name(self):
        return "TEST: StepInputsTestWF"

    def id(self) -> str:
        return self.__class__.__name__


class StepInputsWFInputTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)
        self.input('inBool', Boolean)

        # full inputs
        self.step(
            "stp1", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                pos_default=self.inInt,
                pos_optional=self.inString,
                flag_true=self.inBool,
                flag_false=self.inBool,
                opt_basic=self.inString,
                opt_default=self.inInt,
                opt_optional=self.inString,
            )
        )
        self.output("outFile1", File, source=self.stp1.out)

    def friendly_name(self):
        return "TEST: StepInputsWFInputTestWF"

    def id(self) -> str:
        return self.__class__.__name__


class StepInputsStaticTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)
        self.input('inBool', Boolean)

        # full inputs static
        self.step(
            "stp2", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                pos_default=100,
                pos_optional="static",
                flag_true=False,
                flag_false=True,
                opt_basic="static",
                opt_default=100,
                opt_optional='',
            )
        )

        self.output("outFile2", File, source=self.stp2.out)

    def friendly_name(self):
        return "TEST: StepInputsStaticTestWF"

    def id(self) -> str:
        return self.__class__.__name__


class StepInputsPartialStaticTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)
        self.input('inBool', Boolean)

        # partial inputs static
        self.step(
            "stp3", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                opt_basic="static",
                opt_default=100,
                opt_optional='',
            )
        )

        self.output("outFile3", File, source=self.stp3.out)

    def friendly_name(self):
        return "TEST: StepInputsMinimalTestWF"

    def id(self) -> str:
        return self.__class__.__name__


class StepInputsMinimalTestWF(Workflow):

    def constructor(self):
        self.input('inFile', File)
        self.input('inString', String)
        self.input('inInt', Int)
        self.input('inBool', Boolean)

        # minimal inputs
        self.step(
            "stp4", 
            ComponentsTestTool(
                pos_basic=self.inFile,
                opt_basic=self.inString,
            )
        )
        self.output("outFile4", File, source=self.stp4.out)

    def friendly_name(self):
        return "TEST: StepInputsMinimalTestWF"

    def id(self) -> str:
        return self.__class__.__name__




# ConnectionsTestWF 
# File, String, Int workflow inputs & tool inputs 

class StepConnectionsTestWF(Workflow):

    def constructor(self):
        self.input('inString', String)
        self.input('inFile', File)
        self.input('inInt', Int)

        self.step(
            "stp1", 
            StringTestTool(inp=self.inString)
        )
        self.step(
            "stp2", 
            FileTestTool(inp=self.stp1.out)
        )

        self.output("outString", File, source=self.stp1.out)
        self.output("outFile", File, source=self.stp2.out)

    def friendly_name(self):
        return "TEST: StepConnectionsTestWF"

    def id(self) -> str:
        return self.__class__.__name__



# -------- #
#  ARRAYS  #
# -------- #

# BasicArrayInOutTypesTestWF 
# File, String, Int workflow & tool inputs / outputs

class ArrayIOTestWF(Workflow):

    def constructor(self):
        self.input('inStrArray', Array(String))
        self.input('inFileArray', Array(File))
        self.input('inIntArray', Array(Int))
        self.step(
            "stp1",
            ArrayStringTestTool(
                ins=self.inStrArray,
            ),
        )
        self.step(
            "stp2",
            ArrayFileTestTool(
                ins=self.inFileArray,
            ),
        )
        self.step(
            "stp3",
            ArrayIntTestTool(
                ins=self.inIntArray,
            ),
        )
        self.output("outStrings", source=self.stp1.outs)
        self.output("outFiles", source=self.stp2.outs)
        self.output("outInts", source=self.stp3.outs)

    def friendly_name(self):
        return "TEST: ArrayIOTestWF"

    def id(self) -> str:
        return self.__class__.__name__



# ArrayStepInputsTestWF
# calling same tool with different step input arrays
class ArrayStepInputsTestWF(Workflow):

    def constructor(self):
        self.input('inFileArray', Array(File))
        self.input('inStrArray', Array(String))
        self.input('inIntArray', Array(Int))
        self.input('inBoolArray', Array(Boolean))

        # full inputs
        self.step(
            "stp1",
            ArrayComponentsTestTool(
                pos_basic=self.inFileArray,
                pos_default=self.inStrArray,
                pos_optional=self.inStrArray,
                flag_true=self.inBoolArray,
                flag_false=self.inBoolArray,
                opt_basic=self.inStrArray,
                opt_default=self.inStrArray,
                opt_optional=self.inStrArray,
            )
        )
        # full inputs static
        self.step(
            "stp2", 
            ArrayComponentsTestTool(
                pos_basic=self.inFileArray,
                pos_default=["hi", "there", "friend"],
                pos_optional=["hi", "there", "friend"],
                flag_true=[True],
                flag_false=[True],
                opt_basic=["hi", "there", "friend"],
                opt_default=["hi", "there", "friend"],
                opt_optional=["hi", "there", "friend"],
            )
        )
        # minimal inputs
        self.step(
            "stp3", 
            ArrayComponentsTestTool(
                pos_basic=self.inFileArray,
                opt_basic=self.inStrArray,
            )
        )

        self.output("outFile1", File, source=self.stp1.out)
        self.output("outFile2", File, source=self.stp2.out)
        self.output("outFile3", File, source=self.stp3.out)

    def friendly_name(self):
        return "TEST: ArrayStepInputsTestWF"

    def id(self) -> str:
        return self.__class__.__name__


# ArrayStepConnectionsTestWF 
# Array(File) step io connections
# janis does not allow non-file outputs, so can't test
# Array(String) -> Array(String) step connections. 

class ArrayStepConnectionsTestWF(Workflow):

    def constructor(self):
        self.input('inStrArray', Array(String))
        self.input('inFileArray', Array(File))
        self.input('inIntArray', Array(Int))

        self.step(
            "stp1",
            ArrayFileTestTool(
                ins=self.inFileArray,
            ),
        )
        self.step(
            "stp2",
            ArrayFileTestTool(
                ins=self.stp1.outs,
            ),
        )
        self.output("outFiles1", source=self.stp1.outs)
        self.output("outFiles2", source=self.stp2.outs)

    def friendly_name(self):
        return "TEST: ArrayStepConnectionsTestWF"

    def id(self) -> str:
        return self.__class__.__name__





# --------- #
#  SCATTER  #
# --------- #

# BasicScatterTestWF
# Scatter with no chaining

class BasicScatterTestWF(Workflow):

    def constructor(self):
        self.input('inStrArray', Array(String))
        self.input('inFileArray', Array(File))
        self.input('inIntArray', Array(Int))

        self.step(
            "stp1", 
            FileTestTool(inp=self.inFileArray),
            scatter="inp"
        )
        self.step(
            "stp2", 
            StringTestTool(inp=self.inStrArray),
            scatter="inp"
        )
        self.step(
            "stp3", 
            IntTestTool(inp=self.inIntArray),
            scatter="inp"
        )

        self.output("outFile", Array(File), source=self.stp1.out)
        self.output("outString", Array(File), source=self.stp2.out)
        self.output("outInt", Array(File), source=self.stp3.out)

    def friendly_name(self):
        return "TEST: BasicScatterTestWF"

    def id(self) -> str:
        return self.__class__.__name__


# ChainedScatterTestWF
# Scatter with subsequent consuming steps 

class ChainedScatterTestWF(Workflow):

    def constructor(self):
        self.input('inStrArray', Array(String))
        self.input('inFileArray', Array(File))
        self.input('inIntArray', Array(Int))

        self.step(
            "stp1", 
            FileTestTool(inp=self.inFileArray),
            scatter="inp"
        )
        self.step(
            "stp2", 
            FileTestTool(inp=self.stp1.out),
            scatter="inp"
        )

        self.output("outFile1", Array(File), source=self.stp1.out)
        self.output("outFile2", Array(File), source=self.stp2.out)

    def friendly_name(self):
        return "TEST: BasicScatterTestWF"

    def id(self) -> str:
        return self.__class__.__name__


# MultiFieldScatterTestWF
# Multi-field scatter (dot) with subsequent consuming steps 

class MultiFieldScatterTestWF(Workflow):

    def constructor(self):
        self.input('inStrArray', Array(String))
        self.input('inFileArray', Array(File))
        self.input('inIntArray', Array(Int))

        self.step(
            "stp1", 
            ComponentsTestTool(
                pos_basic=self.inFileArray,
                opt_basic=self.inStrArray
            ),
            scatter=ScatterDescription(fields=["pos_basic", "opt_basic"], method=ScatterMethods.dot)
        )
        self.step(
            "stp2", 
            FileTestTool(
                inp=self.stp1.out
            ),
            scatter="inp"
        )

        self.output("outFile1", Array(File), source=self.stp1.out)
        self.output("outFile2", Array(File), source=self.stp2.out)

    def friendly_name(self):
        return "TEST: BasicScatterTestWF"

    def id(self) -> str:
        return self.__class__.__name__



# ------------- #
#  SECONDARIES  #
# ------------- #


class SecondariesIOTestWF(Workflow):
    def id(self) -> str:
        return "SecondaryFileScatterTestWF"

    def friendly_name(self):
        return "WF which uses SecondaryFile types for workflow / tool IO"

    def constructor(self):
        self.input('inAlignments', BamBai)

        self.step(
            "stp1", 
            SecondariesTestTool(
                inp=self.inAlignments
            ), 
        )

        self.output("outBamBai", source=self.stp1.out)


class SecondariesConnectionsTestWF(Workflow):
    def id(self) -> str:
        return "SecondariesConnectionsTestWF"

    def friendly_name(self):
        return "WF which uses SecondaryFile types for step connections"

    def constructor(self):
        self.input('inAlignments', BamBai)

        self.step(
            "stp1", 
            SecondariesTestTool(
                inp=self.inAlignments
            ), 
        )
        self.step(
            "stp2", 
            SecondariesTestTool(
                inp=self.stp1.out
            ), 
        )

        self.output("outBamBai", source=self.stp2.out)


# ------------------- #
#  DISGUSTING COMBOS  #
# ------------------- #


class ScatterSecondariesTestWF(Workflow):
    def id(self) -> str:
        return "ScatterSecondaries"

    def friendly_name(self):
        return "WF which uses Scatter and Secondaries"

    def constructor(self):
        self.input('inAlignments', Array(BamBai))
        
        self.step(
            "stp1", 
            SecondariesTestTool(
                inp=self.inAlignments
            ),
            scatter="inp"
        )

        self.output("outBamBaiArray", Array(BamBai), source=self.stp1.out)
        # self.output("outStdout", source=self.stp1.outStdout)



class ArraySecondariesTestWF(Workflow):
    def id(self) -> str:
        return "ArraySecondariesTestWF"

    def friendly_name(self):
        return "WF which uses Arrays pf SecondaryFile types for workflow / tool IO"

    def constructor(self):
        self.input('inAlignments', Array(BamBai))
        
        self.step(
            "stp1", 
            ArraySecondariesTestTool(
                inp=self.inAlignments
            ), 
        )
        self.output("outStdout", source=self.stp1.outStdout)



# class ArrayScatterTestWF(Workflow):
#     def id(self) -> str:
#         return "ArrayScatterTestWF"

#     def friendly_name(self):
#         return "WF which uses Array(File) and Scatter"

#     def constructor(self):
#         self.input('inStrArray', Array(String))
#         self.input('inFileArray', Array(File))
#         self.input('inIntArray', Array(Int))

#         self.step(
#             "stp1", 
#             (testtool=self.inStrArray), 
#             scatter="testtool"
#         )

#         self.output("outStrArray", source=self.stp1.out)


# class HolyGrail(Workflow):
#     def id(self) -> str:
#         return "HolyGrail"

#     def friendly_name(self):
#         return "WF which uses almost every core feature"

#     def constructor(self):
#         pass


