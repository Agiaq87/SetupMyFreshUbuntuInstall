import tkinter as tk
from typing import Callable
from unittest import case

from ui.background_enum import BackgroundEnum
from ui.geometry_enum import GeometryEnum
from ui.resizable_enum import ResizableEnum


def makeWindow(
        title: str,
        geometry: GeometryEnum = GeometryEnum.NORMAL,
        resizable: ResizableEnum = ResizableEnum.NOT_RESIZABLE,
        background: BackgroundEnum = BackgroundEnum.GRAY,
) -> tk.Tk:
    window = tk.Tk()
    window.title(title)
    window.geometry(geometry.value)
    window.configure(background=background.value)
    match resizable:
        case ResizableEnum.RESIZABLE: window.resizable(True, True)
        case ResizableEnum.NOT_RESIZABLE: window.resizable(False, False)
        case ResizableEnum.WIDTH_ONLY: window.resizable(True, False)
        case ResizableEnum.HEIGHT_ONLY: window.resizable(False, True)

    return window

def makeButton(
        title: str,
        action: Callable,
) -> tk.Button:
    button = tk.Button(
        text=title,
        command=action,
    )

    return button