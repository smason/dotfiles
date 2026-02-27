"""
Utility to selectively disable keypresses to specific windows.

This program was written due to Firefox's pop-out video player closing when
the Escape key is pressed.  I use a modal text editor (Helix) that encourages
regularly pressing that key and it had a habit of going to the wrong window.

The easiest way I could find to make this window specific key-binding change was
via this code.  Specifically it watches focus changes until the "right" windowds
is focused, and then causes Sway to bind the Escape key before Firefox can see
it.  It continues to watch focus changes so that this binding can be disabled
when another window is selected.

This feels like a potentially useful pattern, please let us know:
  https://github.com/OctopusET/sway-contrib
of any other programs that this functionality would benefit.
"""

import argparse
import logging
import signal
from dataclasses import dataclass
from typing import Any, Callable, Iterator

import i3ipc
from i3ipc.events import IpcBaseEvent

logger = logging.getLogger(__name__)


type WatchLambda = Callable[[object], Iterator[tuple[str, str]]]


@dataclass(slots=True)
class Watch:
    container_props: dict[str, str]
    callback: WatchLambda


class Monitor:
    bound: set[str]
    watched: list[Watch]

    def __init__(self) -> None:
        self.ipc = i3ipc.Connection()
        self.ipc.on("window::focus", self.on_window_event)
        # firefox creates PIP window without title, so need to watch for changes
        self.ipc.on("window::title", self.on_window_event)
        self.bound = set()
        self.watched = []

    def bind(self, callback: WatchLambda, props: dict[str, str]) -> None:
        self.watched.append(Watch(props, callback))

    def _unbind(self, bound: set[str]) -> None:
        if not bound:
            return
        logger.info("unbinding keys %s", bound)
        for key in bound:
            self.ipc.command(f"unbindsym {key}")

    def run(self) -> None:
        "run main i3ipc event loop"
        ipc = self.ipc

        def sighandler(signum: int, frame: Any) -> None:
            logger.debug("exit signal received, stopping event loop")
            ipc.main_quit()

        # stop event loop when we get one of these
        for sig in signal.SIGINT, signal.SIGTERM:
            signal.signal(sig, sighandler)

        try:
            ipc.main()
        finally:
            self._unbind(self.bound)

    def on_window_event(self, ipc: i3ipc.Connection, event: IpcBaseEvent) -> None:
        "respond to window events"
        match event:
            case i3ipc.WindowEvent(container=i3ipc.Con(focused=True, ipc_data=data)):
                pass
            case _:
                logging.error("invalid window event %s", event)

        prev = self.bound
        bound = set()
        for watch in self.watched:
            if all(data.get(k) == v for k, v in watch.container_props.items()):
                for key, resp in watch.callback(data):
                    logger.debug("binding %r to %r", key, resp)
                    self.ipc.command(f"bindsym {key} {resp}")
                    bound.add(key)
                    prev.discard(key)

        if bound:
            logger.info("keys bound %s", bound)

        self.bound = bound

        self._unbind(prev)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="track active window to disable Esc key in Firefox popout media player",
    )
    parser.add_argument(
        "--verbose", "-v", help="Increase verbosity", action="store_true"
    )
    args = parser.parse_args()
    args.loglevel = logging.DEBUG if args.verbose else logging.INFO
    return args


KEY_ALT = "Mod1"
KEY_ESCAPE = "Escape"

PREFERRED_SIZES = [
    (f"{KEY_ALT}+0", 960, 540),
    (f"{KEY_ALT}+1", 1280, 720),
    (f"{KEY_ALT}+2", 1920, 1080),
]


def calculate_size_binds(width: int, height: int) -> Iterator[tuple[str, int, int]]:
    aspect = width / height
    for bind, width_pref, height_pref in PREFERRED_SIZES:
        if aspect < width_pref / height_pref:
            yield bind, width_pref, round(width_pref / aspect)
        else:
            yield bind, round(height_pref * aspect), height_pref


def do_firefox_pip(data) -> Iterator[tuple[str, str]]:
    yield KEY_ESCAPE, "nop 'Ignoring escape key in Firefox popout video'"
    # use match on Sway JSON data to reduce error checking
    match data:
        case {"geometry": {"width": int(width), "height": int(height)}}:
            logger.debug("firefox popout width=%s height=%s", width, height)

            for bind, px, py in calculate_size_binds(width, height):
                yield bind, f"resize set width {px}px height {py}px"


def main() -> None:
    args = parse_args()
    logging.basicConfig(
        level=args.loglevel,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    mon = Monitor()
    # block Escape key from reaching Firefox's popout window
    mon.bind(do_firefox_pip, {"app_id": "firefox", "name": "Picture-in-Picture"})
    mon.run()


if __name__ == "__main__":
    main()
