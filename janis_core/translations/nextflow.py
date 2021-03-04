import json
from typing import Tuple, Dict, List, Optional, Union

from janis_core.types import DataType, Array, String, File, Int, Directory, Stdout, Stderr, Filename, InputSelector, WildcardSelector
from janis_core.operators import Operator, StringFormatter, Selector

from janis_core.tool.commandtool import CommandTool, ToolInput, ToolOutput, ToolArgument, Tool, ToolType
from janis_core.translations.translationbase import TranslatorBase
from janis_core import Logger
from janis_core.workflow.workflow import StepNode, InputNode, OutputNode, WorkflowBase

import janis_core.translations.nfgen as nfgen


class NextflowTranslator(TranslatorBase):
    def __init__(self):
        super().__init__(name="nextflow")

    @classmethod
    def translate_workflow(
        cls,
        workflow,
        with_container=True,
        with_resource_overrides=False,
        allow_empty_container=False,
        container_override: dict = None,
    ) -> Tuple[any, Dict[str, any]]:
        pass

    @classmethod
    def translate_tool_internal(
        cls,
        tool,
        with_container=True,
        with_resource_overrides=False,
        allow_empty_container=False,
        container_override: dict = None,
    ) -> nfgen.process:
        # construct script
        script = cls.prepare_script_for_tool(tool)
        pre_script = cls.prepare_expression_inputs(tool)
        pre_script += cls.prepare_optional_inputs(tool)

        process = nfgen.Process(
            name=tool.id(),
            script=script,
            script_type=nfgen.ProcessScriptType.script,
            pre_script=pre_script,
            outputs_metadata=cls.prepare_tool_output(tool)
        )

        inputs: List[ToolInput] = tool.inputs()
        outputs: List[ToolOutput] = tool.outputs()
        inpmap = {i.id(): i for i in inputs}

        for i in inputs:
            qual = get_input_qualifier_for_inptype(i.input_type)
            inp = nfgen.ProcessInput(qualifier=qual, name=i.id())
            if isinstance(i.input_type, Array) and isinstance(i.input_type.subtype(), File):
                inp.as_process_param = f"Channel.fromPath({nfgen.ProcessInput.PARAM_VAR}).collect()"

            process.inputs.append(inp)

        for o in outputs:
            Logger.debug(o.id())
            qual = get_output_qualifier_for_outtype(o.output_type)
            expression = cls.unwrap_expression(o.selector, inputs_dict=tool.inputs_map(), for_output=True)
            out = nfgen.ProcessOutput(
                qualifier=qual,
                name=o.id(),
                expression=expression,
                is_optional=o.output_type.optional
            )
            process.outputs.append(out)

        if with_container:
            container = (
                NextflowTranslator.get_container_override_for_tool(
                    tool, container_override
                )
                or tool.container()
            )

            if container is not None:
                process.directives.append(
                    nfgen.ContainerDirective(
                        cls.unwrap_expression(container, is_code_environment=True)
                    )
                )
            elif not allow_empty_container:
                raise Exception(
                    f"The tool '{tool.id()}' did not have a container and no container override was specified. "
                    f"Although not recommended, Janis can export empty docker containers with the parameter "
                    f"'allow_empty_container=True' or --allow-empty-container"
                )

        return process.get_string()

    @classmethod
    def translate_code_tool_internal(
        cls,
        tool,
        with_docker=True,
        allow_empty_container=False,
        container_override: dict = None,
    ):
        raise Exception("CodeTool is not currently supported in Nextflow translation")

    @classmethod
    def prepare_string_if_required(cls, value, is_code_environment):
        return f'"{value}"' if is_code_environment else value

    # @classmethod
    # def unwrap_expression(cls, expression, is_code_environment=True):
    #     if isinstance(expression, str):
    #         return cls.prepare_string_if_required(expression, is_code_environment)
    #
    #     raise Exception(
    #         f"Could not detect type '{type(expression)}' to unwrap to nextflow"
    #     )

    @classmethod
    def unwrap_expression(
            cls,
            value,
            code_environment=True,
            selector_override=None,
            tool=None,
            for_output=False,
            inputs_dict=None,
            skip_inputs_lookup=False,
            **debugkwargs,
    ):
        if value is None:
            if code_environment:
                return "null"
            return None

        if isinstance(value, StepNode):
            raise Exception(
                f"The Step node '{value.id()}' was found when unwrapping an expression, "
                f"you might not have selected an output."
            )

        if isinstance(value, list):
            toolid = debugkwargs.get("tool_id", "unwrap_list_expression")
            elements = []
            for i in range(len(value)):
                el = cls.unwrap_expression(
                    value[i],
                    code_environment=True,
                    selector_override=selector_override,
                    tool=tool,
                    tool_id=toolid + "." + str(i),
                    inputs_dict=inputs_dict,
                    skip_inputs_lookup=skip_inputs_lookup,
                    for_output=for_output
                )

                # if isinstance(value, Array):
                #     if value.subtype() is File:
                if for_output:
                    # if isinstance(value[i], File):
                    el = f"path({el})"

                elements.append(el)

            list_representation = ", ".join(elements)

            # inner = ", ".join(
            #     cls.unwrap_expression(
            #         value[i],
            #         code_environment=True,
            #         selector_override=selector_override,
            #         tool=tool,
            #         tool_id=toolid + "." + str(i),
            #         inputs_dict=inputs_dict,
            #         skip_inputs_lookup=skip_inputs_lookup,
            #         for_output=for_output
            #     )
            #     for i in range(len(value))
            # )
            # return cls.wrap_in_codeblock_if_required(
            #     f"$(list \"{inner}\")"
            #     f"", is_code_environment=code_environment
            # )

            # return f"$(list \"{inner}\")"
            return list_representation

        if isinstance(value, str):
            return f"'{value}'"
            # if not code_environment:
            #     return value
            # return cls.quote_values_if_code_environment(
            #     cls.prepare_escaped_string(value), code_environment
            # )
        elif isinstance(value, int) or isinstance(value, float):
            return str(value)
        elif isinstance(value, Filename):
            # value.generated_filenamecwl() if code_environment else f"$({value.generated_filenamecwl()})"
            formatted = cls.quote_values_if_code_environment(
                value.generated_filename(), code_environment
            )

            # if for_output:
            #     formatted = f"path({formatted})"

            return formatted

        # elif isinstance(value, AliasSelector):
        #     return cls.unwrap_expression(
        #         value.inner_selector,
        #         code_environment=code_environment,
        #         selector_override=selector_override,
        #         inputs_dict=inputs_dict,
        #         for_output=for_output,
        #         tool=tool,
        #         **debugkwargs,
        #     )
        #
        elif isinstance(value, StringFormatter):
            return cls.translate_string_formatter(
                value,
                selector_override=selector_override,
                code_environment=code_environment,
                tool=tool,
                inputs_dict=inputs_dict,
                skip_inputs_lookup=skip_inputs_lookup,
                **debugkwargs,
            )
        # elif isinstance(value, InputNodeSelector):
        #     return translate_input_selector(
        #         InputSelector(value.id()),
        #         code_environment=code_environment,
        #         selector_override=selector_override,
        #         inputs_dict=inputs_dict,
        #         skip_inputs_lookup=True,
        #     )
        # elif isinstance(value, StepOutputSelector):
        #     sel = f"{value.node.id()}/{value.tag}"
        #     if sel in selector_override:
        #         return selector_override[sel]
        #     raise Exception(
        #         "An internal error occurred when unwrapping an operator, found StepOutputSelector with no alias"
        #     )
        # elif isinstance(value, ResourceSelector):
        #     if not tool:
        #         raise Exception(
        #             f"Tool must be provided when unwrapping ResourceSelector: {type(value).__name__}"
        #         )
        #     operation = value.get_operation(tool, hints={})
        #     return cls.unwrap_expression(
        #         operation,
        #         code_environment=code_environment,
        #         tool=tool,
        #         inputs_dict=inputs_dict,
        #         **debugkwargs,
        #     )
        #
        # elif for_output and isinstance(value, (Stderr, Stdout)):
        #     # next few ones we rely on the globs being
        #     if isinstance(value, Stdout):
        #         return "self[0]"
        #     elif isinstance(value, Stderr):
        #         return "self[1]"

        elif isinstance(value, InputSelector):
            if for_output:
                el = cls.prepare_filename_replacements_for(value, inputsdict=inputs_dict)
                return cls.wrap_in_codeblock_if_required(
                    el, is_code_environment=code_environment
                )
            return cls.translate_input_selector(
                selector=value,
                code_environment=code_environment,
                selector_override=selector_override,
                inputs_dict=inputs_dict,
                skip_inputs_lookup=skip_inputs_lookup
            )
        elif isinstance(value, WildcardSelector):
            raise Exception(
                f"A wildcard selector cannot be used as an argument value for '{debugkwargs}'"
            )
        elif isinstance(value, Operator):
            unwrap_expression_wrap = lambda exp: cls.unwrap_expression(
                exp,
                code_environment=True,
                selector_override=selector_override,
                tool=tool,
                for_output=for_output,
                inputs_dict=inputs_dict,
                skip_inputs_lookup=skip_inputs_lookup,
                **debugkwargs,
            )

            # if for_output:
            #     return value.to_nextflow_output_var(unwrap_expression_wrap, *value.args)

            return value.to_nextflow(unwrap_expression_wrap, *value.args)

            # return cls.wrap_in_codeblock_if_required(
            #     value.to_nextflow(unwrap_expression_wrap, *value.args),
            #     is_code_environment=code_environment,
            # )
        elif callable(getattr(value, "cwl", None)):
            return value.cwl()
        # elif isinstance(value, Operator):

        raise Exception(
            "Could not detect type %s to convert to input value" % type(value)
        )

    @classmethod
    def prepare_filename_replacements_for(cls,
                                          inp: Optional[Selector], inputsdict: Optional[Dict[str, ToolInput]]
                                          ) -> Optional[str]:
        if inp is None or not isinstance(inp, InputSelector):
            return None

        if not inputsdict:
            return "inputs." + inp.input_to_select + ".basename"
            # raise Exception(
            #     f"Couldn't generate filename as an internal error occurred (inputsdict did not contain {inp.input_to_select})"
            # )

        if isinstance(inp, InputSelector):
            if inp.input_to_select not in inputsdict:
                raise Exception(
                    f"The InputSelector '{inp.input_to_select}' did not select a valid input"
                )

            tinp = inputsdict.get(inp.input_to_select)
            intype = tinp.intype

            if intype.is_base_type((File, Directory)):
                potential_extensions = (
                    intype.get_extensions() if intype.is_base_type(File) else None
                )
                if inp.remove_file_extension and potential_extensions:
                    base = f"inputs.{tinp.id()}.basename"
                    for ext in potential_extensions:
                        base += f'.replace(/{ext}$/, "")'
                elif tinp.localise_file:
                    base = f"inputs.{tinp.id()}.basename"
                else:
                    base = f"inputs.{tinp.id()}"
            elif (
                    intype.is_array()
                    and isinstance(intype.fundamental_type(), (File, Directory))
                    and tinp.localise_file
            ):
                base = f"inputs.{tinp.id()}.map(function(el) {{ return el.basename; }})"
            else:
                base = f"\"${{{tinp.id()}}}\""

            if intype.optional:
                replacement = f'inputs.{tinp.id()} ? {base} : "generated"'
            else:
                replacement = f"{base}"

            return replacement

    @classmethod
    def translate_input_selector(cls,
                                 selector: InputSelector,
                                 code_environment,
                                 inputs_dict,
                                 selector_override=None,
                                 skip_inputs_lookup=False,
                                 ):
        # TODO: Consider grabbing "path" of File

        sel: str = selector.input_to_select
        if not sel:
            raise Exception("No input was selected for input selector: " + str(selector))

        skip_lookup = skip_inputs_lookup or sel.startswith("runtime_")

        if selector_override and sel in selector_override:
            sel = selector_override[sel]

        if not skip_lookup:

            if inputs_dict is None:
                raise Exception(
                    f"An internal error occurred when translating input selector '{sel}': the inputs dictionary was None"
                )
            if selector.input_to_select not in inputs_dict:
                raise Exception(
                    f"Couldn't find the input '{sel}' for the InputSelector(\"{sel}\")"
                )

            tinp: ToolInput = inputs_dict[selector.input_to_select]

            intype = tinp.intype
            if selector.remove_file_extension:
                if intype.is_base_type((File, Directory)):
                    potential_extensions = (
                        intype.get_extensions() if intype.is_base_type(File) else None
                    )
                    if selector.remove_file_extension and potential_extensions:
                        # sel = f"{sel}.basename"
                        # for ext in potential_extensions:
                        #     sel += f'.replace(/{ext}$/, "")'
                        for ext in potential_extensions:
                            sel = f"{{{sel}%{ext}}}"

                        sel = f"(basename \"${sel}\")"

                elif intype.is_array() and isinstance(
                        intype.fundamental_type(), (File, Directory)
                ):
                    inner_type = intype.fundamental_type()
                    extensions = (
                        inner_type.get_extensions()
                        if isinstance(inner_type, File)
                        else None
                    )

                    inner_sel = f"el.basename"
                    if extensions:
                        for ext in extensions:
                            inner_sel += f'.replace(/{ext}$/, "")'
                    sel = f"{sel}.map(function(el) {{ return {inner_sel}; }})"
                else:
                    Logger.warn(
                        f"InputSelector {sel} is requesting to remove_file_extension but it has type {tinp.input_type.id()}"
                    )
            # elif tinp.localise_file:
            #     if intype.is_base_type((File, Directory)):
            #         sel += ".basename"
            #     elif intype.is_array() and isinstance(
            #             intype.fundamental_type(), (File, Directory)
            #     ):
            #         sel = f"{sel}.map(function(el) {{ return el.basename; }})"

        # sel = f"${sel}"
        # return sel if code_environment else f"$({sel})"

        return sel

    @classmethod
    def build_inputs_file(
            cls,
            tool,
            recursive=False,
            merge_resources=False,
            hints=None,
            additional_inputs: Dict = None,
            max_cores=None,
            max_mem=None,
            max_duration=None,
    ) -> Dict[str, any]:

        ad = additional_inputs or {}
        values_provided_from_tool = {}
        # if tool.type() == ToolType.Workflow:
        #     values_provided_from_tool = {
        #         i.id(): i.value or i.default
        #         for i in tool.input_nodes.values()
        #         if i.value or (i.default and not isinstance(i.default, Selector))
        #     }

        count = 0
        inp = {}
        for i in tool.tool_inputs():
            val = ad.get(i.id(), values_provided_from_tool.get(i.id()))

            inputsdict = tool.inputs_map()

            if isinstance(i.intype, Filename):
                val = cls.unwrap_expression(i.intype.generated_filename(), inputs_dict=inputsdict)

            if val is None:
                if isinstance(i.intype, (File, Directory)):
                    count += 1
                    val = f"{nfgen.Process.NO_FILE_PATH_PREFIX}{count}"
                else:
                    val = ''

            inp[i.id()] = val

        # if merge_resources:
        #     for k, v in cls.build_resources_input(
        #             tool,
        #             hints,
        #             max_cores=max_cores,
        #             max_mem=max_mem,
        #             max_duration=max_duration,
        #     ).items():
        #         inp[k] = ad.get(k, v)

        return inp

    @staticmethod
    def stringify_translated_workflow(wf):
        return wf

    @staticmethod
    def stringify_translated_tool(tool):
        return tool

    @staticmethod
    def stringify_translated_inputs(inputs):
        formatted = {}
        for key in inputs:
            # We want list to be formatted as ["xxx", "yyy"] instead of "['xxx', 'yyy']"
            if inputs[key] is not None:
                if type(inputs[key]) is list:
                    val = inputs[key]
                else:
                    val = str(inputs[key])
            else:
                val = ''

            formatted[key] = val

        return json.dumps(formatted)

    @staticmethod
    def workflow_filename(workflow):
        return workflow.versioned_id() + ".nf"

    @staticmethod
    def inputs_filename(workflow):
        return workflow.versioned_id() + ".input.json"

    @staticmethod
    def tool_filename(tool):
        prefix = tool
        if isinstance(tool, Tool):
            prefix = tool.versioned_id()

        return prefix + ".nf"

    @staticmethod
    def resources_filename(workflow):
        return workflow.id() + "-resources.json"

    @staticmethod
    def validate_command_for(wfpath, inppath, tools_dir_path, tools_zip_path):
        pass

    @classmethod
    def wrap_in_codeblock_if_required(cls, value, is_code_environment):
        return value if is_code_environment else f"$({value})"

    @classmethod
    def quote_values_if_code_environment(cls, value, is_code_environment):
        return f'"{value}"' if is_code_environment else value

    @classmethod
    def prepare_escaped_string(cls, value: str):
        return json.dumps(value)[1:-1]

    @classmethod
    def prepare_script_for_tool(cls, tool: CommandTool):
        bc = tool.base_command()
        pargs = []

        if bc:
            pargs.append(" ".join(bc) if isinstance(bc, list) else str(bc))

        # args = sorted(
        #     [*(tool.arguments() or []), *(tool.inputs() or [])],
        #     key=lambda a: a.position or 0,
        # )

        args = [a for a in tool.arguments() or [] if a.position is not None or a.prefix is not None]
        args += [a for a in tool.inputs() or [] if a.position is not None or a.prefix is not None]
        args = sorted(args, key=lambda a: a.position or 0)

        prefix = "  "
        for a in args:
            if isinstance(a, ToolInput):
                pargs.append(f"${a.id()}WithPrefix")
            elif isinstance(a, ToolArgument):
                pargs.append(f"{a.value}")
            else:
                raise Exception("unknown input type")

        main_script = " \\\n".join(pargs)

        return f"""
{main_script} > {nfgen.Process.TOOL_STDOUT_FILENAME}

"""

    @classmethod
    def prepare_tool_output(cls, tool: Tool):
        inputsdict = tool.inputs_map()

        outputs = {}
        for out in tool.outputs():
            # if isinstance(out.output_type, Array):
            #     val = []
            #     for sel in out.selector:
            #         val.append("DIR/" + cls.unwrap_expression(sel, inputs_dict=inputsdict))
            #
            # elif isinstance(out.output_type, Stdout):
            #     val = "STDOUT"
            # elif isinstance(out.output_type, Stderr):
            #     val = "STDERR"
            # elif isinstance(out.output_type, File):
            #     sel = out.selector
            #     if sel is None:
            #         sel = out.glob
            #
            #     val = "DIR/" + cls.unwrap_expression(sel, inputs_dict=inputsdict)

            if isinstance(out.output_type, Stdout):
                val = "STDOUT"
            elif isinstance(out.output_type, Stderr):
                val = "STDERR"
            else:
                val = f"${tool.id()}{out.tag}"

            outputs[out.tag] = val

        return outputs

    @classmethod
    def prepare_expression_inputs(cls, tool):

        inputsdict = tool.inputs_map()

        script_lines = []
        for i in tool.tool_inputs():
            if isinstance(i.intype, Filename):
                val = cls.unwrap_expression(i.intype.generated_filename(), inputs_dict=inputsdict)

                code = f"""
def {i.id()} = {val}
"""
                script_lines.append(code)

        return "".join(script_lines)

    @classmethod
    def prepare_optional_inputs(self, tool):
        pre_script_lines = []
        for a in tool.inputs():
            arg_name = ""
            if isinstance(a, ToolInput):
                arg_name = a.id()
            elif isinstance(a, ToolArgument):
                continue
            else:
                raise Exception("unknown input type")

            if isinstance(a.input_type, Array):
                arg_value = f"{arg_name}.join(' ')"
            else:
                arg_value = arg_name

            if a.input_type.optional:
                arg_value = f"optional({arg_value}, '{a.prefix or ''}')"

            code = f"""
def {arg_name}WithPrefix =  {arg_value}
"""

            pre_script_lines.append(code)

        return "".join(pre_script_lines)


def get_input_qualifier_for_inptype(inp_type: DataType) -> nfgen.InputProcessQualifier:

    if isinstance(inp_type, Array):
        inp_type = inp_type.fundamental_type()

    if isinstance(inp_type, (File, Directory)):
        return nfgen.InputProcessQualifier.path
    return nfgen.InputProcessQualifier.val


def get_output_qualifier_for_outtype(
    out_type: DataType,
) -> nfgen.OutputProcessQualifier:
    # if isinstance(out_type, Array):
    #     out_type = out_type.fundamental_type()

    Logger.debug(out_type)
    if isinstance(out_type, Array):
        return nfgen.OutputProcessQualifier.tuple

    # if hasattr(out_type, 'subtype'):
    #     if callable(out_type.subtype):
    #         return nfgen.OutputProcessQualifier.tuple

    elif isinstance(out_type, Stdout):
        return nfgen.OutputProcessQualifier.stdout

    elif isinstance(out_type, (File, Directory)):
        return nfgen.OutputProcessQualifier.path

    return nfgen.OutputProcessQualifier.val
