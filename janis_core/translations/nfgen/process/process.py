
from enum import Enum
from textwrap import indent

from typing import Optional, Union, List
from abc import ABC, abstractproperty

from ..common import NFBase, filter_null
from ..directives import ProcessDirective
from ..casefmt import to_case
from .. import utils
from .. import settings

class ProcessScriptType(Enum):
    script = "script"
    shell = "shell"
    exec = "exec"








class Process(NFBase):
    def __init__(
        self,
        name: Optional[str],
        script: str,
        script_type: Optional[ProcessScriptType] = None,
        script_quote: Optional[str] = '"',
        inputs: List[ProcessInput] = None,
        outputs: List[ProcessOutput] = None,
        when: Optional[str] = None,  # TODO unimplemented?
        directives: List[ProcessDirective] = None,
        pre_script: Optional[str] = None,
    ):
        self.name = name

        self.script = script
        self.script_type = script_type
        self.script_quote = script_quote

        self.inputs: List[ProcessInput] = inputs or []
        self.outputs: List[ProcessOutput] = outputs or []
        self.directives: List[ProcessDirective] = directives or []
        self.pre_script = pre_script

    def prepare_script(self, prefix="  "):
        script = ''
        script += str(self.script).strip()
        if self.script_quote:
            q = 3 * self.script_quote
            script = q + "\n" + script + "\n" + q

        script = indent(script, prefix)

        if self.pre_script:
            pre_script = indent(self.pre_script, prefix)
        else:
            pre_script = ""

        if self.script_type:
            script = indent(f"{self.script_type.value}:\n{pre_script}\n" + script, "  ")

        return script

    def prepare_inputs(self, prefix="  "):
        if not self.inputs:
            return None
        return indent(
            "input:\n" + "\n".join("  " + i.get_string() for i in self.inputs), "  "
        )

    def prepare_outputs(self, prefix="  "):
        if not self.outputs:
            return None
        return indent(
            "output:\n" + "\n".join(prefix + o.get_string() for o in self.outputs),
            "  ",
        )

    def prepare_directives(self, prefix="  "):
        if not self.directives:
            return None
        return "\n".join(prefix + d.get_string() for d in self.directives)

    def get_string(self) -> str:
        components = filter_null(
            [
                self.prepare_directives(),
                self.prepare_inputs(),
                self.prepare_outputs(),
                self.prepare_script(),
            ]
        )
        name = to_case(self.name, settings.NEXTFLOW_PROCESS_CASE) if self.name else ""
        tool_definition = "\n\n".join(components)

        return f"""\
process {name} {{
{tool_definition}
}}
"""
