from contextlib import contextmanager
from .importer import SwiftEnum, SwiftOptionSet, SwiftStruct, SwiftClass, SwiftCommand
from typing import TextIO, List, Tuple


class BaseGenerator:
    def __init__(self, stream: TextIO):
        self.stream = stream
        self.indent_size = 0

    def write(self, text: str):
        indent = '    ' * self.indent_size
        for line in text.splitlines(keepends=True):
            self.stream.write(indent + line)
        self.linebreak()

    def linebreak(self, n: int=1):
        self.stream.write('\n' * n)

    def __lshift__(self, text: str):
        self.write(text)

    @contextmanager
    def indent(self, prepend: str = None, append: str = None):
        if prepend is not None:
            self << prepend
        self.indent_size += 1
        yield
        self.indent_size -= 1
        if append is not None:
            self << append


class Generator(BaseGenerator):
    def generate_imports(self):
        self << 'import CVulkan'
        self.linebreak()

    def generate_enum(self, enum: SwiftEnum):
        with self.indent(f'enum {enum.name}: {enum.raw_type} {{', '}'):
            for case in enum.cases:
                self << f'case {safe_name(case.name)} = {case.value}'
        self.linebreak()

    def generate_option_set(self, option_set: SwiftOptionSet):
        with self.indent(f'struct {option_set.name}: OptionSet {{', '}'):
            self << f'let rawValue: {option_set.raw_type}'
            for case in option_set.cases:
                self << f'static let {case.name} = {option_set.name}(rawValue: {case.value})'
        self.linebreak()

    def generate_struct(self, struct: SwiftStruct):
        with self.indent(f'struct {struct.name}: CStructConvertible {{', '}'):
            self << f'typealias CStruct = {struct.c_struct.name}'
            self.linebreak()
            for member in struct.members:
                self << f'let {safe_name(member.name)}: {member.type}'
            self.linebreak()
            self.generate_struct_swift_to_c_method(struct)
        self.linebreak()

    def generate_struct_swift_to_c_method(self, struct: SwiftStruct):
        with self.indent('func withCStruct<R>'
                         f'(_ body: (UnsafePointer<{struct.c_struct.name}>) throws -> R)'
                         ' rethrows -> R {', '}'):

            swift_values_map = {member.name: f'self.{member.name}' for member in struct.members}
            closures = [gen(swift_values_map) for gen in struct.closure_generators]

            with self.closures(closures, throws=True):
                self << f'var cStruct = {struct.c_struct.name}()'
                for member, generator in zip(struct.c_struct.members, struct.c_value_generators):
                    self << f'cStruct.{member.name} = {generator(swift_values_map)}'
                self << 'return try body(&cStruct)'

    def generate_class(self, cls: SwiftClass):
        with self.indent(f'class {cls.name} {{', '}'):
            self << f'let handle: {cls.c_handle.name}!'
            if cls.parent:
                self << f'let {cls.parent.reference_name}: {cls.parent.name}'

            self.linebreak()
            self.generate_class_init(cls)

            for command in cls.commands:
                self.linebreak()
                self.generate_command(command)

        self.linebreak()

    def generate_class_init(self, cls: SwiftClass):
        param_string = f'handle: {cls.c_handle.name}!'
        if cls.parent:
            param_string += f', {cls.parent.reference_name}: {cls.parent.name}'

        with self.indent(f'init({param_string}) {{', '}'):
            self << 'self.handle = handle'
            if cls.parent:
                self << f'self.{cls.parent.reference_name} = {cls.parent.reference_name}'

    def generate_command(self, command: SwiftCommand):
        swift_values_map = {param.name: param.name for param in command.params}
        closures = [gen(swift_values_map) for gen in command.closure_generators]

        param_string = ', '.join([f'{param.name}: {param.type}' for param in command.params])
        with self.indent(f'func {command.name}({param_string}) -> {command.return_type} {{', '}'):
            with self.closures(closures):
                param_string = ', '.join([gen(swift_values_map) for gen in command.c_value_generators])
                self << f'{command.c_command.name}({param_string})'

    @contextmanager
    def closures(self, closures: List[Tuple[str, str]], throws: bool = False):
        for closure in closures:
            if throws:
                self << 'try ' + closure[0]
            else:
                self << closure[0]
            self.indent_size += 1
        yield
        for closure in reversed(closures):
            self.indent_size -= 1
            self << closure[1]


def safe_name(name: str) -> str:
    if name in ('repeat', 'default'):
        return f'`{name}`'
    return name
