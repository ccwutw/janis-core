

from janis_core import (
    ToolInput, 
    TInput,
    CommandTool,
    PythonTool,
    File, 
    Directory, 
    DataType
)
from janis_core import translation_utils as utils
from janis_core import settings

from ... import nfgen_utils
from ... import task_inputs

from ...model.process.inputs import (
    NFProcessInput, 
    NFPythonToolProcessInput,
    NFPathProcessInput,
    NFValProcessInput,
    NFTupleProcessInput
)


def gen_nf_process_inputs(tool: CommandTool | PythonTool) -> list[NFProcessInput]:
    generator = ProcessInputGenerator(tool)
    return generator.generate()


class ProcessInputGenerator:
    def __init__(self, tool: CommandTool | PythonTool):
        self.tool = tool
        self.process_inputs: list[NFProcessInput] = []
        self.generate_code_file()

    @property
    def dtype(self) -> DataType:
        return self.tinput.input_type if isinstance(self.tinput, ToolInput) else self.tinput.intype # type: ignore
    
    @property
    def basetype(self) -> DataType:
        basetype = utils.get_base_type(self.dtype)
        basetype = utils.ensure_single_type(basetype)
        assert(basetype)
        return basetype
    
    def generate_code_file(self) -> None:
        # pythontool gets extra code_file input before normal inputs
        if isinstance(self.tool, PythonTool):
            new_input = NFPythonToolProcessInput(
                name=settings.translate.nextflow.PYTHON_CODE_FILE_SYMBOL, 
                tinput_id=settings.translate.nextflow.PYTHON_CODE_FILE_SYMBOL, 
                dtype=File())
            self.process_inputs.append(new_input)

    def generate(self) -> list[NFProcessInput]:
        # normal inputs
        tinput_ids = task_inputs.task_inputs(self.tool.id())
        tinputs = nfgen_utils.items_with_id(self.tool.inputs(), tinput_ids)
        
        for inp in tinputs:
            self.tinput = inp
            new_input = self.create_input()
            self.process_inputs.append(new_input)
        
        return self.process_inputs

    def create_input(self) -> NFProcessInput:
        # @secondariesarray
        # secondaries array
        # if self.dtype.optional:
        #     return self.create_val_input(self.tinput)

        if utils.is_array_secondary_type(self.dtype):
            return self.create_path_input_secondaries_array(self.tinput)
        
        # secondaries
        elif utils.is_secondary_type(self.dtype):
            return self.create_tuple_input_secondaries(self.tinput)
        
        # filepair array
        elif utils.is_array_file_pair_type(self.dtype):
            return self.create_path_input(self.tinput)
        
        # filepair
        elif utils.is_file_pair_type(self.dtype):
            return self.create_path_input(self.tinput)
        
        # file array
        elif self.dtype.is_array() and isinstance(self.basetype, (File, Directory)):
            return self.create_path_input(self.tinput)
        
        # file
        elif isinstance(self.basetype, (File, Directory)):
            return self.create_path_input(self.tinput)
        
        # nonfile array
        elif self.dtype.is_array(): 
            return self.create_val_input(self.tinput)

        # nonfile 
        else:
            return self.create_val_input(self.tinput)

    def create_path_input_secondaries_array(self, inp: ToolInput | TInput) -> NFProcessInput:
        # TODO ignoring secondaries_presents_as for now!
        ti = task_inputs.get(self.tool.id(), inp)
        name = ti.value
        assert(isinstance(name, str))
        new_input = NFPathProcessInput(name=name, tinput_id=inp.id(), dtype=self.dtype)
        return new_input

    def create_tuple_input_secondaries(self, inp: ToolInput | TInput) -> NFTupleProcessInput:
        # tuple sub-element for each file
        ti = task_inputs.get(self.tool.id(), inp)
        subnames = ti.value
        assert(isinstance(subnames, list))
        qualifiers = ['path'] * len(subnames)
        
        new_input = NFTupleProcessInput(
            name=inp.id(), 
            tinput_id=inp.id(),
            dtype=self.dtype,
            qualifiers=qualifiers, 
            subnames=subnames
        )
        return new_input

    def create_path_input(self, inp: ToolInput | TInput) -> NFPathProcessInput:
        ti = task_inputs.get(self.tool.id(), inp)
        name = ti.value
        assert(isinstance(name, str))
        presents_as = None
        if isinstance(inp, ToolInput):
            presents_as = inp.presents_as
        new_input = NFPathProcessInput(name=name, tinput_id=inp.id(), dtype=self.dtype, presents_as=presents_as)
        return new_input 

    def create_val_input(self, inp: ToolInput | TInput) -> NFValProcessInput:
        if isinstance(self.dtype, File) and isinstance(inp, ToolInput):
            if inp.presents_as:
                raise NotImplementedError
                presents_as = inp.presents_as
        ti = task_inputs.get(self.tool.id(), inp)
        name = ti.value
        assert(isinstance(name, str))
        new_input = NFValProcessInput(name=name, tinput_id=inp.id(), dtype=self.dtype)
        return new_input
