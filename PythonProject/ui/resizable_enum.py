from enum import Enum

class ResizableEnum(Enum):
    NOT_RESIZABLE = 0
    WIDTH_ONLY = 1
    HEIGHT_ONLY = 2
    RESIZABLE = 3