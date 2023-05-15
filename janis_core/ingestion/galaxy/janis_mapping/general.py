
from typing import Optional
from copy import deepcopy

from janis_core import (
    InputSelector,
    WildcardSelector
)
from janis_core import (
    DataType,
    Stdout,
    Array,
    String,
    Int, 
    Float,
    Boolean,
    File,
    Directory
)

from janis_core.ingestion.galaxy import tags
from janis_core.ingestion.galaxy.model.workflow.input import WorkflowInput
from janis_core.ingestion.galaxy.model.workflow.step.outputs import StepOutput
from janis_core.ingestion.galaxy.gx.command.components import (
    InputComponent,
    OutputComponent,
    RedirectOutput,
    InputOutput,
    WildcardOutput,
)

datatype_map = {
    'String': String(),
    'Int': Int(),
    'Float': Float(),
    'Boolean': Boolean(),
    'File': File(),
    'Directory': Directory(),
}

DATATYPE_COMPONENT = InputComponent | OutputComponent | WorkflowInput | StepOutput

def to_janis_datatype(component: DATATYPE_COMPONENT) -> DataType:
    if isinstance(component, StepOutput):
        component = component.tool_output
    
    # the underlying datatype, regardless of stdout / array / optionality
    dtype = deepcopy(datatype_map[component.datatype.classname])
    
    # modifying dtype in array case
    if component.array:
        dtype = Array(dtype)
    
    # modifying dtype in stdout case
    if isinstance(component, RedirectOutput):
        dtype = Stdout(dtype)

    # modifying dtype in optional case
    if component.optional:
        dtype.optional = True
    return dtype


def to_janis_selector(component: OutputComponent) -> Optional[InputSelector | WildcardSelector]:
    # wildcard specified 
    if component.gxparam:
        if hasattr(component.gxparam, 'from_work_dir') and component.gxparam.from_work_dir:
            wildcard = component.gxparam.from_work_dir
        elif hasattr(component.gxparam, 'from_work_dir') and component.gxparam.discover_pattern:
            wildcard = component.gxparam.discover_pattern
        else:
            wildcard = None

        if wildcard is not None:  
            return WildcardSelector(wildcard)
    
    if isinstance(component, InputOutput):
        input_comp_tag = tags.get(component.input_component.uuid)
        return InputSelector(input_comp_tag)

    return WildcardSelector('unknown')
    
        
    
    


