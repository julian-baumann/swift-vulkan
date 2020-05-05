from xml.etree import ElementTree
from typing import List


class CEnum:
    class Case:
        def __init__(self, name: str, value: str):
            self.name = name
            self.value = value

    def __init__(self, name: str, cases: List[Case]):
        self.name = name
        self.cases = cases


class CContext:
    def __init__(self, extension_tags: List[str] = None, enums: List[CEnum] = None):
        self.extension_tags = extension_tags or []
        self.enums = enums or []

    def parse(self, source):
        tree = ElementTree.parse(source)
        self.parse_tree(tree)

    def parse_tree(self, tree: ElementTree):
        self.parse_extension_tags(tree),
        self.parse_enums(tree)

    def parse_extension_tags(self, tree: ElementTree):
        for tag in tree.findall('./tags/tag'):
            self.extension_tags.append(tag.attrib['name'])

    def parse_enums(self, tree: ElementTree):
        for enum in tree.findall('./enums[@type="enum"]'):
            c_enum = CEnum(name=enum.attrib['name'], cases=[])
            for case in enum.findall('./enum[@value]'):  # TODO: Handle aliases
                c_enum.cases.append(CEnum.Case(name=case.attrib['name'], value=case.attrib['value']))

            case_names = []
            for extension in tree.findall(f'./extensions/extension'):
                ext_number = int(extension.attrib['number'])
                for case in extension.findall(f'./require/enum[@extends="{c_enum.name}"][@offset]'):
                    case_name = case.attrib['name']
                    if case_name in case_names:
                        continue

                    case_ext_number = ext_number
                    if 'extnumber' in case.attrib:
                        case_ext_number = int(case.attrib['extnumber'])

                    value = 1000000000 + (case_ext_number - 1) * 1000 + int(case.attrib['offset'])
                    signed_value = case.get('dir', '') + str(value)

                    case_names.append(case_name)
                    c_enum.cases.append(
                        CEnum.Case(name=case_name, value=signed_value)
                    )

            self.enums.append(c_enum)