


from typing import Any, Optional
from textwrap import indent

from janis_core import CommandTool, PythonTool, Workflow, ScatterDescription, TInput
from janis_core.workflow.workflow import StepNode
from janis_core.types import DataType, Stdout
from janis_core import settings

from ... import trace

from ...model.process import NFProcess
from ...model.workflow import NFWorkflow

from ...unwrap import unwrap_expression
from ...variables import VariableManager

from .datatype_mismatch import is_datatype_mismatch
from .datatype_mismatch import gen_datatype_mismatch_plumbing

from .edge_cases import satisfies_edge_case
from .edge_cases import handle_edge_case

NF_INDENT = settings.translate.nextflow.NF_INDENT



def gen_task_call(alias: str, task: NFProcess | NFWorkflow, vmanager: VariableManager, step: StepNode) -> list[str]:
    generator = TaskCallGenerator(alias, task, vmanager, step)
    return generator.generate()


class TaskCallGenerator:
    def __init__(self, alias: str, task: NFProcess | NFWorkflow, vmanager: VariableManager, step: StepNode) -> None:
        self.alias = alias
        self.task = task
        self.step = step
        self.vmanager = vmanager
        
        self.tool: CommandTool | PythonTool | Workflow  = step.tool     
        self.sources: dict[str, Any]                    = step.sources
        
        # want to calculate these
        self.args: list[str] = []
        self.call: list[str] = []

    @property
    def ordered_task_input_ids(self) -> list[str]:
        if isinstance(self.task, NFProcess):
            return [x.tinput_id for x in self.task.inputs]
        elif isinstance(self.task, NFWorkflow): # type: ignore
            return [x.tinput_id for x in self.task.take]
        else:
            raise RuntimeError

    def generate(self) -> list[str]:
        self.args = self.get_call_arguments()
        self.call = self.format_task_call()
        return self.call
    
    def get_call_arguments(self) -> list[str]:
        call_args: list[str] = []

        for tinput_id in self.ordered_task_input_ids:
            arg = self.get_call_arg(tinput_id)
            call_args.append(arg)
        
        # TODO check
        # add extra arg in case of python tool - the code file.
        # a param with the same name will have already been created. 
        # if isinstance(self.tool, PythonTool):
        #     scope_joined = self.task_scope.to_string(ignore_base_item=True)
        #     call_args = [f'params.{scope_joined}.code_file'] + call_args
        
        return call_args
    
    def get_call_arg(self, tinput_id: str) -> str:
        generator = TaskCallArgumentGenerator(
            tinput_id=tinput_id,
            vmanager=self.vmanager,
            # calling_scope=self.calling_scope,
            step=self.step
        )
        return generator.generate()

    # formatting task call text
    def format_task_call(self, ind: int=0) -> list[str]:
        if len(self.args) == 0:
            call_lines = self.call_fmt0()
        else:
            call_lines = self.call_fmt2()
        call_lines = [indent(ln, ind * NF_INDENT) for ln in call_lines]
        return call_lines

    def call_fmt0(self) -> list[str]:
        return [f'{self.alias}()']

    def call_fmt2(self) -> list[str]:
        call_lines: list[str] = []
        call_lines.append(f'{self.alias}(')
        for i, inp in enumerate(self.args):
            comma = ',' if i < len(self.args) - 1 else ''
            call_lines.append(f'{NF_INDENT}{inp}{comma}')
        call_lines.append(')')
        return call_lines

 

class TaskCallArgumentGenerator:
    def __init__(self, tinput_id: str, vmanager: VariableManager, step: StepNode) -> None:
        self.tinput_id = tinput_id
        self.vmanager = vmanager

        self.tool: CommandTool | PythonTool | Workflow  = step.tool     
        self.scatter: Optional[ScatterDescription]      = step.scatter
        self.src: Optional[Any]                         = None 

        # update if has source
        if self.tinput_id in step.sources:
            self.src = step.sources[self.tinput_id]

    @property
    def tinput(self) -> TInput:
        return [x for x in self.tool.tool_inputs() if x.id() == self.tinput_id][0]

    @property
    def srctype(self) -> Optional[DataType]:
        """the datatype of the data source"""
        if self.src:
            dtype = trace.trace_source_datatype(self.src)
            assert(dtype)
            if isinstance(dtype, Stdout):
                return dtype.subtype
            else:
                return dtype
        return None
        
    @property
    def desttype(self) -> DataType:
        """the datatype of the relevant ToolInput"""
        tinputs = self.tool.tool_inputs()
        tinp = [x for x in tinputs if x.id() == self.tinput_id][0]
        return tinp.intype  # type: ignore
    
    # @property
    # def src_scatter(self) -> bool:
    #     return trace.trace_source_scatter(self.src)

    @property
    def dest_scatter(self) -> bool:
        if self.scatter and self.tinput_id in self.scatter.fields:
            return True
        return False

    def generate(self) -> str:
        """calculate the arg which will feed this task input"""
        arg = unwrap_expression(
            val=self.src,
            context='workflow',
            variable_manager=self.vmanager,
            quote_strings=True
        )
        if arg is None:
            arg = 'null'
            
        if isinstance(arg, list):
            raise NotImplementedError
            call_args += arg

        # handle misc edge case (takes priority over datatype mismatches)
        if self.src is not None and satisfies_edge_case(self.src):
            suffix = handle_edge_case(self.src)
            arg = f'{arg}{suffix}'

        # handle datatype relationship
        elif self.srctype is not None and is_datatype_mismatch(self.srctype, self.desttype, self.dest_scatter):
            suffix = gen_datatype_mismatch_plumbing(self.srctype, self.desttype, self.dest_scatter)
            arg = f'{arg}{suffix}'
        
        return arg

    




