

from typing import Optional, Any

from janis_core.ingestion.galaxy.gxtool.model import XMLTool
from janis_core.ingestion.galaxy.gxworkflow.tool_state.load import load_tool_state

from .loading import load_vanilla_command_str
from .loading import load_templated_command_str
from .cmdstr.CommandString import CommandString
from .cmdstr.CommandString import CommandStringSource
from .cmdstr.generate import gen_command_string
from .annotation import SimpleInlineBoolAnnotator
from .annotation import SimpleMultilineBoolAnnotator
from .annotation import SimpleSelectAnnotator
from .annotation import OptionParamAnnotator
from .annotation import LocalCmdstrAnnotator
from .annotation import GlobalCmdstrAnnotator
from .Command import Command

"""
Generates a Command object from a Galaxy XML tool definition.
The Command object stores the positional, optional, and flag arguments of the software tool. 
"""

def gen_command(
    xmltool: XMLTool, 
    gxstep: Optional[dict[str, Any]]=None,
    annotators: Optional[list[str]]=None
    ) -> Command:
    factory = CommandFactory(xmltool, gxstep, annotators)
    return factory.create()

class CommandFactory:
    DEFAULT_ANNOTATORS = [
        'SimpleInlineBoolAnnotator',
        'SimpleMultilineBoolAnnotator',
        'SimpleSelectAnnotator',
        'OptionParamAnnotator',
        'LocalCmdstrAnnotator',
        'GlobalCmdstrAnnotator',
    ]

    def __init__(
        self, 
        xmltool: XMLTool, 
        gxstep: Optional[dict[str, Any]]=None,
        annotators: Optional[list[str]]=None
        ) -> None:
        self.xmltool = xmltool
        self.gxstep = gxstep
        self.annotators = annotators if annotators else self.DEFAULT_ANNOTATORS
        self.command = Command()

    def create(self) -> Command:
        if 'SimpleInlineBoolAnnotator' in self.annotators:
            SimpleInlineBoolAnnotator(self.command, self.xmltool).annotate()
        if 'SimpleMultilineBoolAnnotator' in self.annotators:
            SimpleMultilineBoolAnnotator(self.command, self.xmltool).annotate()
        if 'SimpleSelectAnnotator' in self.annotators:
            SimpleSelectAnnotator(self.command, self.xmltool).annotate()
        if 'OptionParamAnnotator' in self.annotators:
            OptionParamAnnotator(self.command, self.xmltool).annotate()
        if 'LocalCmdstrAnnotator' in self.annotators:
            LocalCmdstrAnnotator(self.command, self.xmltool).annotate()
        if 'GlobalCmdstrAnnotator' in self.annotators:
            GlobalCmdstrAnnotator(self.command, self.xmltool, self.gen_cmdstrs()).annotate()
        return self.command
    
    def gen_cmdstrs(self) -> list[CommandString]:
        # NOTE unsure on ordering - vanilla, templated, tests? 
        cmdstrs: list[CommandString] = []

        # templated tool state  
        if self.gxstep:
            inputs_dict = load_tool_state(
                self.gxstep, 
                additional_filters=[
                    # 'ReplaceNullWithVarname'
                    'ReplaceConnectedWithVarname',
                    'ReplaceRuntimeWithVarname',
                ]
            )
            text = load_templated_command_str(inputs_dict)
            cmdstr = gen_command_string(source=CommandStringSource.TOOL_STATE, text=text, xmltool=self.xmltool)
            cmdstrs.append(cmdstr)

        # vanilla xml
        text = load_vanilla_command_str()
        cmdstr = gen_command_string(source=CommandStringSource.XML, text=text, xmltool=self.xmltool)
        cmdstrs.append(cmdstr)
        
        # # templated tests
        # for test in self.xmltool.tests.list():
        #     text = load_templated_command_str(test.inputs)
        #     cmdstr = gen_command_string(source=CommandStringSource.TEST, text=text, xmltool=self.xmltool)
        #     cmdstrs.append(cmdstr)
        
        return cmdstrs






